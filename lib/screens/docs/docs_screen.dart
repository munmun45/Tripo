import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../models/trip_document.dart';
import '../../services/doc_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/page_scaffold.dart';

class DocsScreen extends StatefulWidget {
  final bool standalone;

  const DocsScreen({super.key, this.standalone = true});

  @override
  State<DocsScreen> createState() => _DocsScreenState();
}

class _DocsScreenState extends State<DocsScreen> {
  final _store = DocStore.instance;
  bool _busy = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _store.addListener(_onChange);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await _store.load();
    } catch (_) {
      // DocStore.load already marks loaded in finally.
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _store.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  List<TripDocument> get _filtered {
    final q = _query.trim().toLowerCase();
    final all = _store.docs;
    if (q.isEmpty) return all;
    return all
        .where(
          (d) =>
              d.name.toLowerCase().contains(q) ||
              d.originalName.toLowerCase().contains(q) ||
              d.extension.toLowerCase().contains(q) ||
              (d.note?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }

  Future<void> _upload() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final added = await _store.pickAndAdd();
      if (!mounted) return;
      if (added.isEmpty) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added.length == 1
                ? 'Saved “${added.first.name}”'
                : 'Saved ${added.length} documents',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      final friendly = msg.contains('full app restart') ||
              msg.contains('MissingPluginException') ||
              msg.contains('libdartjni')
          ? 'File picker needs a full restart. Stop the app completely, then run it again.'
          : 'Upload failed: $e';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendly),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _open(TripDocument doc) async {
    try {
      final file = _store.fileFor(doc);
      final result = await OpenFilex.open(file.path);
      if (!mounted) return;
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rename(TripDocument doc) async {
    final ctrl = TextEditingController(text: doc.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename document'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await _store.rename(doc.id, name);
  }

  Future<void> _delete(TripDocument doc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('“${doc.name}” will be removed from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await _store.delete(doc.id);
  }

  Color _extColor(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return const Color(0xFFE57373);
      case 'doc':
      case 'docx':
        return const Color(0xFF64B5F6);
      case 'xls':
      case 'xlsx':
      case 'csv':
        return const Color(0xFF81C784);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'heic':
        return const Color(0xFFFFB74D);
      default:
        return AppColors.teal;
    }
  }

  IconData _extIcon(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'doc':
      case 'docx':
        return Icons.description_rounded;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart_rounded;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'heic':
        return Icons.image_rounded;
      case 'zip':
        return Icons.folder_zip_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = _filtered;
    final dateFmt = DateFormat('dd MMM · hh:mm a');

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search documents',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.softBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _busy ? null : _upload,
                icon: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file_rounded, size: 18),
                label: const Text('Upload'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_store.docs.length} stored on this device',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        Expanded(
          child: !_store.loaded
              ? const Center(child: CircularProgressIndicator())
              : docs.isEmpty
                  ? _EmptyVault(onUpload: _busy ? null : _upload)
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        4,
                        16,
                        widget.standalone ? 28 : 96,
                      ),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final d = docs[i];
                        final color = _extColor(d.extension);
                        return Material(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _open(d),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _extIcon(d.extension),
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          d.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${d.extUpper} · ${d.sizeLabel} · ${dateFmt.format(d.createdAt)}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.slate,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (v) {
                                      if (v == 'open') _open(d);
                                      if (v == 'rename') _rename(d);
                                      if (v == 'delete') _delete(d);
                                    },
                                    itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: 'open',
                                        child: Text('Open'),
                                      ),
                                      PopupMenuItem(
                                        value: 'rename',
                                        child: Text('Rename'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
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
        ),
      ],
    );

    if (!widget.standalone) return body;

    return PageScaffold(
      title: 'Docs',
      subtitle: 'Upload & store travel files',
      body: body,
    );
  }
}

class _EmptyVault extends StatelessWidget {
  final VoidCallback? onUpload;

  const _EmptyVault({this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.softSky,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 36,
                color: AppColors.ocean,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No documents yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upload tickets, visas, hotel vouchers,\nand keep them offline on this phone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.slate,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Upload documents'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.teal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
