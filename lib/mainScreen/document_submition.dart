import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../push notification/push_notification_system.dart';
import 'confirmation_Screen.dart';

class DocumentSubmition extends StatefulWidget {
  const DocumentSubmition({Key? key}) : super(key: key);

  @override
  State<DocumentSubmition> createState() => _DocumentSubmitionState();
}

class _DocumentSubmitionState extends State<DocumentSubmition> {
  PlatformFile? driverLicenseFile;
  PlatformFile? registrationFile;
  UploadTask? uploadTask;



  Future selectDriverLicenseFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      driverLicenseFile = result.files.first;
    });
  }

  Future selectRegistrationFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      registrationFile = result.files.first;
    });
  }

  Future<void> uploadFiles() async {
    if (driverLicenseFile == null || registrationFile == null) return;

    final licensePath = 'RiderFiles/${driverLicenseFile!.name}';
    final registrationPath = 'RiderFiles/${registrationFile!.name}';

    final licenseFileContent = File(driverLicenseFile!.path!);
    final registrationFileContent = File(registrationFile!.path!);

    final licenseRef = FirebaseStorage.instance.ref().child(licensePath);
    final registrationRef =
    FirebaseStorage.instance.ref().child(registrationPath);

    setState(() {
      uploadTask = licenseRef.putFile(licenseFileContent);
      uploadTask = registrationRef.putFile(registrationFileContent);
    });

    await uploadTask!.whenComplete(() {});

    final licenseUrl = await licenseRef.getDownloadURL();
    final registrationUrl = await registrationRef.getDownloadURL();

    await saveDataToFirestore(
        FirebaseAuth.instance.currentUser!,
        licenseUrl: licenseUrl,
        registrationUrl: registrationUrl);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmationScreen()),
    );

    setState(() {
      driverLicenseFile = null;
      registrationFile = null;
    });
  }


  Future saveDataToFirestore(User currentUser,
      {String? registrationUrl, String? licenseUrl}) async {
    // Get the current user's UID
    String uid = currentUser.uid;

    // Construct the data to be saved to Firestore
    Map<String, dynamic> userData = {};
    if (registrationUrl != null) {
      userData["registrationUrl"] = registrationUrl;
    }
    if (licenseUrl != null) {
      userData["licenseUrl"] = licenseUrl;
    }

    try {
      // Save the data to Firestore
      await FirebaseFirestore.instance
          .collection("RidersDocs")
          .doc(uid)
          .set(userData, SetOptions(merge: true));

      // Save data locally if needed
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (registrationUrl != null) {
        await prefs.setString("registrationUrl", registrationUrl);
      }
      if (licenseUrl != null) {
        await prefs.setString("licenseUrl", licenseUrl);
      }
    } catch (error) {
      print("Error saving data to Firestore: $error");
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Document Submission",
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12.sp,
            color: AppColors().white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (driverLicenseFile != null)
              Expanded(
                child: Container(
                  color: AppColors().white,
                  child: Center(
                    child: Text(driverLicenseFile!.name),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: selectDriverLicenseFile,
              child: Text("Select Driver License File"),
            ),
            SizedBox(height: 20.h),
            if (registrationFile != null)
              Expanded(
                child: Container(
                  color: AppColors().white,
                  child: Center(
                    child: Text(registrationFile!.name),
                  ),
                ),
              ),
            ElevatedButton(
              onPressed: selectRegistrationFile,
              child: Text("Select Motorcycle Registration File"),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: uploadFiles,
              child: Text("Upload Files"),
            ),
          ],
        ),
      ),
    );
  }
}


