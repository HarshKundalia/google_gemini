// ignore_for_file: prefer_const_constructors, depend_on_referenced_packages, unused_import

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_gemini/ImageChat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: 'AIzaSyCDtxGKgUwFlJnl02o6rgeT28SZDtDjTSE',
          appId: '1:65576867506:android:5dc71e5e9245717dee5bab',
          messagingSenderId: '65576867506',
          projectId: 'gemini-a57b6',
        ))
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Imagechat(),
    );
  }
}
