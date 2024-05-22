import 'dart:io';
import 'package:chatapp/second.dart';
import 'package:chatapp/staff/chat.dart';


import 'package:chatapp/staff/profile.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

class Entry extends StatefulWidget {
  final String userId;

  Entry({required this.userId});

  @override
  _EntryState createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  String? userName;
  String? userEmail;
  String? profilePictureURL;
  Future<void> _fetchStaffDetails() async {
    try {
      final StaffDoc = await FirebaseFirestore.instance
          .collection('Staff')
          .doc(widget.userId)
          .get();

      if (StaffDoc.exists) {
        final data = StaffDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = data['username'] as String?;
          userEmail = data['email'] as String?;
          profilePictureURL = data['profilePictureURL'] as String?;
        });

        // Navigate to ViewTimetableScreen after fetching details

      }
    } catch (e) {
      print('Error fetching Staff details: $e');
    }
  }



  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imageName = '${widget.userId}_profile_image';
      final Reference storageReference =
      FirebaseStorage.instance.ref().child('profile_images/$imageName');

      UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('Staff')
          .doc(widget.userId)
          .update({'profilePictureURL': downloadURL});

      setState(() {
        profilePictureURL = downloadURL;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStaffDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('User Dashboard'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[




            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SChatPage(

                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
              ),
              child: Text('chat screen'),
            ),


            SizedBox(
              height: 12,
            ),
            // Show the profile picture
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userName ?? 'Unknown Vistors'),
              accountEmail: Text(userEmail ?? 'No Email'),
              currentAccountPicture: Stack(
                children: [
                  Container(
                    width: 250,
                    height: 200,
                    child: profilePictureURL != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(profilePictureURL!),
                    )
                        : Icon(
                      Icons.picture_in_picture,
                      size: 40,
                    ),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),


            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => staffProfilePage(
                      userId: widget.userId,
                    ),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Second()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacementNamed(context, '/login');
}
