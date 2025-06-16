import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';

class SharedPrefsService {
  static const _cacheKeyPrefix = 'cached_journal_';

  /// Cache the given list of entries (for the current month + user).
  Future<void> cacheEntriesForMonth(
      String userId, List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = '$_cacheKeyPrefix${userId}_${now.year}_${now.month}';
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(key, jsonEncode(jsonList));
  }

  /// Load cached entries for the current month + user, or empty if none.
  Future<List<JournalEntry>> loadCachedEntriesForMonth(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key = '$_cacheKeyPrefix${userId}_${now.year}_${now.month}';
    final raw = prefs.getString(key);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw) as List;
      return decoded
          .map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      await prefs.remove(key);
      return [];
    }
  }
}
