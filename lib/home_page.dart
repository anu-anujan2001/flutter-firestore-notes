import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crudflutter/service/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _noteController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future openEditBox(String docId, String oldText) async {
    _noteController.text = oldText;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Note"),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(labelText: 'Update note'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final text = _noteController.text.trim();
              if (text.isEmpty) return;

              await _firestoreService.updateNote(docId, text);
              _noteController.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  Future openNoteBox() async {
    _noteController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(labelText: 'Enter the note'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final text = _noteController.text.trim();
              if (text.isEmpty) return;

              await _firestoreService.addNotes(text);
              _noteController.clear();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getNotes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notes yet"));
          }

          final notes = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final doc = notes[index];
              final docId = doc.id;
              final data = doc.data() as Map<String, dynamic>;
              final noteText = data['note'] ?? "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(noteText),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () =>
                            openEditBox(docId, noteText.toString()),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestoreService.deleteNotes(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: openNoteBox,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
