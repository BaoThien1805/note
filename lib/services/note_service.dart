import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note.dart';

class NoteService {
  static const String noteKey = 'notes';

  Future<List<Note>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final String? data = prefs.getString(noteKey);

    if (data == null || data.isEmpty) {
      return [];
    }

    final List<dynamic> jsonData = jsonDecode(data);

    return jsonData
        .map(
          (item) => Note.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();

    final data = notes.map((note) => note.toJson()).toList();

    await prefs.setString(
      noteKey,
      jsonEncode(data),
    );
  }
}