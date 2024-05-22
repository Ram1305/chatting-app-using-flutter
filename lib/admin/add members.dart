import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupListPage extends StatefulWidget {
  @override
  _GroupListPageState createState() => _GroupListPageState();
}

class _GroupListPageState extends State<GroupListPage> {
  // Function to delete a group
  void deleteGroup(String groupId) {
    FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
    // You can also delete associated data or perform any additional logic based on your requirements
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blueAccent,
        title: Text('Group List'),
        actions: [],
      ),
      body: _buildGroupList(),
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

        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            var group = groups[index];
            var groupName = group['name'];
            var groupId = group.id;

            return Card(
              elevation: 2.0,
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(groupName),
                    Row(
                      children: [

                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Delete Group"),
                                  content: Text("Are you sure you want to delete this group?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Call the function to delete the group
                                        deleteGroup(groupId);
                                        Navigator.pop(context); // Close the dialog
                                      },
                                      child: Text("Delete"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                subtitle: Text('Group ID: $groupId'),
                onTap: () {
                  // You can add navigation or additional logic here if needed
                },
              ),
            );
          },
        );
      },
    );
  }
}

class AddMembersPage extends StatefulWidget {
  final String groupId;

  AddMembersPage({required this.groupId});

  @override
  _AddMembersPageState createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  List<String> selectedStaffMembers = [];

  // Function to add selected staff members to the group
  void addSelectedMembersToGroup() {
    FirebaseFirestore.instance.collection('groups').doc(widget.groupId).update({
      'members': FieldValue.arrayUnion(selectedStaffMembers),
    });
    // You can also update other data or perform any additional logic based on your requirements
  }

  Widget _buildStaffList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('Staff').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var staffMembers = snapshot.data!.docs;

        return ListView.builder(
          itemCount: staffMembers.length,
          itemBuilder: (context, index) {
            var staffMember = staffMembers[index];
            var staffName = staffMember['username'];

            return Card(
              elevation: 2.0,
              margin: EdgeInsets.all(8.0),
              child: CheckboxListTile(
                title: Text(staffName),
                value: selectedStaffMembers.contains(staffName),
                onChanged: (bool? value) {
                  setState(() {
                    if (value != null) {
                      if (value) {
                        selectedStaffMembers.add(staffName);
                      } else {
                        selectedStaffMembers.remove(staffName);
                      }
                    }
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Members'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // Call the function to add the selected staff members to the group
              addSelectedMembersToGroup();
              // Optionally, you can navigate back or perform other actions
            },
          ),
        ],
      ),
      body: _buildStaffList(),
    );
  }
}
