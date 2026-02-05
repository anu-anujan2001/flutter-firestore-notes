import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference notes = FirebaseFirestore.instance.collection(
    'notes',
  );

  //add notes
  Future<void> addNotes(String data) {
    return notes.add({"note": data, "timestamp": Timestamp.now()});
  }

  //get notes
  Stream<QuerySnapshot> getNotes() {
    final noteStream = notes.orderBy('timestamp', descending: true).snapshots();
    return noteStream;
  }

  //detele notes
  Future<void> deleteNotes(String docId) {
    return notes.doc(docId).delete();
  }

  // update note
  Future<void> updateNote(String docId, String newText) {
    return notes.doc(docId).update({
      "note": newText,
      "updatedAt": Timestamp.now(),
    });
  }
}
