// ignore_for_file: dead_code

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Authservice {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _usercollection = _db.collection('users');
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'createdAt': Timestamp.now(),
        });
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // دالة لجلب stream لكل المستخدمين من Firestore
  Stream<QuerySnapshot> getUsersStream() {
    final String? currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) {
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .where(
          'uid',
          isNotEqualTo: currentUserId,
        )
        .snapshots();
  }

  
  Future<void> signOut() async {
    try {
      await auth.signOut();
      print("User signed out successfully.");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
