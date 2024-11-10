import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/music_item.dart';

class MusicBoardDocumentManager {
  final CollectionReference _musicCollection =
      FirebaseFirestore.instance.collection('musicBoard');

  Future<void> addMusicItem(MusicItem musicItem) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await _musicCollection.add({
        ...musicItem.toMap(),
        'creatorId': userId,
      });
    }
  }

  Future<void> updateMusicItem(String docId, MusicItem musicItem) async {
    await _musicCollection.doc(docId).update(musicItem.toMap());
  }

  Future<void> deleteMusicItem(String docId) async {
    await _musicCollection.doc(docId).delete();
  }
}
