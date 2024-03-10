import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../authentication/auth_screen.dart'; // Import the ConfirmationScreen widget
import '../global/global.dart';
import '../mainScreen/confirmation_Screen.dart';
import '../mainScreen/home_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {



  startTimer() {
    Timer(const Duration(seconds: 4), () async {
      if (firebaseAuth.currentUser != null) {
        // Check if user is disapproved
        String? currentUserUID = firebaseAuth.currentUser!.uid;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('riders').doc(currentUserUID).get();
        String userStatus = userSnapshot.get('status');

        if (userStatus == 'disapproved') {
          // Navigate to confirmation screen if disapproved
          Navigator.push(context, MaterialPageRoute(builder: (c) => const ConfirmationScreen()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
        }
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: AppColors().black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  "images/appIcon.png",
                  width: 150, // Adjust the width as needed
                  height: 150, // Adjust the height as needed
                ),
              ),
              const SizedBox(height: 10,),
           Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Welcome Food2Go Rider",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors().white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
