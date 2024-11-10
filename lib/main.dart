import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/auth_gate.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MusicBoardApp());
}

class MusicBoardApp extends StatelessWidget {
  const MusicBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Board',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const AuthGate(),
    );
  }
}
