import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/tools_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final _store = NotesStore.instance;

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

  Future<void> _openAfterSheet(VoidCallback action) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!mounted) return;
    action();
  }

  Future<void> _showNoteActions(TripNote note) async {
    await showModalBottomSheet<void>(
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
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  note.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Choose an action',
                  style: TextStyle(fontSize: 12, color: AppColors.slate),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.softSky,
                  child: Icon(Icons.edit_rounded, color: AppColors.ocean),
                ),
                title: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text('Edit in slider form'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAfterSheet(() => _showNoteForm(note: note));
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  backgroundColor: AppColors.softSky,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.coral,
                  ),
                ),
                title: const Text(
                  'Delete',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.coral,
                  ),
                ),
                subtitle: const Text('Remove this note'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openAfterSheet(() => _confirmDelete(note));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(TripNote note) async {
    final ok = await showModalBottomSheet<bool>(
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
              const SizedBox(height: 16),
              const Text(
                'Delete note?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                '“${note.title}” will be removed from this device.',
                style: const TextStyle(color: AppColors.slate, height: 1.35),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
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
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.coral,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    if (ok == true) await _store.delete(note.id);
  }

  Future<void> _showNoteForm({TripNote? note}) async {
    final isNew = note == null;
    final result = await showModalBottomSheet<_NoteFormResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => _NoteFormSheet(
        isNew: isNew,
        initialTitle: isNew || note.title == 'Untitled' ? '' : note.title,
        initialBody: note?.body ?? '',
        showDelete: !isNew,
      ),
    );

    if (!mounted || result == null) return;

    if (result.delete && note != null) {
      await _confirmDelete(note);
      return;
    }

    final title = result.title.trim().isEmpty ? 'Untitled' : result.title.trim();
    final body = result.body;
    if (isNew) {
      await _store.add(title: title, body: body);
    } else {
      note.title = title;
      note.body = body;
      await _store.update(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notes = _store.notes;
    final fmt = DateFormat('dd MMM · hh:mm a');

    return PageScaffold(
      title: 'Notes',
      subtitle: 'Trip thoughts & reminders',
      actions: [
        IconButton(
          tooltip: 'New note',
          onPressed: () => _showNoteForm(),
          icon: const Icon(Icons.add_rounded, color: AppColors.ocean),
        ),
      ],
      body: !_store.loaded
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sticky_note_2_outlined,
                          size: 48, color: AppColors.slate),
                      const SizedBox(height: 12),
                      const Text('No notes yet',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _showNoteForm(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add note'),
                        style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  itemCount: notes.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final n = notes[i];
                    return Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _showNoteActions(n),
                        onLongPress: () => _showNoteActions(n),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (n.body.trim().isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        n.body,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: AppColors.slate,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(
                                      fmt.format(n.updatedAt),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.slate,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Options',
                                onPressed: () => _showNoteActions(n),
                                icon: const Icon(
                                  Icons.more_vert_rounded,
                                  color: AppColors.slate,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _NoteFormResult {
  final String title;
  final String body;
  final bool delete;

  const _NoteFormResult({
    required this.title,
    required this.body,
    this.delete = false,
  });
}

class _NoteFormSheet extends StatefulWidget {
  final bool isNew;
  final String initialTitle;
  final String initialBody;
  final bool showDelete;

  const _NoteFormSheet({
    required this.isNew,
    required this.initialTitle,
    required this.initialBody,
    required this.showDelete,
  });

  @override
  State<_NoteFormSheet> createState() => _NoteFormSheetState();
}

class _NoteFormSheetState extends State<_NoteFormSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    _bodyCtrl = TextEditingController(text: widget.initialBody);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _cancel() => Navigator.of(context).pop();

  void _save() {
    Navigator.of(context).pop(
      _NoteFormResult(title: _titleCtrl.text, body: _bodyCtrl.text),
    );
  }

  void _delete() {
    Navigator.of(context).pop(
      const _NoteFormResult(title: '', body: '', delete: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final height = MediaQuery.sizeOf(context).height * 0.72;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 12 + bottom),
          child: Column(
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
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.isNew ? 'New note' : 'Edit note',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (widget.showDelete)
                    TextButton(
                      onPressed: _delete,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.coral,
                      ),
                      child: const Text('Delete'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      autofocus: widget.isNew,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        filled: true,
                        fillColor: AppColors.softBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _bodyCtrl,
                      minLines: 8,
                      maxLines: 16,
                      decoration: InputDecoration(
                        hintText: 'Write your note…',
                        filled: true,
                        fillColor: AppColors.softBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(14),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _cancel,
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
                        backgroundColor: AppColors.teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.isNew ? 'Save note' : 'Save changes',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
