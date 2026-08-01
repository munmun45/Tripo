import 'package:flutter/material.dart';

import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _store = TodoStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
    _store.load();
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<TodoGroup?> _createGroup() async {
    final draft = await showModalBottomSheet<_GroupDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => const _GroupFormSheet(),
    );
    if (!mounted || draft == null) return null;
    final g = await _store.addGroup(
      name: draft.name,
      colorValue: draft.colorValue,
      iconCode: draft.iconCode,
    );
    if (!mounted) return g;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('“${g.name}” created — add more groups anytime'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Open',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TodoGroupScreen(groupId: g.id),
              ),
            );
          },
        ),
      ),
    );
    return g;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _store.groups;
    final open = _store.totalOpen;

    return PageScaffold(
      title: 'Todo',
      subtitle: groups.isEmpty
          ? 'Create groups for your trip'
          : '${groups.length} groups · ${open == 0 ? 'all clear' : '$open open'}',
      actions: [
        IconButton(
          tooltip: 'New group',
          onPressed: _createGroup,
          icon: const Icon(Icons.create_new_folder_rounded,
              color: AppColors.ocean),
        ),
      ],
      body: !_store.loaded
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
              ? _EmptyGroups(onCreate: _createGroup)
              : Stack(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      children: [
                        ...groups.map(
                          (g) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _GroupCard(
                              group: g,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        TodoGroupScreen(groupId: g.id),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 20,
                      child: SafeArea(
                        top: false,
                        child: FilledButton.icon(
                          onPressed: _createGroup,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Create another group'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.ocean,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class TodoGroupScreen extends StatefulWidget {
  final String groupId;

  const TodoGroupScreen({super.key, required this.groupId});

  @override
  State<TodoGroupScreen> createState() => _TodoGroupScreenState();
}

class _TodoGroupScreenState extends State<TodoGroupScreen> {
  final _store = TodoStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_refresh);
    _store.load();
  }

  @override
  void dispose() {
    _store.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  TodoGroup? get _group => _store.groupById(widget.groupId);

  void _openGroup(String id) {
    if (id == widget.groupId) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TodoGroupScreen(groupId: id)),
    );
  }

  Future<void> _addOrEditTodo({TodoItem? item}) async {
    final group = _group;
    if (group == null) return;
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _TodoFormSheet(
        initialText: item?.text ?? '',
        accent: group.color,
        title: item == null ? 'New task' : 'Edit task',
      ),
    );
    if (!mounted || text == null || text.trim().isEmpty) return;
    if (item == null) {
      await _store.addTodo(group.id, text);
    } else {
      item.text = text;
      await _store.updateTodo(group.id, item);
    }
  }

  Future<void> _todoActions(TodoGroup group, TodoItem item) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottom = MediaQuery.paddingOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: group.color.withValues(alpha: 0.15),
                  child: Icon(Icons.edit_rounded, color: group.color),
                ),
                title: const Text('Edit',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.pop(ctx, 'edit'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.softSky,
                  child: Icon(Icons.delete_outline_rounded,
                      color: AppColors.coral),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.coral,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
          ),
        );
      },
    );
    if (!mounted || action == null) return;
    if (action == 'edit') {
      await Future<void>.delayed(const Duration(milliseconds: 40));
      if (mounted) await _addOrEditTodo(item: item);
    } else if (action == 'delete') {
      await _store.deleteTodo(group.id, item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    if (group == null) {
      return PageScaffold(
        title: 'Group',
        subtitle: 'Not found',
        body: const Center(child: Text('This group was removed.')),
      );
    }

    final open = group.openCount;
    final openItems = group.items.where((e) => !e.done).toList();
    final doneItems = group.items.where((e) => e.done).toList();
    final items = [...openItems, ...doneItems];

    return PageScaffold(
      title: group.name,
      subtitle: open == 0
          ? (group.total == 0 ? 'No tasks yet' : 'All done')
          : '$open remaining',
      body: Column(
        children: [
          if (_store.groups.length > 1)
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
                scrollDirection: Axis.horizontal,
                itemCount: _store.groups.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final g = _store.groups[i];
                  final selected = g.id == group.id;
                  return FilterChip(
                    selected: selected,
                    showCheckmark: false,
                    label: Text(g.name),
                    avatar: Icon(g.icon, size: 15, color: g.color),
                    selectedColor: AppColors.softSky,
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: selected ? AppColors.ocean : AppColors.border,
                    ),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.ocean : AppColors.ink,
                      fontSize: 12.5,
                    ),
                    onSelected: (_) => _openGroup(g.id),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: _GroupHero(group: group),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tasks',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                Text(
                  '${group.doneCount}/${group.total}',
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: AppColors.ocean,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _addOrEditTodo(),
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_rounded,
                              size: 18, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: AppColors.softSky,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.playlist_add_check_rounded,
                              size: 36,
                              color: group.color,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap Add to create your first task',
                            style: TextStyle(
                              color: AppColors.slate,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 28),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final t = items[i];
                      final showDoneLabel =
                          doneItems.isNotEmpty &&
                          i == openItems.length &&
                          openItems.isNotEmpty;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDoneLabel) ...[
                            const Padding(
                              padding: EdgeInsets.only(top: 6, bottom: 8),
                              child: Text(
                                'Completed',
                                style: TextStyle(
                                  color: AppColors.slate,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                          _TodoTile(
                            item: t,
                            accent: group.color,
                            onToggle: () =>
                                _store.toggleTodo(group.id, t.id),
                            onMore: () => _todoActions(group, t),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final TodoGroup group;
  final VoidCallback onTap;

  const _GroupCard({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = group.color;
    final pct = group.total == 0 ? null : (group.progress * 100).round();
    final subtitle = group.total == 0
        ? 'No tasks yet'
        : '${group.doneCount} of ${group.total} done';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.85),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.ocean.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(group.icon, color: c, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              group.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15.5,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                          if (pct != null)
                            Text(
                              '$pct%',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                                color: c,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.slate,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: group.progress,
                          minHeight: 4,
                          backgroundColor: AppColors.softSky,
                          valueColor: AlwaysStoppedAnimation(c),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.slate,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHero extends StatelessWidget {
  final TodoGroup group;

  const _GroupHero({required this.group});

  @override
  Widget build(BuildContext context) {
    final pct = group.total == 0 ? 0 : (group.progress * 100).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.softSky,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(group.icon, color: AppColors.ocean, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group.total == 0
                      ? 'Ready when you are'
                      : group.openCount == 0
                          ? 'Everything done'
                          : '${group.openCount} left to finish',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  group.total == 0
                      ? 'Add tasks to track progress'
                      : '${group.doneCount} of ${group.total} completed',
                  style: const TextStyle(
                    color: AppColors.slate,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: group.progress,
                    minHeight: 5,
                    backgroundColor: AppColors.softSky,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.ocean),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 46,
            height: 46,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: group.progress,
                  strokeWidth: 3.5,
                  backgroundColor: AppColors.softSky,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.ocean),
                ),
                Text(
                  group.total == 0 ? '—' : '$pct%',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ocean,
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

class _TodoTile extends StatelessWidget {
  final TodoItem item;
  final Color accent;
  final VoidCallback onToggle;
  final VoidCallback onMore;

  const _TodoTile({
    required this.item,
    required this.accent,
    required this.onToggle,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.done ? AppColors.softBg : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onToggle,
        onLongPress: onMore,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 6, 2, 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: item.done ? AppColors.ocean : AppColors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: item.done ? AppColors.ocean : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: item.done
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.2,
                    decoration:
                        item.done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.slate,
                    color: item.done ? AppColors.slate : AppColors.ink,
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                onPressed: onMore,
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  size: 20,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyGroups({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.softSky,
              ),
              child: const Icon(Icons.folder_special_rounded,
                  size: 40, color: AppColors.ocean),
            ),
            const SizedBox(height: 16),
            const Text(
              'Create your first group',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Packing list, day plans, bookings —\norganize todos by trip theme.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.slate, height: 1.4),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create group'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupDraft {
  final String name;
  final int colorValue;
  final int iconCode;

  const _GroupDraft({
    required this.name,
    required this.colorValue,
    required this.iconCode,
  });
}

class _GroupFormSheet extends StatefulWidget {
  final String? initialName;
  final int? initialColor;
  final int? initialIcon;
  final String title;

  const _GroupFormSheet({
    this.initialName,
    this.initialColor,
    this.initialIcon,
    this.title = 'New group',
  });

  @override
  State<_GroupFormSheet> createState() => _GroupFormSheetState();
}

class _GroupFormSheetState extends State<_GroupFormSheet> {
  late final TextEditingController _nameCtrl;
  late int _color;
  late int _icon;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialName ?? '');
    _color = widget.initialColor ?? TodoGroupStyle.colors.first;
    _icon = widget.initialIcon ?? TodoGroupStyle.icons.first.codePoint;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop(
      _GroupDraft(
        name: _nameCtrl.text.trim().isEmpty
            ? 'Untitled group'
            : _nameCtrl.text.trim(),
        colorValue: _color,
        iconCode: _icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final accent = Color(_color);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    IconData(_icon, fontFamily: 'MaterialIcons'),
                    color: accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Group name (e.g. Packing)',
                filled: true,
                fillColor: AppColors.softBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Color',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: TodoGroupStyle.colors.map((cv) {
                final selected = cv == _color;
                return GestureDetector(
                  onTap: () => setState(() => _color = cv),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Color(cv),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? AppColors.ink : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: selected
                        ? const Icon(Icons.check_rounded,
                            size: 18, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Icon',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TodoGroupStyle.icons.map((ic) {
                final selected = ic.codePoint == _icon;
                return GestureDetector(
                  onTap: () => setState(() => _icon = ic.codePoint),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: selected
                          ? accent.withValues(alpha: 0.18)
                          : AppColors.softBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? accent : AppColors.border,
                      ),
                    ),
                    child: Icon(
                      ic,
                      color: selected ? accent : AppColors.slate,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save group'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoFormSheet extends StatefulWidget {
  final String initialText;
  final Color accent;
  final String title;

  const _TodoFormSheet({
    required this.initialText,
    required this.accent,
    required this.title,
  });

  @override
  State<_TodoFormSheet> createState() => _TodoFormSheetState();
}

class _TodoFormSheetState extends State<_TodoFormSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    Navigator.of(context).pop(t);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottom),
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
            Text(
              widget.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'What needs to be done?',
                filled: true,
                fillColor: AppColors.softBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save task'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
