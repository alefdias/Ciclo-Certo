import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DiaryEntry {
  final String id;
  final DateTime date;
  final String? mood;
  final List<String> symptoms;
  final String text;

  DiaryEntry({
    required this.id,
    required this.date,
    this.mood,
    this.symptoms = const [],
    required this.text,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'date': date.toIso8601String(),
    'mood': mood,
    'symptoms': symptoms,
    'text': text,
  };

  factory DiaryEntry.fromMap(Map<String, dynamic> map) => DiaryEntry(
    id: map['id'] as String? ?? '',
    date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
    mood: map['mood'] as String?,
    symptoms:
        (map['symptoms'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [],
    text: map['text'] as String? ?? '',
  );
}

class DiaryService {
  DiaryService._();
  static final DiaryService instance = DiaryService._();

  static const String _storageKey = 'velix_diary_entries_v1';
  final _controller = StreamController<List<DiaryEntry>>.broadcast();

  Stream<List<DiaryEntry>> get entriesStream => _controller.stream;

  Future<List<DiaryEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final entries =
          list
              .map(
                (item) =>
                    DiaryEntry.fromMap(Map<String, dynamic>.from(item as Map)),
              )
              .toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      return entries;
    } catch (_) {
      return [];
    }
  }

  Future<void> addEntry(DiaryEntry entry) async {
    final entries = await getEntries();
    entries.insert(0, entry);
    await _save(entries);
  }

  Future<void> saveRemoteEntries(List<dynamic> remoteList) async {
    try {
      final entries =
          remoteList
              .map(
                (item) =>
                    DiaryEntry.fromMap(Map<String, dynamic>.from(item as Map)),
              )
              .toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      await _save(entries);
    } catch (_) {}
  }

  Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await _save(entries);
  }

  Future<void> _save(List<DiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, raw);
    _controller.add(entries);
  }
}
