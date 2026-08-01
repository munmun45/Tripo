import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_packages.dart';
import '../models/travel_package.dart';

class SavedPackagesStore extends ChangeNotifier {
  static const _key = 'tripo_saved_packages_v1';
  static final SavedPackagesStore instance = SavedPackagesStore._();
  SavedPackagesStore._();

  final Set<String> _ids = {};
  bool _loaded = false;
  bool _openSavedOnly = false;

  bool get loaded => _loaded;
  int get count => _ids.length;
  Set<String> get ids => Set.unmodifiable(_ids);

  List<TravelPackage> get packages => DummyPackages.all
      .where((p) => _ids.contains(p.id))
      .toList(growable: false);

  bool isSaved(String id) => _ids.contains(id);

  /// Ask Trips tab to open in “saved only” mode (e.g. from Tools).
  void requestShowSavedOnly() {
    _openSavedOnly = true;
    notifyListeners();
  }

  bool consumeShowSavedOnly() {
    if (!_openSavedOnly) return false;
    _openSavedOnly = false;
    return true;
  }

  Future<void> load() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_key) ?? const <String>[];
      _ids
        ..clear()
        ..addAll(list);
    } catch (_) {
      // Keep empty set.
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> toggle(String id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    await _persist();
  }

  Future<void> remove(String id) async {
    if (!_ids.remove(id)) return;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
    notifyListeners();
  }
}
