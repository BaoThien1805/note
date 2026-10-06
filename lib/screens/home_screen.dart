import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/note_service.dart';
import 'note_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NoteService noteService = NoteService();

  List<Note> notes = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadNotes();
  }

  Future<void> loadNotes() async {
    final data = await noteService.getNotes();

    data.sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    setState(() {
      notes = data;
      isLoading = false;
    });
  }

  Future<void> saveNotes() async {
    await noteService.saveNotes(notes);
  }

  Future<void> addNote() async {
    final Note? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoteFormScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        notes.insert(0, result);
      });

      await saveNotes();
    }
  }

  Future<void> editNote(Note note, int index) async {
    final Note? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteFormScreen(
          note: note,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        notes[index] = result;
      });

      await saveNotes();
    }
  }

  Future<bool> confirmDelete() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa ghi chú này không?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> deleteNote(int index) async {
    setState(() {
      notes.removeAt(index);
    });

    await saveNotes();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa ghi chú'),
      ),
    );
  }

  String formatDate(DateTime date) {
    String twoDigits(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '${twoDigits(date.hour)}:${twoDigits(date.minute)} '
        '${twoDigits(date.day)}/${twoDigits(date.month)}/${date.year}';
  }

  String shortContent(String content) {
    if (content.isEmpty) {
      return 'Không có nội dung';
    }

    if (content.length > 80) {
      return '${content.substring(0, 80)}...';
    }

    return content;
  }

  Widget buildNoteItem(Note note, int index) {
    return Dismissible(
      key: Key(note.id),

      background: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      confirmDismiss: (direction) async {
        return await confirmDelete();
      },

      onDismissed: (direction) {
        deleteNote(index);
      },

      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        elevation: 2,
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),

          leading: const CircleAvatar(
            child: Icon(Icons.note),
          ),

          title: Text(
            note.title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shortContent(note.content),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      formatDate(note.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
          ),

          onTap: () {
            editNote(note, index);
          },

          onLongPress: () async {
            final confirm = await confirmDelete();

            if (confirm) {
              await deleteNote(index);
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Ghi chú cá nhân',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '2324801030103 - Nguyen Hoang Bao Thien',
              style: TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : notes.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'Chưa có ghi chú nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Nhấn nút + để thêm ghi chú',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return buildNoteItem(
            notes[index],
            index,
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        tooltip: 'Thêm ghi chú',
        child: const Icon(Icons.add),
      ),
    );
  }
}