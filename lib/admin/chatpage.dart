import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AtPage extends StatefulWidget {
  @override
  _AtPageState createState() => _AtPageState();
}

class _AtPageState extends State<AtPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Chat page'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white10, Colors.white54],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: _buildGroupList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('groups').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var groups = snapshot.data!.docs;

        List<Widget> groupWidgets = [];
        for (var group in groups) {
          var groupName = group['name'];
          var groupId = group.id;

          var groupWidget = ListTile(
            title: Text(groupName),
            subtitle: Text('Group ID: $groupId'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Chatn(groupId: groupId, groupName: groupName),
                ),
              );
            },
          );
          groupWidgets.add(groupWidget);
        }

        return ListView(
          children: groupWidgets,
        );
      },
    );
  }
}

class Chatn extends StatefulWidget {
  final String groupId;
  final String groupName;

  Chatn({required this.groupId, required this.groupName});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chatn> {
  TextEditingController _messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildChatMessages(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            var text = message['text'];
            var sender = message['sender'];
            var senderId = message['senderId'];
            var imageUrl = message['imageUrl'];

            // Custom BoxDecoration for chat messages
            BoxDecoration messageDecoration = BoxDecoration(
              color: senderId == FirebaseAuth.instance.currentUser?.uid
                  ? Colors.blueAccent
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(48.0),
            );

            return Container(
              margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              decoration: messageDecoration,
              child: ListTile(
                title: Text('$sender: $text'),
                trailing: (senderId == FirebaseAuth.instance.currentUser?.uid)
                    ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteMessage(message.id),
                )
                    : null,
                subtitle: imageUrl != null
                    ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                )
                    : null,
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.blue),
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(78.0), // Adjust the radius as needed
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.camera, color: Colors.blue),
            onPressed: _pickImageFromGallery,
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.green),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }


  Future<void> _pickImageFromGallery() async {
    final XFile? pickedImage = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);

      // Upload the image to Firestore
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('chat_images')
            .child('image_${Timestamp.now().millisecondsSinceEpoch}.jpg');

        UploadTask uploadTask = storageReference.putFile(imageFile);

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Now, send the message with the image URL
        FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .add({
          'text': '', // You can keep text empty or provide additional description
          'sender': user.displayName ?? user.email,
          'senderId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'imageUrl': imageUrl,
        }).then((value) {
          print('Image sent successfully!');
          _messageController.clear();
        }).catchError((error) {
          print('Error sending image: $error');
        });
      }
    }
  }

  void _sendMessage() {
    String text = _messageController.text.trim();

    if (text.isNotEmpty) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .add({
          'text': text,
          'sender': user.displayName ?? user.email,
          'senderId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
          'imageUrl': null, // Add the image URL if available
        }).then((value) {
          print('Message sent successfully!');
          _messageController.clear();
        }).catchError((error) {
          print('Error sending message: $error');
        });
      }
    } else {
      // Show an error message or handle empty message
    }
  }

  void _deleteMessage(String messageId) {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.groupId)
        .collection('messages')
        .doc(messageId)
        .delete()
        .then((value) {
      print('Message deleted successfully!');
    }).catchError((error) {
      print('Error deleting message: $error');
    });
  }
}
