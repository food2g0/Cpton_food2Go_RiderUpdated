import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/home_screen.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Widgets/order_card.dart';
import 'history_screen.dart';
import 'order_in_progress.dart';

class EarningScreen extends StatefulWidget {
  final int? currentIndex;
  const EarningScreen({Key? key, this.currentIndex}) : super(key: key);

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  String riderUID = FirebaseAuth.instance.currentUser!.uid;

  // Getter function to fetch seller's name
  Future<String?> getSellerName(String sellerUID) async {
    try {
      DocumentSnapshot sellerSnapshot = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(sellerUID)
          .get();
      if (sellerSnapshot.exists) {
        return sellerSnapshot.get('sellersName');
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching seller name: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Earnings',
          style: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors().white,
          ),
        ),
        backgroundColor: AppColors().red,
      ),
      backgroundColor: AppColors().white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16), // Add some space at the top
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors().backgroundWhite,
                  borderRadius: BorderRadius.circular(10)
                ),
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Your Total Earnings',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors().black,
                        ),
                      ),

                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Total Earnings: Php ${double.parse(
                                previousRiderEarnings).toStringAsFixed(2)}',
                            // Display previous earnings without deduction
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: 12.sp,

                              color: AppColors().black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Add some spacing between the texts
                      Text(
                        'Current Earnings: Php ${(double.parse(
                            previousRiderEarnings) * 0.7).toStringAsFixed(2)}',
                        // Display current earnings after deduction
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          color: AppColors().green,
                        ),
                      ),
                      SizedBox(height: 10),
                      // Add some spacing between the texts
                      Text(
                        'Total Amount to Turnover: Php ${(double.parse(
                            previousRiderEarnings) - (double.parse(
                            previousRiderEarnings) * 0.7)).toStringAsFixed(2)}',
                        // Display total amount to turnover
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          color: AppColors().black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Divider(
            thickness: 2,
            color: AppColors().black,
          ),
          SizedBox(height: 20,),
          Text(
            'Recent Deliveries',
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors().black,
            ),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: SizedBox(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where("status", isEqualTo: "ended")
                    .where(
                    "riderUID", isEqualTo: riderUID) // Filter by rider ID
                    .orderBy("orderTime", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  // Extract orders data from snapshot
                  List<DocumentSnapshot> orders = snapshot.data!.docs;

                  // Build your UI using the orders data
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      // Extract order details from each document snapshot
                      dynamic productsData = orders[index].get("products");
                      List<Map<String, dynamic>> productList = [];
                      if (productsData != null && productsData is List) {
                        productList =
                        List<Map<String, dynamic>>.from(productsData);
                      }

                      print("Product List: $productList"); // Print productList

                      return FutureBuilder<String?>(
                        future: getSellerName(
                            orders[index].get('sellerUID')), // Fetch seller name
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          String? sellerName = snapshot.data;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                OrderCard(
                                  itemCount: productList.length,
                                  data: productList,
                                  orderID: orders[index].id,
                                  sellerName: sellerName ?? "",
                                  // Pass the seller's name
                                  paymentDetails: orders[index]
                                      .get("paymentDetails"),
                                  totalAmount: orders[index]
                                      .get("totalAmount")
                                      .toString(),
                                  cartItems: productList, // Pass the products list
                                ),
                                if (productList.length > 1)
                                  SizedBox(height: 10), // Adjust the height as needed
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

