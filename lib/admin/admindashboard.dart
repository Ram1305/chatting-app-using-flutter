
import 'package:chatapp/admin/add%20members.dart';
import 'package:chatapp/admin/group.dart';

import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/material.dart';




import 'chatpage.dart';



class staff extends StatefulWidget {
  final String userId;

  staff({required this.userId});

  @override
  _EntryState createState() => _EntryState();
}

class _EntryState extends State<staff> {
  String? userName;
  String? userEmail;
  String? profilePictureURL;

  List<String> staffNames = [];

  Future<void> _fetchStaffNames() async {
    try {
      final staffCollection = await FirebaseFirestore.instance.collection('Staff').get();

      if (staffCollection.docs.isNotEmpty) {
        setState(() {
          staffNames = staffCollection.docs.map((doc) => doc['username'] as String).toList();
        });
      }
    } catch (e) {
      print('Error fetching staff names: $e');
    }
  }

  Future<void> _fetchVisitorDetails() async {
    try {
      final visitorDoc = await FirebaseFirestore.instance
          .collection('Staff')
          .doc(widget.userId)
          .get();

      if (visitorDoc.exists) {
        final data = visitorDoc.data() as Map<String, dynamic>;
        setState(() {
          userName = data['username'] as String?;
          userEmail = data['email'] as String?;
          profilePictureURL = data['profilePictureURL'] as String?;
        });
      }
    } catch (e) {
      print('Error fetching visitor details: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVisitorDetails();
    _fetchStaffNames(); // Call this to fetch staff names when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Admin Dashboard'),
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
                    builder: (context) =>CreateGroupPage(

                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
              ),
              child: Text('create group ',style:  TextStyle(color: Colors.white,)),

            ),



            SizedBox(
              height: 12,
            ),
            ElevatedButton(
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupListPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
              ),
              child: Text('View Group',style:  TextStyle(color: Colors.white,)),
            ),
            SizedBox(height: 10,),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>  AtPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blueAccent,
              ),
              child: Text('Chat screen',style:  TextStyle(color: Colors.white,)),
            ),
            SizedBox(
              height: 12,
            ),

            SizedBox(
              height: 12,
            ),
            Text(
              'Students list',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 12,
            ),
            Container(
              height: 200, // Adjust the height based on your design
              child: ListView.builder(
                itemCount: staffNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(staffNames[index]),
                    // Add onTap or other properties as needed
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}





