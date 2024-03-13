import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/authentication/signup_page.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/error_dialog.dart';
import '../Widgets/loading_dialog.dart';
import '../global/global.dart';
import '../mainScreen/confirmation_Screen.dart';
import '../mainScreen/home_screen.dart';
import 'forgot_password.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  bool agreedToTerms = false;
  bool _obscureText = true; // Added

  formValidation() {
    if (emailcontroller.text.isNotEmpty && passwordcontroller.text.isNotEmpty) {
      //login
      loginNow();
    } else {
      showDialog(
        context: context,
        builder: (c) {
          return ErrorDialog(
            message: "Please write Email and password.",
          );
        },
      );
    }
  }

  loginNow() async {
    showDialog(
      context: context,
      builder: (c) {
        return LoadingDialog(message: "Checking credentials");
      },
    );

    User? currentUser;
    try {
      final authResult = await firebaseAuth.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );
      currentUser = authResult.user!;
    } catch (error) {
      Navigator.pop(context); // Close loading dialog
      if (error is FirebaseAuthException) {
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message ?? "An error occurred",
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "An error occurred: $error",
            );
          },
        );
      }
      return; // Exit the function if an error occurs
    }

    if (currentUser != null) {
      await currentUser.reload(); // Refresh user data
      if (currentUser.emailVerified) {
        readDataAndSetDataLocally(currentUser);
      } else {
        // User's email is not verified
        Navigator.pop(context); // Close loading dialog
        showDialog(
          context: context,
          builder: (c) {
            return AlertDialog(
              title: Text(
                'Email Not Verified',
                style: TextStyle(
                  color: AppColors().red,
                  fontFamily: "Poppins",
                ),
              ),
              content: const Text('Please verify your email to log in.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(c).pop(); // Close AlertDialog using its context
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("riders")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        String status = snapshot.data()!["status"];

        if (status == "disapproved") {
          // Status is disapproved, navigate to the ConfirmationScreen
          Navigator.pop(context);
          Route newRoute = MaterialPageRoute(
            builder: (c) => const ConfirmationScreen(),
          );
          Navigator.pushReplacement(context, newRoute);
        } else {
          // Status is not disapproved, proceed with login
          await sharedPreferences!.setString("uid", currentUser.uid);
          await sharedPreferences!.setString(
              "email", snapshot.data()!["riderEmail"]);
          await sharedPreferences!.setString(
              "name", snapshot.data()!["riderName"]);

          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => const HomeScreen()),
          );
        }
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => const AuthScreen()),
        );

        showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: "No record exists.",
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors().white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: w,
              height: h * 0.4,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/log.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  CustomTextField(
                    data: Icons.email,
                    hintText: "Enter your Email",
                    isObsecure: false,
                    controller: emailcontroller,
                  ),
                  CustomTextField(
                    data: Icons.password,
                    hintText: "Enter your Password",
                    isObsecure: _obscureText,
                    controller: passwordcontroller,
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),

                  Row(
                    children: [
                      Checkbox(
                        value: agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            agreedToTerms = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Terms and Conditions",
                                    style: TextStyle(
                                      fontFamily: "Poppins",
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "1. Always be careful in driving, the company is not responsible in any damage.",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                          "2. As per agreement, Riders are mandatory to give 30% of their income to food2go. ",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                          "3. Failure to give 30% will result to account termination",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                          "4. Make sure to remain your ratings high, making your ratings low will result to account suspension or termination",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                        SizedBox(height: 5,),
                                        Text(
                                          "5. Make sure to cary your driver license and registration of motorcycle everytime you have trip",
                                          style: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 8.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Close"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            "I agree to the Terms and Conditions",
                            style: TextStyle(
                              color: AppColors().black,
                              fontFamily: "Poppins",
                              fontSize: 8.sp,
                            ),
                          ),

                        ),

                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, top: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          text: "Forgot Password?",
                          style: TextStyle(
                            color: AppColors().black,
                            fontFamily: "Poppins",
                            fontSize: 12.sp,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.to(() => const ForgotPassword()),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: w * 0.08),
            ElevatedButton(
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors().red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              onPressed: () {
                if (!agreedToTerms) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Please agree to the Terms and Conditions to proceed."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  formValidation();
                }
              },
            ),
            SizedBox(height: w * 0.08),
            RichText(
              text: TextSpan(
                text: "Don\'t have an account?",
                style: TextStyle(
                  color: AppColors().black1,
                  fontSize: 15,
                  fontFamily: "Poppins",
                ),
                children: [
                  TextSpan(
                    text: "  Create!",
                    style: TextStyle(
                      color: AppColors().black,
                      fontFamily: "Poppins",
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.to(() => const SignUpPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
