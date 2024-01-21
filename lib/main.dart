import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:unibookwebpanel/view/login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDhUeQ29Sn-AI2iaBCXFE-yQ0YadEa1RJg",
        appId: "1:52215896362:web:2b7b39c14c0e2e80442653",
        messagingSenderId: "52215896362",
        projectId: "unibook-e3013"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const InitApp(),
    );
  }
}

class InitApp extends StatelessWidget {
  const InitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            return WebLoginPage();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
