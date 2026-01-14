import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages locally stored recent search terms.
class RecentSearchesStorage extends Notifier<List<String>> {
  static const _key = 'recent_searches';
  static const _maxItems = 12;

  @override
  List<String> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      try {
        final list = (jsonDecode(raw) as List).cast<String>();
        state = list.take(_maxItems).toList();
      } catch (_) {
        state = [];
      }
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(state));
  }

  /// Add a search term to the front of the list.
  /// Removes duplicates and keeps the list under [_maxItems].
  Future<void> addSearch(String term) async {
    final trimmed = term.trim();
    if (trimmed.isEmpty) return;

    final updated = [
      trimmed,
      ...state.where((s) => s.toLowerCase() != trimmed.toLowerCase()),
    ].take(_maxItems).toList();

    state = updated;
    await _saveToPrefs();
  }

  /// Remove a specific search term.
  Future<void> removeSearch(String term) async {
    state = state.where((s) => s != term).toList();
    await _saveToPrefs();
  }

  /// Clear all recent searches.
  Future<void> clearAll() async {
    state = [];
    await _saveToPrefs();
  }
}

final recentSearchesProvider = NotifierProvider<RecentSearchesStorage, List<String>>(
  RecentSearchesStorage.new,
);
