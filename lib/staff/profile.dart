import 'dart:io';

import 'package:chatapp/staff/stafflogin.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';



class staffProfilePage extends StatefulWidget {
  final String userId;
  final Function()? onProfilePictureUpdated;

  staffProfilePage({required this.userId, this.onProfilePictureUpdated});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<staffProfilePage> {
  String? profilePictureURL;
  bool isUploading = false;
  User? _user;

  Future<void> _uploadProfilePicture(BuildContext context) async {
    setState(() {
      isUploading = true;
    });

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      try {
        String imageName = '${widget.userId}_profile_image';
        final Reference storageReference =
        FirebaseStorage.instance.ref().child('profile_images/$imageName');

        UploadTask uploadTask = storageReference.putFile(File(pickedFile.path));

        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        print('Download URL: $downloadURL');

        // Check if the document exists before updating
        var docSnapshot = await FirebaseFirestore.instance
            .collection('Staff')
            .doc(widget.userId)
            .get();
        if (docSnapshot.exists) {
          // Update the user's profile picture URL in Firestore
          await FirebaseFirestore.instance
              .collection('Staff')
              .doc(widget.userId)
              .update({'profilePictureURL': downloadURL});

          // Save the profile picture URL locally
          await _saveProfilePictureURL(downloadURL);

          if (widget.onProfilePictureUpdated != null) {
            widget.onProfilePictureUpdated!();
          }

          // Update the UI to display the new profile picture
          setState(() {
            profilePictureURL = downloadURL;
            isUploading = false;
          });

          // Notify the parent widget that the profile picture has been updated
          if (widget.onProfilePictureUpdated != null) {
            widget.onProfilePictureUpdated!();
          }

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Upload Successful'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('Document does not exist.');
          setState(() {
            isUploading = false;
          });
        }
      } catch (e) {
        print('Error uploading profile picture: $e');
        setState(() {
          isUploading = false;
        });
      }
    } else {
      setState(() {
        isUploading = false;
      });
    }
  }





  Future<void> _saveProfilePictureURL(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profilePictureURL', url);
  }

  Future<void> _loadProfilePictureURL() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final loadedURL = prefs.getString('profilePictureURL');
    setState(() {
      profilePictureURL = loadedURL;
    });
  }

  @override
  void initState() {
    super.initState();

    // Get the currently authenticated user
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _user = currentUser;
      });
    }

    _loadProfilePictureURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        title: Text('USER PROFILE'),
      ),
      body: Center(
        // Center widget added here
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 250,
                height: 200,
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('Staff')
                      .doc(widget.userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error.toString()}'),
                      );
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text('Document does not exist.'),
                      );
                    }

                    var userData = snapshot.data!.data();
                    if (userData == null || userData.isEmpty) {
                      return Center(
                        child: Text(
                            'Data is empty or not in the expected format.'),
                      );
                    }

                    return profilePictureURL != null
                        ? CircleAvatar(
                      backgroundImage: NetworkImage(
                        '$profilePictureURL?${DateTime.now().millisecondsSinceEpoch}',
                      ),
                    )
                        : Icon(
                      Icons.camera_alt,
                      size: 40,
                    );
                  },
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Welcome, ${_user?.displayName ?? 'User'}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Email: ${_user?.email ?? 'N/A'}', // Use _user?.email
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    // Display a loading indicator while uploading
                    setState(() {
                      isUploading = true;
                    });

                    String imageName = '${widget.userId}_profile_image';
                    final Reference storageReference = FirebaseStorage.instance
                        .ref()
                        .child('profile_images/$imageName');

                    UploadTask uploadTask =
                    storageReference.putFile(File(pickedFile.path));

                    TaskSnapshot taskSnapshot =
                    await uploadTask.whenComplete(() => null);
                    String downloadURL =
                    await taskSnapshot.ref.getDownloadURL();

                    // Update the user's profile picture URL in Firestore
                    await FirebaseFirestore.instance
                        .collection('Staff')
                        .doc(widget.userId)
                        .update({'profilePictureURL': downloadURL});

                    // Save the profile picture URL locally
                    await _saveProfilePictureURL(downloadURL);

                    // Update the UI to display the new profile picture
                    setState(() {
                      profilePictureURL = downloadURL;
                      isUploading = false;
                    });

                    // Notify the parent widget that the profile picture has been updated
                    if (widget.onProfilePictureUpdated != null) {
                      widget.onProfilePictureUpdated!();
                    }

                    // Show a success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Upload Successful'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent, // Background color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 3, // Shadow elevation
                ),
                child: Text('Upload Profile Picture'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => staffLoginScreen (
                          // Pass the userId
                        )),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueAccent, // Background color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // Rounded corners
                  ),
                  elevation: 3, // Shadow elevation
                ),
                child: Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
