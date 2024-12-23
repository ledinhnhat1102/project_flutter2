import 'package:flutter/material.dart';
import '../models/note.dart';
import '../utils/database_helper.dart';
import 'note_detail.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note>? noteList;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = [];
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: getNoteListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => navigateToDetail(Note('', '', 2, ''), 'Add Note'),
        child: const Icon(Icons.add),
      ),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        Note note = noteList![index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: getPriorityColor(note.priority),
              child: getPriorityIcon(note.priority),
            ),
            title: Text(note.title),
            subtitle: Text(note.date),
            trailing: GestureDetector(
              child: const Icon(Icons.delete, color: Colors.grey),
              onTap: () => _delete(note),
            ),
            onTap: () => navigateToDetail(note, 'Edit Note'),
          ),
        );
      },
    );
  }

  Color getPriorityColor(int priority) => priority == 1 ? Colors.red : Colors.yellow;

  Icon getPriorityIcon(int priority) => priority == 1 ? const Icon(Icons.priority_high) : const Icon(Icons.low_priority);

  void _delete(Note note) async {
    int result = await databaseHelper.deleteNote(note.id!);
    if (result != 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note Deleted')));
      updateListView();
    }
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetail(note, title)),
    );
    if (result) updateListView();
  }

  void updateListView() async {
    List<Note> list = await databaseHelper.getNoteList();
    setState(() {
      noteList = list;
      count = list.length;
    });
  }
}
