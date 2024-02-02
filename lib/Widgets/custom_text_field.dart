import 'package:flutter/material.dart';

import '../theme/Colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final String? hintText;
  bool? isObsecure = true;
  bool? enabled = true;

  CustomTextField({
    this.controller,
    this.data,
    this.hintText,
    this.isObsecure,
    this.enabled,
  });

  String? _validateemail(String? value) {
    if (value == null || value.isEmpty) {
      return "Full Name is required";
    } else if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
        .hasMatch(value)) {
      return "Please enter a valid Full Name";
    }
    return null; // Input is valid
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: AppColors().black),
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.all(7),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        obscureText: isObsecure!,
        validator: _validateemail,
        cursorColor: Theme.of(context).primaryColor,
        style: TextStyle( // Set the font family here
          fontFamily: "Poppins",
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            data,
            color: AppColors().red,
          ),
          hintText: hintText,
        ),
      ),
    );
  }
}
