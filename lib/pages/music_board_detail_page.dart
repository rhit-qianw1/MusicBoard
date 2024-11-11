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
              onPressed: () {
                MusicBoardDocumentManager().deleteMusicItem(docId);
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

  Color _getGenreColor(String genre) {
    switch (genre) {
      case 'Classic':
        return Colors.deepPurpleAccent.withOpacity(0.2);
      case 'Popular':
        return Colors.orangeAccent.withOpacity(0.2);
      case 'Country':
        return Colors.lightBlueAccent.withOpacity(0.2);
      case 'Electronic':
        return Colors.greenAccent.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
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
                Center(
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: musicItem.imageUrl.isNotEmpty
                          ? Image.network(musicItem.imageUrl, fit: BoxFit.cover)
                          : Center(child: Text('No Image')),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Music Name: ${musicItem.name}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Artist Name: ${musicItem.artist}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[700]),
                ),
                Divider(height: 30, thickness: 1),
                Text(
                  'Genre',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getGenreColor(musicItem.genre),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    musicItem.genre,
                    style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
                  ),
                ),
                Divider(height: 30, thickness: 1),
                Text(
                  'Description',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  musicItem.description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
