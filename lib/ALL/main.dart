import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/scheduler.dart';
import '../firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MusicBoardApp());
}

class MusicBoardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Board',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: AuthGate(),
    );
  }
}

// AuthGate，用于根据用户状态显示登录或主界面
class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return MusicBoardListPage();
        }
        return LoginPage();
      },
    );
  }
}

// LoginPage，用户登录和注册页面
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to login. Please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to register. Please try again.")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: Text("Login"),
                      ),
                      ElevatedButton(
                        onPressed: _register,
                        child: Text("Register"),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

// 数据类 MusicItem，用于存储音乐项的详细信息
class MusicItem {
  final String name;
  final String artist;
  final String genre;
  final String imageUrl;
  final String description;
  final String creatorId;

  MusicItem({
    required this.name,
    required this.artist,
    required this.genre,
    required this.imageUrl,
    required this.description,
    required this.creatorId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'artist': artist,
      'genre': genre,
      'imageUrl': imageUrl,
      'description': description,
      'creatorId': creatorId,
    };
  }

  static MusicItem fromMap(Map<String, dynamic> map) {
    return MusicItem(
      name: map['name'] ?? '',
      artist: map['artist'] ?? '',
      genre: map['genre'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      creatorId: map['creatorId'] ?? '',
    );
  }
}

// Firebase 数据库管理类，用于添加、更新和删除音乐项
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

// MusicBoardListPage，显示音乐项的网格视图
class MusicBoardListPage extends StatefulWidget {
  @override
  _MusicBoardListPageState createState() => _MusicBoardListPageState();
}

class _MusicBoardListPageState extends State<MusicBoardListPage> {
  bool _showOnlyMine = false;
  String _selectedGenre = 'All';

  final List<String> genres = [
    'All',
    'Classic',
    'Popular',
    'Country',
    'Electronic'
  ];

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
          child: Container(
            color: Colors.white,
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              itemCount: genres.length,
              itemBuilder: (context, index) {
                final genre = genres[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: _selectedGenre == genre,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGenre = genre;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 80, // 设置较小的高度
              color: Theme.of(context).colorScheme.inversePrimary,
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
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final musicItems = snapshot.data!.docs
              .map((doc) =>
                  MusicItem.fromMap(doc.data() as Map<String, dynamic>))
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
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Text('Image Error'));
                                },
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Center(child: Text('No Image')),
                    ),
                    SizedBox(height: 8),
                    Text(
                      musicItem.name,
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

// MusicBoardDetailPage，用于显示单个音乐项的详细信息
class MusicBoardDetailPage extends StatelessWidget {
  final String docId;

  MusicBoardDetailPage({required this.docId});

  void _showEditDialog(BuildContext context, MusicItem musicItem) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicBoardFormDialog(
          musicItem: musicItem,
          onSubmit: (updatedItem) async {
            await MusicBoardDocumentManager()
                .updateMusicItem(docId, updatedItem);
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
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.pop(context); // 返回列表页面
                });
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
            stream: FirebaseFirestore.instance
                .collection('musicBoard')
                .doc(docId)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data == null)
                return SizedBox.shrink();
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
        stream: FirebaseFirestore.instance
            .collection('musicBoard')
            .doc(docId)
            .snapshots(),
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

// MusicBoardFormDialog，添加和编辑音乐项的表单
class MusicBoardFormDialog extends StatefulWidget {
  final MusicItem? musicItem;
  final Future<void> Function(MusicItem) onSubmit;

  MusicBoardFormDialog({this.musicItem, required this.onSubmit});

  @override
  _MusicBoardFormDialogState createState() => _MusicBoardFormDialogState();
}

class _MusicBoardFormDialogState extends State<MusicBoardFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String artist;
  late String genre;
  late String imageUrl;
  late String description;
  String? creatorId;
  bool _isSubmitting = false;
  final List<String> genres = ['Classic', 'Popular', 'Country', 'Electronic'];

  @override
  void initState() {
    super.initState();
    name = widget.musicItem?.name ?? '';
    artist = widget.musicItem?.artist ?? '';
    genre = widget.musicItem?.genre ?? genres.first;
    imageUrl = widget.musicItem?.imageUrl ?? '';
    description = widget.musicItem?.description ?? '';
    creatorId =
        widget.musicItem?.creatorId ?? FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final newItem = MusicItem(
      name: name,
      artist: artist,
      genre: genre,
      imageUrl: imageUrl,
      description: description,
      creatorId: creatorId!,
    );

    try {
      await widget.onSubmit(newItem);
      Navigator.pop(context);
    } catch (e) {
      print("Error submitting data: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.musicItem == null ? 'Create Music Item' : 'Edit Music Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextFormField(
                initialValue: artist,
                decoration: InputDecoration(labelText: 'Artist'),
                onChanged: (value) => artist = value,
              ),
              DropdownButtonFormField<String>(
                value: genre,
                decoration: InputDecoration(labelText: 'Genre'),
                items: genres.map((String genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      genre = value;
                    });
                  }
                },
              ),
              TextFormField(
                initialValue: imageUrl,
                decoration: InputDecoration(labelText: 'Image URL'),
                onChanged: (value) => imageUrl = value,
              ),
              TextFormField(
                initialValue: description,
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submitForm,
          child: _isSubmitting
              ? CircularProgressIndicator(strokeWidth: 2)
              : Text('Submit'),
        ),
      ],
    );
  }
}
