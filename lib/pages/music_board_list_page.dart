import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/music_item.dart';
import '../managers/music_board_document_manager.dart';
import '../components/music_board_form_dialog.dart';
import '../components/genre_selector.dart';
import 'music_board_detail_page.dart';

class MusicBoardListPage extends StatefulWidget {
  const MusicBoardListPage({super.key});

  @override
  _MusicBoardListPageState createState() => _MusicBoardListPageState();
}

class _MusicBoardListPageState extends State<MusicBoardListPage> {
  bool _showOnlyMine = false;
  String _selectedGenre = 'All';

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicBoardFormDialog(
          onSubmit: (newItem) async {
            await MusicBoardDocumentManager().addMusicItem(newItem);
          },
        );
      },
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return (screenWidth / 150).floor();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Music Board'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: GenreSelector(
            selectedGenre: _selectedGenre,
            onGenreSelected: (genre) {
              setState(() {
                _selectedGenre = genre;
              });
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 80,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(Icons.list),
                    title: Text("Show All"),
                    onTap: () {
                      setState(() {
                        _showOnlyMine = false;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Show Only Mine"),
                    onTap: () {
                      setState(() {
                        _showOnlyMine = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('musicBoard').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final musicItems = snapshot.data!.docs
              .map((doc) => MusicItem.fromMap(doc.data() as Map<String, dynamic>))
              .where((item) =>
                  (!_showOnlyMine || item.creatorId == userId) &&
                  (_selectedGenre == 'All' || item.genre == _selectedGenre))
              .toList();

          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _calculateCrossAxisCount(context),
              childAspectRatio: 0.8,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: musicItems.length,
            itemBuilder: (context, index) {
              final musicItem = musicItems[index];
              final docId = snapshot.data!.docs[index].id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicBoardDetailPage(
                        docId: docId,
                      ),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: musicItem.imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                musicItem.imageUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(child: Text('No Image')),
                    ),
                    SizedBox(height: 8),
                    Text(
                      musicItem.name,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
