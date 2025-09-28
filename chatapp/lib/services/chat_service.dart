import 'package:chatapp/models/messege_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class MessageSevices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> sendMessage(chatmessage message) async {
    final messageDoc = _firestore.collection('messages').doc();
    message.id = messageDoc.id;

    await messageDoc.set(message.toMap());
  }

  Stream<QuerySnapshot> getmessages(String currentuserid, String reciverid) {
    return _firestore
        .collection('messages')
        .where('senderid', whereIn: [currentuserid, reciverid])
        .where('recieverid', whereIn: [currentuserid, reciverid])
        //.orderBy('time', descending: false)
        .snapshots();
  }

  editMessage(chatmessage message) async {
    final messageDoc = _firestore.collection('messages').doc(message.id);
    if (message.senderid == _auth.currentUser!.uid) {
      await messageDoc.update(message.toMap());
    }
  }

  deletMessage(chatmessage message) async {
    final messageDoc = _firestore.collection('messages').doc(message.id);
    if (message.senderid == _auth.currentUser!.uid) {
      await messageDoc.delete();
    }
  }
}
