import 'package:chatapp/models/messege_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // قد تحتاج لاستيراد هذا
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  // يفضل تحديد نوع المتغير ليكون الكود أكثر وضوحاً
  final Map<String, dynamic> otheruser;

  const ChatScreen({super.key, required this.otheruser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // الحصول على المستخدم الحالي
  final User? currentUser = FirebaseAuth.instance.currentUser;
  // إنشاء instance من خدمة الشات
  final MessageSevices _chatService = MessageSevices();
  TextEditingController messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:    Colors.blue,
     
        
        title: Text(
          widget.otheruser['email'].split('@')[0],
          style: TextStyle(fontSize: 30),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Expanded لجعل قائمة الرسائل تملأ المساحة المتاحة
          Expanded(
            // (التصحيح رقم 1 و 2)
            // استخدام StreamBuilder لجلب الرسائل وعرضها بشكل تفاعلي
            child: _buildMessageList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      fillColor: Colors.grey[500],
                      hintText: "  Type your message...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      final message = chatmessage(
                        text: messageController.text,
                        senderid: currentUser!.uid,
                        recieverid: widget.otheruser['uid'],
                        time: DateTime.now()
                            .toIso8601String(), // ✅ أدق في الترتيب
                      );
                      _chatService.sendMessage(message);
                      messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),

          // هنا يمكنك إضافة حقل إدخال الرسالة وزر الإرسال
          // _buildMessageInput(),
        ],
      ),
    );
  }

  void _showEditDialog(chatmessage message) {
    TextEditingController editController = TextEditingController(
      text: message.text,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تعديل الرسالة"),
          content: TextField(
            controller: editController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "اكتب الرسالة الجديدة",
            ),
          ),
          actions: [
            TextButton(
              child: Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("حفظ"),
              onPressed: () {
                Navigator.pop(context);
                final updatedMessage = chatmessage(
                  id: message.id,
                  text: editController.text,
                  senderid: message.senderid,
                  recieverid: message.recieverid,
                  time: DateTime.now().toIso8601String(), // تحديث الوقت
                );
                _chatService.editMessage(updatedMessage);
              },
            ),
          ],
        );
      },
    );
  }

  void _showMessageOptions(BuildContext context, chatmessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: Colors.blue),
                title: Text('تعديل الرسالة'),
                onTap: () {
                  Navigator.pop(context); // غلق الـ BottomSheet
                  _showEditDialog(message); // استدعاء دالة التعديل
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('حذف الرسالة'),
                onTap: () {
                  Navigator.pop(context);
                  _chatService.deletMessage(message); // استدعاء الحذف
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://i.pinimg.com/736x/be/0f/48/be0f48f042efd65fc79413a5e17aff5a.jpg',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: StreamBuilder(
        stream: _chatService.getmessages(
          currentUser!.uid,
          widget.otheruser['uid'],
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final String currentuserid = FirebaseAuth.instance.currentUser!.uid
              .toString();

          // تحويل الداتا لليست رسائل
          List<chatmessage> messages = snapshot.data!.docs
              .map(
                (doc) =>
                    chatmessage.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

          // ترتيب تنازلي (الأحدث → الأقدم)
          messages.sort((a, b) {
            final timeA = DateTime.tryParse(a.time ?? '') ?? DateTime(1970);
            final timeB = DateTime.tryParse(b.time ?? '') ?? DateTime(1970);
            return timeB.compareTo(timeA);
          });

          return ListView.builder(
            reverse: true, // ✅ يخلي آخر رسالة تبان تحت زي واتساب
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isSender = message.senderid == currentuserid;

              return Align(
                alignment: isSender
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: InkWell(
                  onLongPress: () {
                    if (FirebaseAuth.instance.currentUser!.uid ==
                        message.senderid) {
                      _showMessageOptions(context, message);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSender ? Colors.blue : Colors.grey[200],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isSender ? 12 : 0),
                        topRight: Radius.circular(isSender ? 0 : 12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${message.text}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message.time != null
                              ? () {
                                  try {
                                    final dt = DateTime.parse(message.time!);
                                    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}"; // ✅ الوقت مضبوط
                                  } catch (e) {
                                    return '';
                                  }
                                }()
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ويدجت خاصة ببناء قائمة الرسائل
}
