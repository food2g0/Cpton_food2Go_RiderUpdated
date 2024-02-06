import 'dart:io';

import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DocumentSubmition extends StatefulWidget {
  const DocumentSubmition({super.key});

  @override
  State<DocumentSubmition> createState() => _DocumentSubmitionState();
}

class _DocumentSubmitionState extends State<DocumentSubmition> {
  PlatformFile? driverLicenseFile;
  PlatformFile? registrationFile;
  UploadTask? driverLicenseUploadTask;
  UploadTask? registrationUploadTask;

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

  Future uploadDriverLicenseFile() async {
    await _uploadFile(driverLicenseFile, (snapshot) {
      driverLicenseUploadTask = null;
    });
  }

  Future uploadRegistrationFile() async {
    await _uploadFile(registrationFile, (snapshot) {
      registrationUploadTask = null;
    });
  }

  Future<void> _uploadFile(
      PlatformFile? file,
      void Function(TaskSnapshot) onComplete,
      ) async {
    if (file == null) return;

    final path = 'files/${file.name}';
    final fileContent = File(file.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      if (file == driverLicenseFile) {
        driverLicenseUploadTask = ref.putFile(fileContent);
      } else if (file == registrationFile) {
        registrationUploadTask = ref.putFile(fileContent);
      }
    });

    final snapshot = await (file == driverLicenseFile
        ? driverLicenseUploadTask!.whenComplete(() {})
        : registrationUploadTask!.whenComplete(() {}));

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    onComplete(snapshot);
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
            ElevatedButton(
              onPressed: uploadDriverLicenseFile,
              child: Text("Upload Driver License File"),
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
              onPressed: uploadRegistrationFile,
              child: Text("Upload Motorcycle Registration File"),
            ),
          ],
        ),
      ),
    );
  }
}
