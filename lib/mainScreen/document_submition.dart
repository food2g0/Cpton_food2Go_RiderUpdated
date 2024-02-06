
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

  PlatformFile? pickedFile;
  UploadTask? uploadTask;


  Future selectFile() async
  {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });

  }

  Future uploadFile() async
  {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');

    setState(() {
      uploadTask = null;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text("Document Submission",
        style: TextStyle(
          fontFamily: "Poppins",
          fontSize: 12.sp,
          color: AppColors().white
        ),),

      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (pickedFile != null)
              Expanded(child: Container(
                color: AppColors().white,
                child: Center(
                  child: Text(pickedFile!.name),
                ),
              )),
            ElevatedButton(onPressed: selectFile,
                child: Text("Select File")),
            SizedBox(height: 20.h,),
            ElevatedButton(onPressed: uploadFile,
                child: Text("upload File")),
            SizedBox(height: 30.h,),
            buildProgress(),
          ],
        ),
      ),
    );
  }

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents ,
      builder: (context, snapshot) {
        if (snapshot.hasData)
        {
          final data = snapshot.data!;
          double progress = data.bytesTransferred / data.totalBytes;

          return SizedBox(height: 50,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors().black1,
                color: AppColors().green,

              ),
              Center(
                child: Text(
                  '${(100 * progress).roundToDouble()}%',
                  style: TextStyle(
                    color: AppColors().white
                  ),
                ),
              )

            ],
          ),);
        }else{
          return SizedBox(height: 50.h,);
        }
      });


}
