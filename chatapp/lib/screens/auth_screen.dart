import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login.dart' show Login, SigninScreen;

class AuthScreen extends StatelessWidget {
  AuthScreen({super.key});

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // تحميل
          } else if (snapshot.hasData) {
            return HomeScreen(); // المستخدم مسجّل دخول
          }
          return const SigninScreen();
        },
      ),
    );
  }
}
