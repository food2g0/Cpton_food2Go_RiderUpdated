import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConfirmationScreen extends StatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold (appBar:
      AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Waiting for Confirmation",
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColors().white,
            fontFamily: "Poppins"
          ),
        ),
      ),
      body: Center(
        child: Text("Were validating your account please wait...",
        style: TextStyle(
          fontSize: 12.sp,
          fontFamily: "Poppins",
          color: AppColors().black1
        ),),
      ),
    );
  }
}
