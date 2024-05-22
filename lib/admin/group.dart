import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateGroupPage extends StatefulWidget {
  @override
  _CreateGroupPageState createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _newGroupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Group'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Text('This is the Create Group Page'),
          ),
          SizedBox(height: 20),
          TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _createGroup();
            },
            child: Text('Create Group'),
          ),
          SizedBox(height: 20),
          Text(
            'List of Groups:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: _buildGroupList(),
          ),
        ],
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
          var groupId = group.id; // Get the document ID

          var groupWidget = ListTile(
            title: Text(groupName),
            subtitle: Text('Group ID: $groupId'),
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _editGroupName(groupName, groupId);
              },
            ),
          );
          groupWidgets.add(groupWidget);
        }

        return ListView(
          children: groupWidgets,
        );
      },
    );
  }

  void _createGroup() {
    String groupName = _groupNameController.text.trim();

    if (groupName.isNotEmpty) {
      _saveGroupNameToDatabase(groupName);
    } else {
      // Show an error message or handle empty group name
    }
  }

  void _saveGroupNameToDatabase(String groupName) {
    FirebaseFirestore.instance.collection('groups').add({
      'name': groupName,
      // Add more fields if needed
    }).then((value) {
      print('Group created successfully!');
      // Handle success or navigate to the next screen
    }).catchError((error) {
      print('Error creating group: $error');
      // Handle error
    });
  }

  void _editGroupName(String currentName, String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Group Name'),
          content: TextField(
            controller: _newGroupNameController,
            decoration: InputDecoration(
              labelText: 'New Group Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateGroupName(groupId);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _updateGroupName(String groupId) {
    String newGroupName = _newGroupNameController.text.trim();
    if (newGroupName.isNotEmpty) {
      FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'name': newGroupName,
      }).then((value) {
        print('Group name updated successfully!');
        // Handle success or update the UI accordingly
      }).catchError((error) {
        print('Error updating group name: $error');
        // Handle error
      });
    } else {
      // Show an error message or handle empty group name
    }
  }
}
