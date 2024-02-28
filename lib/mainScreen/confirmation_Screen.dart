import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({Key? key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  Stream<DocumentSnapshot<Map<String, dynamic>>?>? _statusStream;

  @override
  void initState() {
    super.initState();
    _statusStream = FirebaseFirestore.instance
        .collection('RidersDocs')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Waiting for Confirmation",
          style: TextStyle(
              fontSize: 10.sp,
              color: AppColors().white,
              fontFamily: "Poppins"),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
        stream: _statusStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final data = snapshot.data?.data();
            if (data?['status'] == 'approved') {
              // Proceed to home screen
              return Scaffold(
                body: Center(
                  child: Text('You are confirmed! Proceed to home screen.'),
                ),
              );
            } else {
              return Center(
                child: Text(
                  "We're validating your account, please wait...",
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                      color: AppColors().black1),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
