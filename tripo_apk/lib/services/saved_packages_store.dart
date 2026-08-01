import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_packages.dart';
import '../models/travel_package.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'auth_service.dart';

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
    // If logged in, prefer cloud list.
    await syncFromServer();
  }

  Future<void> syncFromServer() async {
    if (!await AuthService.isLoggedIn()) return;
    try {
      final data = await ApiClient.instance.get(
        ApiConfig.savedPackages,
        auth: true,
      );
      final list = (data['package_ids'] as List?)
              ?.map((e) => '$e')
              .toList() ??
          const <String>[];
      _ids
        ..clear()
        ..addAll(list);
      await _persistLocal();
      notifyListeners();
    } catch (_) {
      // Keep local cache offline.
    }
  }

  Future<void> toggle(String id) async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      try {
        final data = await ApiClient.instance.post(
          ApiConfig.savedToggle,
          auth: true,
          body: {'package_id': id},
        );
        final saved = data['saved'] == true;
        if (saved) {
          _ids.add(id);
        } else {
          _ids.remove(id);
        }
        await _persistLocal();
        notifyListeners();
        return;
      } catch (_) {
        // Fall through to local toggle.
      }
    }

    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    await _persistLocal();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    if (!_ids.contains(id)) return;
    await toggle(id);
  }

  Future<void> _persistLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
  }
}
