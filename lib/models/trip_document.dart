import 'dart:convert';

class TripDocument {
  final String id;
  String name;
  final String storedName;
  final String originalName;
  final String extension;
  final int sizeBytes;
  final DateTime createdAt;
  String? note;

  TripDocument({
    required this.id,
    required this.name,
    required this.storedName,
    required this.originalName,
    required this.extension,
    required this.sizeBytes,
    required this.createdAt,
    this.note,
  });

  String get sizeLabel {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get extUpper =>
      extension.isEmpty ? 'FILE' : extension.toUpperCase();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'storedName': storedName,
        'originalName': originalName,
        'extension': extension,
        'sizeBytes': sizeBytes,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory TripDocument.fromJson(Map<String, dynamic> j) => TripDocument(
        id: j['id'] as String,
        name: j['name'] as String? ?? j['originalName'] as String? ?? 'Document',
        storedName: j['storedName'] as String,
        originalName: j['originalName'] as String? ?? '',
        extension: j['extension'] as String? ?? '',
        sizeBytes: (j['sizeBytes'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
        note: j['note'] as String?,
      );

  static String encodeList(List<TripDocument> docs) =>
      jsonEncode(docs.map((d) => d.toJson()).toList());

  static List<TripDocument> decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => TripDocument.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
