
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/Colors.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  late User? _user;
  double totalEarnings = 0.0;
  double totalEarningsCashonDelivery = 0.0;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    fetchEarnings();
  }

  void fetchEarnings() async {
    try {
      // Get the sales document for the current user for the month of March
      DocumentSnapshot<Map<String, dynamic>> salesSnapshot = await FirebaseFirestore.instance
          .collection('riders')
          .doc(_user!.uid)
          .get();

      // Check if the document exists
      if (salesSnapshot.exists) {
        // Extract the sale value from the document and update the total earnings
        setState(() {
          totalEarnings = salesSnapshot['earningsGCash'] ?? 0.0;
          totalEarningsCashonDelivery = salesSnapshot['earningsCashOnDelivery'] ?? 0.0;
        });
      } else {
        // If the document doesn't exist, set earnings to 0
        setState(() {
          totalEarnings = 0.0;
          totalEarningsCashonDelivery = 0.0;
        });
      }
    } catch (error) {
      print('Error fetching earnings: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate 10% of total earnings
    double totalEarningsGcashAndCod = totalEarnings + totalEarningsCashonDelivery * 0.3;
    double tenPercent = (totalEarnings) * 0.7;
    // Calculate earnings after deducting 10%
    double earningsAfterDeduction = tenPercent;

    double turnOverAmount = totalEarningsCashonDelivery * 0.3;
    String formattedTurnOverAmount = turnOverAmount.toStringAsFixed(2);
    String formattedWithdraw = earningsAfterDeduction.toStringAsFixed(2);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Earnings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 180.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors().green.withOpacity(0.5), // Set the opacity here
                      borderRadius: BorderRadius.circular(10),

                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'G-cash',
                          style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/peso.png', // Path to your image asset
                              width: 12.w,
                              height: 12.h,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '$totalEarnings',
                              style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 20), // Add spacing between the first and second container
                SizedBox(
                  width: 170.w,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors().green.withOpacity(0.5), // Set the opacity here
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Cash on Delivery',
                          style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'images/peso.png', // Path to your image asset
                              width: 12.w,
                              height: 12.h,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '$totalEarningsCashonDelivery',
                              style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // Add spacing between the first row and the second container
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors().green.withOpacity(0.5), // Set the opacity here
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Total Earnings',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/peso.png', // Path to your image asset
                            width: 12.w,
                            height: 12.h,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '$totalEarningsGcashAndCod',
                            style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    color: AppColors().green.withOpacity(0.5), // Set the opacity here
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Withdraw',
                        style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/peso.png', // Path to your image asset
                            width: 12.w,
                            height: 12.h,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '$formattedWithdraw',
                            style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors().green.withOpacity(0.5), // Set the opacity here
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'Amount to turnover',
                        style: TextStyle(fontSize: 8.sp, fontFamily: "Poppins"),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'images/peso.png', // Path to your image asset
                            width: 12.w,
                            height: 12.h,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            '$formattedTurnOverAmount',
                            style: TextStyle(fontSize: 10.sp, fontFamily: "Poppins"),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            ElevatedButton(onPressed: (){
              requestTurnover();
            },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors().red,
                    minimumSize: Size(150, 60),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)
                    )
                ),
                child: Text("Turn Over", style: TextStyle(
                  color: AppColors().white,
                  fontFamily: "Poppins",
                  fontSize: 12.sp,

                ),))
          ],
        ),
      ),
    );
  }
  void requestTurnover() {
    TextEditingController referenceController = TextEditingController(); // Controller for reference number

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          physics: BouncingScrollPhysics(), // Allow the sheet to adjust its height according to its content
          reverse: true, // Scroll to the bottom of the sheet initially
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Ensure the bottom padding adjusts for the keyboard
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: referenceController, // Assign controller to reference number text field
                    decoration: InputDecoration(labelText: 'Reference Number'),
                    maxLength: 13,
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        'Gcash Number: ', // Display the Gcash number as text
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '09271679585 - Paolo Somido', // Replace 'Your Gcash Number Here' with the actual Gcash number
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontFamily: "Poppins"
                          // Add your styles here
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Save turnover details to Firestore with reference number
                      saveTurnoverRequest(referenceController.text);
                      Navigator.pop(context); // Close the modal
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors().red,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text('Submit',
                      style: TextStyle(color: AppColors().white,
                          fontFamily: "Poppins"),),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  void saveTurnoverRequest(String referenceNumber) {
    // Reset the value of totalEarningsCashonDelivery * 0.1 to 0
    double turnOverAmount = totalEarningsCashonDelivery * 0.1;

    // Save turnover details to Firestore
    FirebaseFirestore.instance.collection('turnover').doc(_user!.uid).set({
      'userId': _user!.uid,
      'status': 'sent',
      'amount': turnOverAmount, // Reset to 0
      'referenceNumber': referenceNumber,
      'timestamp': DateTime.now(),
    }).then((value) {
      // Reset the value of earningsCashOnDelivery to 0 in the database
      FirebaseFirestore.instance.collection('riders').doc(_user!.uid).update({
        'earningsCashOnDelivery': 0.0,
      }).then((_) {
        // Do something after updating the earningsCashOnDelivery field
      }).catchError((error) {
        print('Error updating earningsCashOnDelivery: $error');
      });
    }).catchError((error) {
      print('Error saving turnover request: $error');
    });
  }




}

