import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../models/split_models.dart';
import '../../services/split_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/split_sheets.dart';

class SplitGroupScreen extends StatefulWidget {
  final String groupId;

  const SplitGroupScreen({super.key, required this.groupId});

  @override
  State<SplitGroupScreen> createState() => _SplitGroupScreenState();
}

class _SplitGroupScreenState extends State<SplitGroupScreen> {
  final _store = SplitStore.instance;
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  final _scroll = ScrollController();
  DateTime? _remindAt;
  bool _sending = false;
  bool _membersPanelOpen = false;
  /// UI-only ticks for design preview (function later).
  final Set<String> _memberTicks = {};

  final _money = NumberFormat.currency(locale: 'en_IN', symbol: '\u20B9');

  SplitGroup? get _group => _store.byId(widget.groupId);

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onChange);
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _remindAt ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _remindAt ?? now.add(const Duration(hours: 1)),
      ),
    );
    if (time == null) return;
    setState(() {
      _remindAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _onSendPressed() async {
    final g = _group;
    if (g == null) return;

    final amount = double.tryParse(_amountCtrl.text.trim());
    if (amount == null || amount <= 0) {
      _snack('Enter a valid amount');
      return;
    }
    if (g.members.isEmpty) {
      _snack('Add members to the group first');
      return;
    }

    // Split only among checked members (default: everyone if panel never opened).
    final splitAmong = _memberTicks.isEmpty
        ? List<SplitMember>.from(g.members)
        : g.members.where((m) => _memberTicks.contains(m.id)).toList();
    if (splitAmong.isEmpty) {
      _snack('Select at least one member to split with');
      return;
    }

    final paidBy = await showModalBottomSheet<SplitMember>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _PaidBySheet(
        amount: amount,
        note: _noteCtrl.text.trim(),
        remindAt: _remindAt,
        members: splitAmong,
        money: _money,
      ),
    );

    if (paidBy == null || !mounted) return;

    setState(() => _sending = true);
    await _store.addExpense(
      groupId: widget.groupId,
      amount: amount,
      note: _noteCtrl.text,
      remindAt: _remindAt,
      paidBy: paidBy,
      splitAmong: splitAmong,
    );
    _amountCtrl.clear();
    _noteCtrl.clear();
    setState(() {
      _remindAt = null;
      _sending = false;
      _membersPanelOpen = false;
    });
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _scrollToLatest();
  }

  void _scrollToLatest({bool animate = true}) {
    if (!_scroll.hasClients) return;
    // reverse: true ListView — latest messages sit at offset 0 (bottom).
    if (animate) {
      _scroll.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _scroll.jumpTo(0);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  Future<Map<String, String>?> _promptContact({
    required String title,
    String name = '',
    String phone = '',
    required String confirm,
  }) {
    return showContactSheet(
      context,
      title: title,
      name: name,
      phone: phone,
      confirmLabel: confirm,
    );
  }

  Future<void> _addMemberQuick() async {
    final data = await _promptContact(
      title: 'Add member',
      confirm: 'Add',
    );
    if (data == null) return;
    if (data['name']!.isEmpty || data['phone']!.isEmpty) {
      _snack('Name and phone are required');
      return;
    }
    await _store.addMember(
      groupId: widget.groupId,
      name: data['name']!,
      phone: data['phone']!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = _group;
    if (g == null) {
      return PageScaffold(
        title: 'Split',
        body: const Center(child: Text('Group not found')),
      );
    }

    return PageScaffold(
      title: g.name,
      subtitle: '${g.members.length} members',
      actions: [
        TextButton.icon(
          onPressed: _addMemberQuick,
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 20),
          label: const Text('Add'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.ocean,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
      ],
      body: Column(
        children: [
          // Settle row
          Material(
            color: AppColors.softSky,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.slate,
                          ),
                        ),
                        Text(
                          g.unsettledTotal > 0
                              ? _money.format(g.unsettledTotal)
                              : _money.format(0),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _SettlementBanner.open(
                      context,
                      group: g,
                      money: _money,
                    ),
                    icon: const Icon(Icons.handshake_outlined, size: 18),
                    label: const Text('Settle'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Chat receipts + settlement summaries
          Expanded(
            child: Builder(
              builder: (context) {
                final chat = <Object>[
                  ...g.expenses,
                  ...g.settlements,
                ]..sort((a, b) {
                    final da = a is SplitExpense
                        ? a.createdAt
                        : (a as SplitSettlementRecord).createdAt;
                    final db = b is SplitExpense
                        ? b.createdAt
                        : (b as SplitSettlementRecord).createdAt;
                    return da.compareTo(db);
                  });

                if (chat.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Text(
                        'No payments yet.\nEnter amount > Send > select who paid > submit.',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(color: AppColors.slate, height: 1.45),
                      ),
                    ),
                  );
                }

                // reverse: true → open on latest (bottom), WhatsApp-style.
                return ListView.builder(
                  controller: _scroll,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                  itemCount: chat.length,
                  itemBuilder: (context, i) {
                    final item = chat[chat.length - 1 - i];
                    if (item is SplitSettlementRecord) {
                      return _SettlementChatCard(
                        record: item,
                        money: _money,
                        group: g,
                      );
                    }
                    final e = item as SplitExpense;
                    return _ExpenseBubble(
                      expense: e,
                      money: _money,
                      group: g,
                      memberColorValue: g.members
                          .where((m) => m.id == e.paidById)
                          .map((m) => m.colorValue)
                          .firstOrNull,
                    );
                  },
                );
              },
            ),
          ),

          // Composer
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: AppColors.white,
              border: const Border(top: BorderSide(color: AppColors.border)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: _membersPanelOpen
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _MembersTickPanel(
                            members: g.members,
                            selectedIds: _memberTicks,
                            onToggle: (id) {
                              setState(() {
                                if (_memberTicks.contains(id)) {
                                  _memberTicks.remove(id);
                                } else {
                                  _memberTicks.add(id);
                                }
                              });
                            },
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]'),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Amount',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate.withValues(alpha: 0.7),
                          ),
                          prefixIcon: const Align(
                            widthFactor: 1,
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 2),
                              child: Text(
                                '\u20B9',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 34,
                            minHeight: 48,
                          ),
                          filled: true,
                          fillColor: AppColors.softBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: _membersPanelOpen
                          ? AppColors.teal
                          : AppColors.softSky,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _membersPanelOpen = !_membersPanelOpen;
                            if (_membersPanelOpen) {
                              // Default: all members checked
                              _memberTicks
                                ..clear()
                                ..addAll(g.members.map((m) => m.id));
                            }
                          });
                        },
                        child: SizedBox(
                          width: 44,
                          height: 48,
                          child: Icon(
                            _membersPanelOpen
                                ? Icons.keyboard_arrow_down_rounded
                                : Icons.groups_rounded,
                            color: _membersPanelOpen
                                ? Colors.white
                                : AppColors.ocean,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: Material(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(24),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: _sending ? null : _onSendPressed,
                          child: _sending
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'Note (dinner, cab...)',
                    filled: true,
                    fillColor: AppColors.softBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    isDense: true,
                    suffixIcon: IconButton(
                      tooltip: _remindAt == null
                          ? 'Set reminder'
                          : 'Reminder set',
                      onPressed: () async {
                        if (_remindAt != null) {
                          setState(() => _remindAt = null);
                          return;
                        }
                        await _pickReminder();
                      },
                      icon: Icon(
                        _remindAt == null
                            ? Icons.alarm_add_rounded
                            : Icons.alarm_on_rounded,
                        size: 20,
                        color: _remindAt == null
                            ? AppColors.slate
                            : AppColors.teal,
                      ),
                    ),
                  ),
                ),
                ),
                if (_remindAt != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
                    child: Text(
                      'Reminder · ${DateFormat('dd MMM, hh:mm a').format(_remindAt!)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MembersTickPanel extends StatelessWidget {
  final List<SplitMember> members;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  const _MembersTickPanel({
    required this.members,
    required this.selectedIds,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final checked = selectedIds.length;
    final media = MediaQuery.of(context);
    final maxH = (media.size.height -
            media.padding.top -
            media.padding.bottom -
            media.viewInsets.bottom -
            220)
        .clamp(180.0, media.size.height * 0.58);

    const headerH = 40.0;
    const rowH = 52.0;
    const listPadTop = 4.0;
    const listPadBottom = 16.0;
    final n = members.length;
    final listNeeded =
        n == 0 ? listPadBottom : n * rowH + listPadTop + listPadBottom;
    final contentH = headerH + listNeeded;
    final panelH = contentH > maxH ? maxH : contentH;
    final needsScroll = contentH > maxH;

    return SizedBox(
      height: panelH,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: headerH,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded,
                      size: 18, color: AppColors.ocean),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Members',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 0.2,
                        color: AppColors.ocean,
                      ),
                    ),
                  ),
                  Text(
                    '$checked selected',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: needsScroll
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
              itemCount: members.length,
              itemBuilder: (context, i) {
                final m = members[i];
                final on = selectedIds.contains(m.id);
                final label = m.id == 'you' ? '${m.name} (You)' : m.name;
                final initial =
                    m.name.isNotEmpty ? m.name[0].toUpperCase() : '?';

                return InkWell(
                  onTap: () => onToggle(m.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Color(
                            m.colorValue != 0
                                ? m.colorValue
                                : 0xFFE8F0F4,
                          ),
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color.lerp(
                                Color(m.colorValue != 0
                                    ? m.colorValue
                                    : 0xFFE8F0F4),
                                const Color(0xFF0D3B4C),
                                0.55,
                              )!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.ink,
                                ),
                              ),
                              if (m.phone.isNotEmpty)
                                Text(
                                  m.phone,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.slate,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: on ? AppColors.teal : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: on
                                  ? AppColors.teal
                                  : const Color(0xFFB0C0C8),
                              width: 1.5,
                            ),
                          ),
                          child: on
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementBanner {
  static Future<void> open(
    BuildContext context, {
    required SplitGroup group,
    required NumberFormat money,
  }) async {
    final store = SplitStore.instance;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.softBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final g = store.byId(group.id)!;
        final pending = g.pendingExpenses;
        final lines = g.settlementLines();
        final transfers = SettlementTransfer.fromNets(lines);
        final paidTotals = g.pendingPaidTotals();
        final maxPaid = paidTotals.isEmpty
            ? 1.0
            : paidTotals.map((p) => p.totalPaid).reduce((a, b) => a > b ? a : b);

        Color memberFill(String id) {
          final m = g.members.where((x) => x.id == id).firstOrNull;
          final v = m?.colorValue ?? 0;
          return Color(v != 0 ? v : 0xFFE8F0F4);
        }

        String initialOf(String name) =>
            name.isNotEmpty ? name[0].toUpperCase() : '?';

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          minChildSize: 0.55,
          maxChildSize: 0.96,
          builder: (context, scrollCtrl) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5D4DC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B6B85), Color(0xFF2A9AAB)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.handshake_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settle up',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              'Totals · balances · who pays whom',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.slate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    children: [
                      // Hero total card
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF134E63), Color(0xFF2A9AAB)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1B6B85)
                                  .withValues(alpha: 0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'PENDING TOTAL',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    money.format(g.unsettledTotal),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w300,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${pending.length} unsettled bill${pending.length == 1 ? '' : 's'}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (pending.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.check_circle_outline_rounded,
                                  size: 48, color: AppColors.teal),
                              SizedBox(height: 10),
                              Text(
                                'Nothing to settle',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'All bills are clear.',
                                style: TextStyle(color: AppColors.slate),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        const SizedBox(height: 18),
                        _SettleGraphicSection(
                          icon: Icons.payments_rounded,
                          title: 'Who paid how much',
                          subtitle: 'Total paid by each member',
                          child: Column(
                            children: [
                              for (final p in paidTotals) ...[
                                _PaidBarRow(
                                  name: p.memberName,
                                  bills: p.billCount,
                                  amount: money.format(p.totalPaid),
                                  progress: (p.totalPaid / maxPaid).clamp(0, 1),
                                  fill: memberFill(p.memberId),
                                  initial: initialOf(p.memberName),
                                ),
                                if (p != paidTotals.last)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SettleGraphicSection(
                          icon: Icons.balance_rounded,
                          title: 'Balance per person',
                          subtitle: 'Net after equal shares',
                          child: Column(
                            children: [
                              for (final l in lines) ...[
                                _BalanceChipRow(
                                  name: l.memberName,
                                  amount: money.format(l.net.abs()),
                                  owes: l.net < 0,
                                  fill: memberFill(l.memberId),
                                  initial: initialOf(l.memberName),
                                ),
                                if (l != lines.last) const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _SettleGraphicSection(
                          icon: Icons.swap_horiz_rounded,
                          title: 'Who pays whom',
                          subtitle: 'Suggested transfers to settle',
                          child: transfers.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'All clear — no transfers needed.',
                                    style: TextStyle(color: AppColors.slate),
                                  ),
                                )
                              : Column(
                                  children: [
                                    for (final t in transfers) ...[
                                      _TransferGraphicCard(
                                        fromName: t.fromName,
                                        toName: t.toName,
                                        amount: money.format(t.amount),
                                        fromFill: memberFill(t.fromId),
                                        toFill: memberFill(t.toId),
                                      ),
                                      if (t != transfers.last)
                                        const SizedBox(height: 10),
                                    ],
                                  ],
                                ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (pending.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      10 + MediaQuery.paddingOf(ctx).bottom,
                    ),
                    child: SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () async {
                          final record = await store.settleAll(group.id);
                          if (!ctx.mounted) return;
                          Navigator.pop(ctx);
                          if (record != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Settled — full report posted in chat',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_rounded, size: 20),
                        label: const Text(
                          'Submit · Settle & post report',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SettleGraphicSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const _SettleGraphicSection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.softSky,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.ocean),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PaidBarRow extends StatelessWidget {
  final String name;
  final int bills;
  final String amount;
  final double progress;
  final Color fill;
  final String initial;

  const _PaidBarRow({
    required this.name,
    required this.bills,
    required this.amount,
    required this.progress,
    required this.fill,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color.lerp(fill, const Color(0xFF0D3B4C), 0.45)!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: fill,
          child: Text(
            initial,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.teal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.softBg,
                  color: accent.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$bills bill${bills == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 10, color: AppColors.slate),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BalanceChipRow extends StatelessWidget {
  final String name;
  final String amount;
  final bool owes;
  final Color fill;
  final String initial;

  const _BalanceChipRow({
    required this.name,
    required this.amount,
    required this.owes,
    required this.fill,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color.lerp(fill, const Color(0xFF0D3B4C), 0.45)!;
    final tone = owes ? AppColors.coral : AppColors.teal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: fill,
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                Text(
                  owes ? 'Should pay' : 'Should receive',
                  style: TextStyle(
                    fontSize: 11,
                    color: tone,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  owes
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 14,
                  color: tone,
                ),
                const SizedBox(width: 4),
                Text(
                  amount,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: tone,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferGraphicCard extends StatelessWidget {
  final String fromName;
  final String toName;
  final String amount;
  final Color fromFill;
  final Color toFill;

  const _TransferGraphicCard({
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.fromFill,
    required this.toFill,
  });

  @override
  Widget build(BuildContext context) {
    String initial(String n) => n.isNotEmpty ? n[0].toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7F0), Color(0xFFFFF0E6)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.coral.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _MiniPerson(name: fromName, fill: fromFill, initial: initial(fromName)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.coral,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: AppColors.coral.withValues(alpha: 0.45),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: AppColors.coral.withValues(alpha: 0.9),
                        ),
                        Expanded(
                          child: Container(
                            height: 2,
                            color: AppColors.coral.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'pays',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.slate,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniPerson(name: toName, fill: toFill, initial: initial(toName)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniPerson extends StatelessWidget {
  final String name;
  final Color fill;
  final String initial;

  const _MiniPerson({
    required this.name,
    required this.fill,
    required this.initial,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Color.lerp(fill, const Color(0xFF0D3B4C), 0.45)!;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: fill,
            child: Text(
              initial,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementChatCard extends StatelessWidget {
  final SplitSettlementRecord record;
  final NumberFormat money;
  final SplitGroup group;

  const _SettlementChatCard({
    required this.record,
    required this.money,
    required this.group,
  });

  Color _fillFor(String id) {
    final m = group.members.where((x) => x.id == id).firstOrNull;
    final v = m?.colorValue ?? 0;
    return Color(v != 0 ? v : 0xFFE8F0F4);
  }

  String _initial(String name) =>
      name.isNotEmpty ? name[0].toUpperCase() : '?';

  void _openFull(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.softBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final r = record;
        final maxPaid = r.paidTotals.isEmpty
            ? 1.0
            : r.paidTotals
                .map((p) => p.totalPaid)
                .reduce((a, b) => a > b ? a : b);
        final when =
            DateFormat('dd MMM yyyy · hh:mm a').format(r.createdAt);

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollCtrl) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC5D4DC),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Settlement details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        when,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF134E63), Color(0xFF2A9AAB)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL SETTLED',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              money.format(r.totalAmount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '${r.bills.length} bill${r.bills.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (r.paidTotals.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SettleGraphicSection(
                          icon: Icons.payments_rounded,
                          title: 'Who paid how much',
                          subtitle: 'Total paid by each member',
                          child: Column(
                            children: [
                              for (final p in r.paidTotals) ...[
                                _PaidBarRow(
                                  name: p.memberName,
                                  bills: p.billCount,
                                  amount: money.format(p.totalPaid),
                                  progress:
                                      (p.totalPaid / maxPaid).clamp(0, 1),
                                  fill: _fillFor(p.memberId),
                                  initial: _initial(p.memberName),
                                ),
                                if (p != r.paidTotals.last)
                                  const SizedBox(height: 12),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (r.nets.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SettleGraphicSection(
                          icon: Icons.balance_rounded,
                          title: 'Balance per person',
                          subtitle: 'Net after equal shares',
                          child: Column(
                            children: [
                              for (final l in r.nets) ...[
                                _BalanceChipRow(
                                  name: l.memberName,
                                  amount: money.format(l.net.abs()),
                                  owes: l.net < 0,
                                  fill: _fillFor(l.memberId),
                                  initial: _initial(l.memberName),
                                ),
                                if (l != r.nets.last)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (r.transfers.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _SettleGraphicSection(
                          icon: Icons.swap_horiz_rounded,
                          title: 'Who pays whom',
                          subtitle: 'Transfers to settle',
                          child: Column(
                            children: [
                              for (final t in r.transfers) ...[
                                _TransferGraphicCard(
                                  fromName: t.fromName,
                                  toName: t.toName,
                                  amount: money.format(t.amount),
                                  fromFill: _fillFor(t.fromId),
                                  toFill: _fillFor(t.toId),
                                ),
                                if (t != r.transfers.last)
                                  const SizedBox(height: 10),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = record;
    final when = DateFormat('dd MMM · hh:mm a').format(r.createdAt);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openFull(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10, left: 2, right: 2),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFB8E0D8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Total strip
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF134E63), Color(0xFF2A9AAB)],
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.handshake_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SETTLED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                when,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            money.format(r.totalAmount),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.05,
                            ),
                          ),
                          Text(
                            'Total · ${r.bills.length} bill${r.bills.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (r.transfers.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.swap_horiz_rounded,
                              size: 16, color: AppColors.ocean),
                          SizedBox(width: 6),
                          Text(
                            'Who pays whom',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...r.transfers.map(
                        (t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _ChatTransferTile(
                            fromName: t.fromName,
                            toName: t.toName,
                            amount: money.format(t.amount),
                            fromFill: _fillFor(t.fromId),
                            toFill: _fillFor(t.toId),
                          ),
                        ),
                      ),
                    ] else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.softMint,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 18, color: AppColors.teal),
                            SizedBox(width: 8),
                            Text(
                              'All clear — no transfers needed.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 2),
                    const Center(
                      child: Text(
                        'Tap for full details',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatTransferTile extends StatelessWidget {
  final String fromName;
  final String toName;
  final String amount;
  final Color fromFill;
  final Color toFill;

  const _ChatTransferTile({
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.fromFill,
    required this.toFill,
  });

  @override
  Widget build(BuildContext context) {
    String initial(String n) => n.isNotEmpty ? n[0].toUpperCase() : '?';
    Color accent(Color fill) =>
        Color.lerp(fill, const Color(0xFF0D3B4C), 0.45)!;

    Widget avatar(String name, Color fill) {
      return Column(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: fill,
            child: Text(
              initial(name),
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
                color: accent(fill),
              ),
            ),
          ),
          const SizedBox(height: 3),
          SizedBox(
            width: 58,
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7F0), Color(0xFFFFF0E6)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.coral.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          avatar(fromName, fromFill),
          Expanded(
            child: Column(
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.coral.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: AppColors.coral,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: AppColors.coral.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'pays',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.slate,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          avatar(toName, toFill),
        ],
      ),
    );
  }
}

// ignore: unused_element - old body removed below
class _PaidBySheet extends StatefulWidget {
  final double amount;
  final String note;
  final DateTime? remindAt;
  final List<SplitMember> members;
  final NumberFormat money;

  const _PaidBySheet({
    required this.amount,
    required this.note,
    required this.remindAt,
    required this.members,
    required this.money,
  });

  @override
  State<_PaidBySheet> createState() => _PaidBySheetState();
}

class _PaidBySheetState extends State<_PaidBySheet> {
  String? _selectedId;

  SplitMember? get _selected {
    if (_selectedId == null) return null;
    return widget.members.where((m) => m.id == _selectedId).firstOrNull;
  }

  static String _splitLabel(List<SplitMember> members) {
    final names = members.map((m) => m.name).toList();
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')} & ${names.last}';
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Who paid this amount?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            widget.members.length == 1
                ? 'Only this person is in the split.'
                : 'Showing only selected members — pick who paid. Split equally among ${widget.members.length}.',
            style: const TextStyle(
              color: AppColors.slate,
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.softBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.money.format(widget.amount),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  _selected == null
                      ? 'Paid by —'
                      : 'Paid by ${_selected!.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.ocean,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Split between ${_splitLabel(widget.members)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${widget.money.format(widget.amount / widget.members.length)} each',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate,
                  ),
                ),
                if (widget.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.note,
                      style: const TextStyle(color: AppColors.slate),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.36,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.members.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final m = widget.members[i];
                final on = _selectedId == m.id;
                return Material(
                  color: on ? const Color(0xFFE6F7F5) : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _selectedId = m.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: on ? AppColors.teal : AppColors.border,
                          width: on ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: on ? AppColors.teal : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: on
                                    ? AppColors.teal
                                    : const Color(0xFF9AADB8),
                                width: 1.5,
                              ),
                            ),
                            child: on
                                ? const Icon(Icons.check,
                                    size: 14, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(
                              m.colorValue != 0
                                  ? m.colorValue
                                  : 0xFFE8F0F4,
                            ),
                            child: Text(
                              m.name.isNotEmpty
                                  ? m.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color.lerp(
                                  Color(m.colorValue != 0
                                      ? m.colorValue
                                      : 0xFFE8F0F4),
                                  const Color(0xFF0D3B4C),
                                  0.55,
                                )!,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m.id == 'you' ? '${m.name} (You)' : m.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                                if (m.phone.isNotEmpty)
                                  Text(
                                    m.phone,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slate,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _selected == null
                  ? null
                  : () => Navigator.pop(context, _selected),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                disabledBackgroundColor: const Color(0xFFD7E4EA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _selected == null
                    ? 'Select who paid'
                    : 'Submit · Paid by ${_selected!.name}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

class _ExpenseBubble extends StatelessWidget {
  final SplitExpense expense;
  final NumberFormat money;
  final SplitGroup group;
  final int? memberColorValue;

  const _ExpenseBubble({
    required this.expense,
    required this.money,
    required this.group,
    this.memberColorValue,
  });

  void _openMemberPayments(BuildContext context, String memberId) {
    final member = group.members.where((m) => m.id == memberId).firstOrNull;
    if (member == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _MemberPaymentsSheet(
        group: group,
        member: member,
        money: money,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = expense;
    final time = DateFormat('hh:mm a').format(e.createdAt);
    final isMine = e.paidById == 'you';
    final bubbleW = MediaQuery.sizeOf(context).width * 0.70;
    final fill = Color(
      (memberColorValue != null && memberColorValue != 0)
          ? memberColorValue!
          : (isMine ? 0xFFD9F5EF : 0xFFF5F7F9),
    );
    final border = Color.lerp(fill, const Color(0xFF1A2B34), 0.18)!;
    final accent = Color.lerp(fill, const Color(0xFF0D3B4C), 0.55)!;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: bubbleW,
        margin: EdgeInsets.only(
          bottom: 6,
          left: isMine ? 12 : 8,
          right: isMine ? 8 : 12,
        ),
        decoration: BoxDecoration(
          color: e.settled ? const Color(0xFFF0F4F6) : fill,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMine ? 12 : 3),
            bottomRight: Radius.circular(isMine ? 3 : 12),
          ),
          border: Border.all(
            color: e.settled ? AppColors.border : border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    money.format(e.amount),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: e.settled ? AppColors.slate : AppColors.ink,
                      decoration:
                          e.settled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (e.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        e.note,
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Bottom: tap name → only that member's payments
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _openMemberPayments(context, e.paidById),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(isMine ? 12 : 3),
                  bottomRight: Radius.circular(isMine ? 3 : 12),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              isMine
                                  ? 'Paid by You'
                                  : 'Paid by ${e.paidByName}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: e.settled ? AppColors.slate : accent,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: accent.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                      if (e.splitAmongLabel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          e.splitAmongIds.length <= 1
                              ? 'For ${e.splitAmongLabel}'
                              : 'Split between ${e.splitAmongLabel}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate,
                            height: 1.25,
                          ),
                        ),
                        if (e.splitAmongIds.length > 1)
                          Text(
                            '${money.format(e.shareEach)} each',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.slate.withValues(alpha: 0.9),
                            ),
                          ),
                      ],
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (e.settled) ...[
                            Icon(
                              Icons.verified_rounded,
                              size: 12,
                              color: AppColors.teal.withValues(alpha: 0.9),
                            ),
                            const SizedBox(width: 3),
                          ],
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.slate,
                            ),
                          ),
                          if (e.remindAt != null) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.alarm,
                                size: 11, color: AppColors.teal),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows only this member's related payments — not the whole group.
class _MemberPaymentsSheet extends StatelessWidget {
  final SplitGroup group;
  final SplitMember member;
  final NumberFormat money;

  const _MemberPaymentsSheet({
    required this.group,
    required this.member,
    required this.money,
  });

  @override
  Widget build(BuildContext context) {
    final mine = group.expensesForMember(member.id);
    final paidByThem =
        mine.where((e) => e.paidById == member.id && !e.settled);
    final totalPaid =
        paidByThem.fold<double>(0, (a, e) => a + e.amount);
    final line = group.settlementForMember(member.id);
    final label = member.id == 'you' ? '${member.name} (You)' : member.name;
    final fill = Color(
      member.colorValue != 0 ? member.colorValue : 0xFFE8F0F4,
    );
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: fill,
                child: Text(
                  member.name.isNotEmpty
                      ? member.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: Color.lerp(fill, const Color(0xFF0D3B4C), 0.55)!,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'Only this member\'s payments',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: 'Paid (pending)',
                  value: money.format(totalPaid),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniStat(
                  title: line == null
                      ? 'Balance'
                      : (line.net < 0 ? 'Should pay' : 'Should receive'),
                  value: line == null
                      ? money.format(0)
                      : money.format(line.net.abs()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (mine.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No payments for this member.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.slate),
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.42,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: mine.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final e = mine[i];
                  final theyPaid = e.paidById == member.id;
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fill.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color.lerp(fill, const Color(0xFF1A2B34), 0.15)!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                money.format(e.amount),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text(
                              theyPaid ? 'Paid by them' : 'In their split',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: theyPaid
                                    ? AppColors.teal
                                    : AppColors.ocean,
                              ),
                            ),
                          ],
                        ),
                        if (e.note.isNotEmpty)
                          Text(
                            e.note,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.slate,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          e.splitAmongIds.length <= 1
                              ? 'For ${e.splitAmongLabel}'
                              : 'Split between ${e.splitAmongLabel}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.slate,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM · hh:mm a').format(e.createdAt),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.softBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.slate,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
