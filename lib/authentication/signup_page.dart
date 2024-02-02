import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/custom_text_field.dart';
import '../Widgets/error_dialog.dart';
import '../Widgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String riderAvatarUrl = "";
  String completeAddress = "";

  Future<void> _getImage() async {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    completeAddress =
        '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }

  Future<void> formValidation() async {
    if (imageXFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "Please select an image.",
            );
          });
    } else {
      if (passwordController.text == confirmPasswordController.text) {
        if (confirmPasswordController.text.isNotEmpty &&
            emailController.text.isNotEmpty &&
            nameController.text.isNotEmpty &&
            phoneController.text.isNotEmpty &&
            locationController.text.isNotEmpty) {
          //start uploading image
          showDialog(
              context: context,
              builder: (c) {
                return LoadingDialog(
                  message: "Registering Account",
                );
              });

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance
              .ref()
              .child("riders")
              .child(fileName);
          fStorage.UploadTask uploadTask =
              reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot =
              await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            riderAvatarUrl = url;

            //save info to firestore
            authenticateRiderAndSignUp();
          });
        } else {
          showDialog(
              context: context,
              builder: (c) {
                return ErrorDialog(
                  message:
                      "Please write the complete required info for Registration.",
                );
              });
        }
      } else {
        showDialog(
            context: context,
            builder: (c) {
              return ErrorDialog(
                message: "Password do not match.",
              );
            });
      }
    }
  }

  void authenticateRiderAndSignUp() async {
    User? currentUser;

    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async {
    FirebaseFirestore.instance.collection("riders").doc(currentUser.uid).set({
      "riderUID": currentUser.uid,
      "riderEmail": currentUser.email,
      "riderName": nameController.text.trim(),
      "riderAvatarUrl": riderAvatarUrl,
      "phone": phoneController.text.trim(),
      "address": completeAddress,
      "status": "disapproved",
      "earnings": 0.0,
      "lat": position?.latitude ?? 0.0, // Handle null position gracefully
      "lng": position?.longitude ?? 0.0,
    });

    //save data locally
    SharedPreferences? sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("uid", currentUser.uid);
    await sharedPreferences.setString("email", currentUser.email.toString());
    await sharedPreferences.setString("name", nameController.text.trim());
    await sharedPreferences.setString("riderAvatarUrl", riderAvatarUrl);
  }

  @override
  Widget build(BuildContext context) {
    List images = ["google.png", "facebook.png", "twitter.png"];

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors().white,
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Column(
          children: [
            Container(
              width: w,
              height: h * 0.4,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage("images/log.png"),
                fit: BoxFit.cover,
              )),
            ),
            Container(

              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: const Column(

                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
            Container(

              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _getImage();
                    },
                    child: Stack(
                      children: [
                        CustomTextField(
                          controller: null, // Since this field is just for display
                          data: Icons.add_photo_alternate,
                          hintText: "Select Image",
                          isObsecure: false, // Not relevant for this field
                          enabled: false, // Not editable
                        ),
                        if (imageXFile != null)
                          Positioned(
                            right: 8.0,
                            top: 8.0,
                            child: Image.file(
                              File(imageXFile!.path),
                              width: MediaQuery.of(context).size.width * 0.20,
                              height: MediaQuery.of(context).size.width * 0.20,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),



                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: nameController,
                          data: Icons.person,
                          hintText: "Enter your Full Name",
                          isObsecure: false,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: emailController,
                          data: Icons.email,
                          hintText: "Enter your Email",
                          isObsecure: false,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: phoneController,
                          data: Icons.phone_android,
                          hintText: "Enter your Phone Number",
                          isObsecure: false,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: passwordController,
                          data: Icons.password,
                          hintText: "Enter your Password",
                          isObsecure: true,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: confirmPasswordController,
                          data: Icons.password_rounded,
                          hintText: "Confirm your Password",
                          isObsecure: true,
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: locationController,
                          data: Icons.location_city,
                          hintText: "Enter your Address",
                          isObsecure: false,
                          enabled: true,
                        ),
                        const SizedBox(height: 20),
                        Container(
                            width: 400,
                            height: 40,
                            alignment: Alignment.center,
                            child: ElevatedButton.icon(
                              label:  Text(
                                "Get my Current Location",
                                style: TextStyle(color: AppColors().white,
                                  fontFamily: "Poppins",),
                              ),
                              icon:  Icon(
                                Icons.location_on,
                                color: AppColors().red,
                              ),
                              onPressed: () {
                                getCurrentLocation();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors().black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  )),
                            ))
                      ],
                    ),
                  ),
                  SizedBox(height: w * 0.08),
                  SizedBox(
                    width: 150, // Set the desired width
                    child: ElevatedButton(
                      onPressed: () {
                        formValidation();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors().black,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),



                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
