import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/split_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';
import '../../widgets/split_sheets.dart';
import 'split_group_screen.dart';

class SplitHomeScreen extends StatefulWidget {
  /// When true, content only (shell provides Tripo top + bottom nav).
  final bool embedded;

  const SplitHomeScreen({super.key, this.embedded = false});

  @override
  State<SplitHomeScreen> createState() => _SplitHomeScreenState();
}

class _SplitHomeScreenState extends State<SplitHomeScreen> {
  final _store = SplitStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load().then((_) {
      if (mounted) setState(() {});
    });
    _store.addListener(_onChange);
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onChange);
    super.dispose();
  }

  Future<void> _createGroup() async {
    final result = await showCreateGroupSheet(context);
    if (result == null) return;
    final groupName = result['group'] ?? '';
    final myName = result['name'] ?? '';
    final myPhone = result['phone'] ?? '';
    if (groupName.isEmpty || myName.isEmpty || myPhone.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Group name, your name and phone are required'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final g = await _store.createGroup(
      name: groupName,
      myName: myName,
      myPhone: myPhone,
    );
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SplitGroupScreen(groupId: g.id)),
    );
  }

  Future<String?> _promptText({
    required String title,
    required String hint,
    required String confirm,
    String initial = '',
  }) async {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: Text(confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete group?'),
        content: Text(
          '"$name" and all payment receipts inside will be removed. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await _store.deleteGroup(id);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _store.groups;
    final money = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final content = Stack(
      children: [
        if (!_store.loaded)
          const Center(child: CircularProgressIndicator())
        else if (groups.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.groups_rounded,
                    size: 56,
                    color: AppColors.teal.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create a group first',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter group name, your name & phone. Then add friends with name + phone, and split payments.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.slate, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _createGroup,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create group'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ocean,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              widget.embedded ? 96 : 28,
            ),
            itemCount: groups.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              if (i == groups.length) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: _createGroup,
                    icon: const Icon(Icons.group_add_rounded, size: 18),
                    label: const Text('Create group'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.ocean,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                );
              }
              final g = groups[i];
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SplitGroupScreen(groupId: g.id),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ocean.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: AppColors.softSky,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            g.name.isNotEmpty
                                ? g.name[0].toUpperCase()
                                : 'G',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.ocean,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                g.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${g.members.length} members · ${g.expenses.length} payments',
                                style: const TextStyle(
                                  color: AppColors.slate,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          money.format(g.totalSpent),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.teal,
                            fontSize: 14,
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'More',
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            size: 22,
                            color: AppColors.slate,
                          ),
                          onSelected: (value) async {
                            if (value == 'edit') {
                              final n = await _promptText(
                                title: 'Rename group',
                                hint: 'Group name',
                                confirm: 'Save',
                                initial: g.name,
                              );
                              if (n != null && n.trim().isNotEmpty) {
                                await _store.renameGroup(g.id, n);
                              }
                            } else if (value == 'delete') {
                              await _confirmDelete(g.id, g.name);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.edit_outlined, size: 20),
                                title: Text('Edit'),
                                dense: true,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: AppColors.coral,
                                ),
                                title: Text(
                                  'Delete',
                                  style: TextStyle(color: AppColors.coral),
                                ),
                                dense: true,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );

    if (widget.embedded) return content;

    return PageScaffold(
      title: 'Split',
      subtitle: 'Groups & shared expenses',
      body: content,
    );
  }
}
