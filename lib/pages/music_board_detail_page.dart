import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/music_item.dart';
import '../components/music_board_form_dialog.dart';
import '../managers/music_board_document_manager.dart';

class MusicBoardDetailPage extends StatelessWidget {
  final String docId;

  const MusicBoardDetailPage({super.key, required this.docId});

  void _showEditDialog(BuildContext context, MusicItem musicItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicBoardFormDialog(
          musicItem: musicItem,
          onSubmit: (updatedItem) async {
            await MusicBoardDocumentManager().updateMusicItem(docId, updatedItem);
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await MusicBoardDocumentManager().deleteMusicItem(docId);
                Navigator.pop(context); // 关闭确认弹窗
                Navigator.pop(context); // 返回列表页面
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Music Board'),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('musicBoard').doc(docId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null) return SizedBox.shrink();
              final data = snapshot.data!.data() as Map<String, dynamic>?;
              if (data == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
                return SizedBox.shrink();
              }
              final musicItem = MusicItem.fromMap(data);

              return Row(
                children: [
                  if (musicItem.creatorId == userId)
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showEditDialog(context, musicItem),
                    ),
                  if (musicItem.creatorId == userId)
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('musicBoard').doc(docId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data?.exists == false) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            });
            return SizedBox(); 
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          MusicItem musicItem = MusicItem.fromMap(data);

          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.grey,
                  child: musicItem.imageUrl.isNotEmpty
                      ? Image.network(musicItem.imageUrl, fit: BoxFit.cover)
                      : Center(child: Text('No Image')),
                ),
                SizedBox(height: 16),
                Text(musicItem.name, style: TextStyle(fontSize: 24)),
                Text(musicItem.artist, style: TextStyle(fontSize: 16)),
                SizedBox(height: 16),
                Text('Description: ${musicItem.description}'),
                SizedBox(height: 16),
                Text('Genre: ${musicItem.genre}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
