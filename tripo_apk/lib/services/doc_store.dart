import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/trip_document.dart';

class DocStore extends ChangeNotifier {
  static const _key = 'tripo_docs_v1';
  static final DocStore instance = DocStore._();
  DocStore._();

  final List<TripDocument> _docs = [];
  bool _loaded = false;
  Directory? _dir;

  List<TripDocument> get docs => List.unmodifiable(_docs);
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _docs
        ..clear()
        ..addAll(TripDocument.decodeList(prefs.getString(_key)));
      _docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _dir = await _docsDirectory();
    } catch (_) {
      // Still mark loaded so UI is not stuck on spinner.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<Directory> _docsDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'tripo_docs'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<Directory> get directory async {
    _dir ??= await _docsDirectory();
    return _dir!;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, TripDocument.encodeList(_docs));
    notifyListeners();
  }

  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();

  File fileFor(TripDocument doc) {
    final dir = _dir;
    if (dir == null) {
      throw StateError('DocStore not loaded');
    }
    return File(p.join(dir.path, doc.storedName));
  }

  Future<List<TripDocument>> pickAndAdd() async {
    await load();
    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        withData: false,
        type: FileType.custom,
        allowedExtensions: const [
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'jpg',
          'jpeg',
          'png',
          'webp',
          'heic',
          'csv',
          'zip',
        ],
      );
    } on MissingPluginException {
      // Hot-reload can leave plugins unregistered — surface a clear message.
      throw StateError(
        'File picker needs a full app restart. Stop the app and run again.',
      );
    } catch (e) {
      if (e is StateError) rethrow;
      try {
        result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          withData: false,
        );
      } on MissingPluginException {
        throw StateError(
          'File picker needs a full app restart. Stop the app and run again.',
        );
      }
    }
    if (result == null || result.files.isEmpty) return const [];

    final dir = await directory;
    final added = <TripDocument>[];

    for (final f in result.files) {
      final path = f.path;
      if (path == null || path.isEmpty) continue;
      final source = File(path);
      if (!await source.exists()) continue;

      final id = _uid();
      final ext = (f.extension ?? p.extension(f.name).replaceFirst('.', ''))
          .toLowerCase();
      final stored = '$id${ext.isEmpty ? '' : '.$ext'}';
      final dest = File(p.join(dir.path, stored));
      await source.copy(dest.path);

      final size = f.size > 0 ? f.size : await dest.length();
      final baseName = f.name.trim().isEmpty ? 'Document' : f.name.trim();
      final display = ext.isEmpty
          ? baseName
          : baseName.toLowerCase().endsWith('.$ext')
              ? baseName.substring(0, baseName.length - ext.length - 1)
              : baseName;

      final doc = TripDocument(
        id: id,
        name: display,
        storedName: stored,
        originalName: baseName,
        extension: ext,
        sizeBytes: size,
        createdAt: DateTime.now(),
      );
      _docs.insert(0, doc);
      added.add(doc);
    }

    if (added.isNotEmpty) await _persist();
    return added;
  }

  Future<void> rename(String id, String name) async {
    final doc = _docs.where((d) => d.id == id).firstOrNull;
    if (doc == null || name.trim().isEmpty) return;
    doc.name = name.trim();
    await _persist();
  }

  Future<void> setNote(String id, String? note) async {
    final doc = _docs.where((d) => d.id == id).firstOrNull;
    if (doc == null) return;
    doc.note = note?.trim().isEmpty == true ? null : note?.trim();
    await _persist();
  }

  Future<void> delete(String id) async {
    final i = _docs.indexWhere((d) => d.id == id);
    if (i < 0) return;
    final doc = _docs.removeAt(i);
    try {
      final file = fileFor(doc);
      if (await file.exists()) await file.delete();
    } catch (_) {}
    await _persist();
  }
}
