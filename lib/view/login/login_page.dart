import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unibookwebpanel/view/admin_panel.dart';

class WebLoginPage extends StatefulWidget {
  @override
  _WebLoginPageState createState() => _WebLoginPageState();
}

class _WebLoginPageState extends State<WebLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> loginAdmin() async {
    // Call your authentication method here
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Check the user's role from Firestore
      final user = FirebaseAuth.instance.currentUser;
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .get();
      String userRole = userSnapshot['role'] ?? 'User';

      if (userRole == 'Admin') {
        print('Admin logged in:');
        // Navigate to the admin panel or perform necessary actions
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AdminPanel()),
        );
      } else {
        print('User is not an admin');
        // Handle non-admin users
      }
    } catch (e) {
      print('Error: $e');
      // Handle authentication errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: loginAdmin,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
