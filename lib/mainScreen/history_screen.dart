import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Widgets/order_card.dart';
import '../Widgets/progress_bar.dart';
import '../assisstantMethod/assistant_methods.dart';
import '../global/global.dart';
import '../theme/Colors.dart';
import 'earning_screen.dart';
import 'home_screen.dart';
import 'order_in_progress.dart';

class HistoryScreen extends StatefulWidget {
  final int? currentIndex;
  const HistoryScreen({super.key,  this.currentIndex});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    String riderUID = FirebaseAuth.instance.currentUser!.uid;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors().red,
          title: Text("History",
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: "Poppins",
            fontWeight: FontWeight.w700,
            color: AppColors().white,
          ),),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "rated")
              .where("riderUID", isEqualTo: riderUID) // Filter by rider ID
              .orderBy("orderTime", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
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

                return Column(
                  children: [
                    OrderCard(
                      itemCount: productList.length,
                      data: productList,
                      orderID: snapshot.data!.docs[index].id,
                      sellerName: "", // Pass the seller's name
                      paymentDetails:
                      snapshot.data!.docs[index].get("paymentDetails"),
                      totalAmount: snapshot.data!.docs[index].get("totalAmount").toString(),
                      cartItems: productList, // Pass the products list
                    ),
                    if (productList.length > 1)
                      SizedBox(height: 10), // Adjust the height as needed
                  ],
                );
              },
            );
          },
        ),

      ),
    );
  }
}
