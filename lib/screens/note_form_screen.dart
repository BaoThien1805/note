import 'package:flutter/material.dart';

import '../models/note.dart';

class NoteFormScreen extends StatefulWidget {
  final Note? note;

  const NoteFormScreen({
    super.key,
    this.note,
  });

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      contentController.text = widget.note!.content;
    }
  }

  void saveNote() {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề'),
        ),
      );

      return;
    }

    Note note;

    if (isEditing) {
      note = Note(
        id: widget.note!.id,
        title: title,
        content: content,
        createdAt: widget.note!.createdAt,
      );
    } else {
      note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        createdAt: DateTime.now(),
      );
    }

    Navigator.pop(context, note);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Chỉnh sửa ghi chú' : 'Thêm ghi chú',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 150),
                    child: Icon(Icons.notes),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: saveNote,
                icon: const Icon(Icons.save),
                label: const Text(
                  'LƯU GHI CHÚ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}