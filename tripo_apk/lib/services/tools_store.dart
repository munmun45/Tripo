import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripNote {
  final String id;
  String title;
  String body;
  DateTime updatedAt;

  TripNote({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TripNote.fromJson(Map<String, dynamic> j) => TripNote(
        id: j['id'] as String,
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class NotesStore extends ChangeNotifier {
  static const _key = 'tripo_notes_v1';
  static final NotesStore instance = NotesStore._();
  NotesStore._();

  final List<TripNote> _notes = [];
  bool _loaded = false;

  List<TripNote> get notes => List.unmodifiable(_notes);
  bool get loaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      _notes.clear();
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List;
        _notes.addAll(
          list.map((e) => TripNote.fromJson(Map<String, dynamic>.from(e as Map))),
        );
        _notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_notes.map((n) => n.toJson()).toList()),
    );
    notifyListeners();
  }

  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<TripNote> add({String title = '', String body = ''}) async {
    await load();
    final n = TripNote(
      id: _uid(),
      title: title.trim().isEmpty ? 'Untitled' : title.trim(),
      body: body,
      updatedAt: DateTime.now(),
    );
    _notes.insert(0, n);
    await _persist();
    return n;
  }

  Future<void> update(TripNote note) async {
    note.updatedAt = DateTime.now();
    if (note.title.trim().isEmpty) note.title = 'Untitled';
    await _persist();
  }

  Future<void> delete(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _persist();
  }
}

class TodoItem {
  final String id;
  String text;
  bool done;
  DateTime createdAt;

  TodoItem({
    required this.id,
    required this.text,
    this.done = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> j) => TodoItem(
        id: j['id'] as String,
        text: j['text'] as String? ?? '',
        done: j['done'] as bool? ?? false,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

class TodoGroup {
  final String id;
  String name;
  int colorValue;
  int iconCode;
  final List<TodoItem> items;
  DateTime updatedAt;

  TodoGroup({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
    List<TodoItem>? items,
    required this.updatedAt,
  }) : items = items ?? [];

  Color get color => Color(colorValue);
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  int get total => items.length;
  int get doneCount => items.where((e) => e.done).length;
  int get openCount => total - doneCount;
  double get progress => total == 0 ? 0 : doneCount / total;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'colorValue': colorValue,
        'iconCode': iconCode,
        'updatedAt': updatedAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory TodoGroup.fromJson(Map<String, dynamic> j) => TodoGroup(
        id: j['id'] as String,
        name: j['name'] as String? ?? 'Group',
        colorValue: j['colorValue'] as int? ?? 0xFF1A4F9C,
        iconCode: j['iconCode'] as int? ?? Icons.checklist_rounded.codePoint,
        updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ??
            DateTime.now(),
        items: (j['items'] as List? ?? [])
            .map((e) => TodoItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}

/// Preset accents for todo groups (blue-only).
class TodoGroupStyle {
  static const colors = <int>[
    0xFF1A4F9C, // ocean blue
    0xFF2B6BCF, // mid blue
    0xFF5B9EFF, // light blue
    0xFF0A1F45, // navy
  ];

  static const icons = <IconData>[
    Icons.checklist_rounded,
    Icons.flight_takeoff_rounded,
    Icons.luggage_rounded,
    Icons.hotel_rounded,
    Icons.map_rounded,
    Icons.restaurant_rounded,
    Icons.beach_access_rounded,
    Icons.camera_alt_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_bus_rounded,
  ];
}

class TodoStore extends ChangeNotifier {
  static const _key = 'tripo_todo_groups_v2';
  static const _legacyKey = 'tripo_todos_v1';
  static final TodoStore instance = TodoStore._();
  TodoStore._();

  final List<TodoGroup> _groups = [];
  bool _loaded = false;

  List<TodoGroup> get groups => List.unmodifiable(_groups);
  bool get loaded => _loaded;

  int get totalOpen =>
      _groups.fold(0, (sum, g) => sum + g.openCount);

  TodoGroup? groupById(String id) =>
      _groups.where((g) => g.id == id).firstOrNull;

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      _groups.clear();
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List;
        _groups.addAll(
          list.map(
            (e) => TodoGroup.fromJson(Map<String, dynamic>.from(e as Map)),
          ),
        );
        _groups.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      } else {
        await _migrateLegacy(prefs);
      }
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _migrateLegacy(SharedPreferences prefs) async {
    final raw = prefs.getString(_legacyKey);
    if (raw == null || raw.isEmpty) return;
    final list = jsonDecode(raw) as List;
    final items = list
        .map((e) => TodoItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (items.isEmpty) return;
    _groups.add(
      TodoGroup(
        id: _uid(),
        name: 'My tasks',
        colorValue: TodoGroupStyle.colors.first,
        iconCode: Icons.checklist_rounded.codePoint,
        items: items,
        updatedAt: DateTime.now(),
      ),
    );
    await _persist();
    await prefs.remove(_legacyKey);
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_groups.map((g) => g.toJson()).toList()),
    );
    notifyListeners();
  }

  String _uid() => DateTime.now().microsecondsSinceEpoch.toString();

  Future<TodoGroup> addGroup({
    required String name,
    required int colorValue,
    required int iconCode,
  }) async {
    await load();
    final g = TodoGroup(
      id: _uid(),
      name: name.trim().isEmpty ? 'Untitled group' : name.trim(),
      colorValue: colorValue,
      iconCode: iconCode,
      updatedAt: DateTime.now(),
    );
    _groups.insert(0, g);
    await _persist();
    return g;
  }

  Future<void> updateGroup(TodoGroup group) async {
    if (group.name.trim().isEmpty) group.name = 'Untitled group';
    group.updatedAt = DateTime.now();
    await _persist();
  }

  Future<void> deleteGroup(String id) async {
    _groups.removeWhere((g) => g.id == id);
    await _persist();
  }

  Future<void> addTodo(String groupId, String text) async {
    await load();
    final g = groupById(groupId);
    if (g == null) return;
    final t = text.trim();
    if (t.isEmpty) return;
    g.items.insert(
      0,
      TodoItem(id: _uid(), text: t, createdAt: DateTime.now()),
    );
    g.updatedAt = DateTime.now();
    await _persist();
  }

  Future<void> updateTodo(String groupId, TodoItem item) async {
    final g = groupById(groupId);
    if (g == null) return;
    if (item.text.trim().isEmpty) return;
    item.text = item.text.trim();
    g.updatedAt = DateTime.now();
    await _persist();
  }

  Future<void> toggleTodo(String groupId, String todoId) async {
    final g = groupById(groupId);
    if (g == null) return;
    final i = g.items.where((e) => e.id == todoId).firstOrNull;
    if (i == null) return;
    i.done = !i.done;
    g.updatedAt = DateTime.now();
    await _persist();
  }

  Future<void> deleteTodo(String groupId, String todoId) async {
    final g = groupById(groupId);
    if (g == null) return;
    g.items.removeWhere((e) => e.id == todoId);
    g.updatedAt = DateTime.now();
    await _persist();
  }

  Future<void> clearDone(String groupId) async {
    final g = groupById(groupId);
    if (g == null) return;
    g.items.removeWhere((e) => e.done);
    g.updatedAt = DateTime.now();
    await _persist();
  }
}
