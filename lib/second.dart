

import 'package:chatapp/admin/adminsignup.dart';
import 'package:chatapp/staff/staffsignup.dart';
import 'package:flutter/material.dart';

import 'admin/adminlogin.dart';
import 'staff/stafflogin.dart';


class Second extends StatefulWidget {
  @override
  _Second createState() => _Second();
}

class _Second extends State<Second> {
  String _greeting = '';

  @override
  void initState() {
    super.initState();
    _updateGreeting();
  }

  void _updateGreeting() {
    final currentTime = DateTime.now();
    final currentTimeOfDay = currentTime.hour;
    String newGreeting = '';

    if (currentTimeOfDay >= 0 && currentTimeOfDay < 12) {
      newGreeting = 'Good Morning ';
    } else if (currentTimeOfDay >= 12 && currentTimeOfDay < 17) {
      newGreeting = 'Good Afternoon ';
    } else {
      newGreeting = 'Good Evening';
    }

    setState(() {
      _greeting = newGreeting;
    });
  }

  void _Adminsignup() {
    // Navigate to the next page (replace `NextPage` with your actual page)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => adminSignupScreen()),
    );
  }
  void _LoginPressed() {
    // Navigate to the next page (replace `NextPage` with your actual page)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => staffLoginScreen()),
    );
  }

  void _SignupPressed() {
    // Navigate to the next page (replace `NextPage` with your actual page)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => staffSignupScreen()),
    );
  }
  void _Adminlogin() {
    // Navigate to the next page (replace `NextPage` with your actual page)
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => adminLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset(
                "assets/new.png",
                width: 500,
                height: 500,
              ),
            ),
            Text(
              _greeting,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20), // Adding some space between text and buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20), // Adding space below buttons
                Center(
                  child: ElevatedButton(
                    onPressed: _Adminsignup,
                    child: Text('Admin Signup',
                        style: TextStyle(
                          fontSize: 20,color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .redAccent, // Make button background transparent
                      elevation: 0, // Remove button elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.black), // Add border
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _Adminlogin,
                    child: Text('Admin Login',
                        style: TextStyle(
                          fontSize: 20,color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      primary: Colors
                          .blueAccent, // Make button background transparent
                      elevation: 0, // Remove button elevation
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.black), // Add border
                      ),
                    ),
                  ),

                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.blue, // Customize the button color
              ),
              child: ElevatedButton(
                onPressed: _SignupPressed,
                child: Text('User Sign Up',
                    style: TextStyle(
                      fontSize: 20,color: Colors.white,
                    )),
                style: ElevatedButton.styleFrom(
                  primary: Colors
                      .transparent, // Make button background transparent
                  elevation: 0, // Remove button elevation
                ),
              ),

            ),
            SizedBox(height: 20), // Increased space between buttons
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                color: Colors.blueAccent, // Customize the button color
              ),
              child: ElevatedButton(
                onPressed: _LoginPressed,
                child: Text(' User Login',
                    style: TextStyle(
                      fontSize: 20,color: Colors.white,
                    )),
                style: ElevatedButton.styleFrom(
                  primary: Colors
                      .transparent, // Make button background transparent
                  elevation: 0, // Remove button elevation
                ),
              ),
            ),
          ],
        ),



        ),

    );
  }
}
