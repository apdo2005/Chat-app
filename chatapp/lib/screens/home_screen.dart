// تأكد من استيراد الملف
import 'package:chatapp/screens/Chat_screen.dart';
import 'package:chatapp/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/home_services.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final FirebaseAuth auth = FirebaseAuth.instance;
  final Authservice _authService = Authservice(); // إنشاء instance من السيرفس

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 232, 223, 248),
        actions: [
          IconButton(
            onPressed: () async {
              // يمكنك استخدام دالة تسجيل الخروج من السيرفس أيضاً
              await Authservice().signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>   SigninScreen()),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(image:   NetworkImage('https://i.pinimg.com/736x/be/0f/48/be0f48f042efd65fc79413a5e17aff5a.jpg'), fit: BoxFit.cover),
        ),
        child: StreamBuilder(
          stream: _authService.getUsersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('An error occurred!'));
            }
        
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No other users found.'));
            }
        
            return ListView(
              children: [
                for (DocumentSnapshot user in snapshot.data!.docs)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: InkWell(
                      highlightColor: const Color.fromARGB(255, 67, 86, 196),
                      borderRadius: BorderRadius.circular(10),
        
                      onTap: () {
                        print('uuuuuuuuuuuuuuuuuuuuuuuuuuuuu${user['uid']}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return ChatScreen(
                                otheruser: {
                                  ...user.data() as Map<String, dynamic>,
                                  'uid': user.id,
                                },
                              );
                            },
                          ),
                        );
                      },
                      child: Card(
                        color: const Color.fromARGB(255, 172, 176, 199),
                        child: ListTile(
                                            
                          shape: RoundedRectangleBorder(
                            
                          ),
                          title: Text(user['email'].split('@')[0]),
                          subtitle: Text(user['email']),
                          leading: const CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://i.pinimg.com/736x/23/2e/40/232e402f53165b75a08bccf83322ef1d.jpg',
                               
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
