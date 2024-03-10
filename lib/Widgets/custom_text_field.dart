import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/Colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final Widget? suffixIcon; // Updated to accept Widget
  final String? hintText;
  final bool? isObsecure;
  final bool? enabled;
  final TextInputType? keyboardType;

  CustomTextField({
    this.controller,
    this.data,
    this.suffixIcon,
    this.hintText,
    this.isObsecure,
    this.enabled,
    this.keyboardType,
  });

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Full Name is required";
    }
    return null; // Input is valid
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter>? inputFormatters;
    if (keyboardType == TextInputType.text) {
      inputFormatters = [
        FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z ]+$')),
      ];
    }

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
        validator: _validateName,
        cursorColor: Theme.of(context).primaryColor,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
          fontFamily: "Poppins",
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            data,
            color: AppColors().red,
          ),
          suffixIcon: suffixIcon, // Use suffixIcon if provided
          hintText: hintText,
        ),
      ),
    );
  }
}
