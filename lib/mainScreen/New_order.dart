import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Widgets/order_card.dart';
import '../global/global.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {

  bool isRiderAvailable = false; // Flag to track rider's availability


  @override
  void initState() {
    super.initState();
    checkRiderAvailability();

  }
  void checkRiderAvailability() {
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get()
        .then((snap) {
      setState(() {
        // Update isRiderAvailable based on the availability field in Firestore
        isRiderAvailable = snap.data()!["availability"] == "yes";
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "New Order",
          style: TextStyle(
            color: AppColors().white,
            fontFamily: "Poppins",
            fontSize: 12.sp,
          ),
        ),
      ),
      body: isRiderAvailable
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "New Order",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors().black,
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("orders")
                    .where("status", isEqualTo: "To Pick")
                    .orderBy("orderTime", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  // Extract orders data from snapshot
                  List<DocumentSnapshot> orders =
                      snapshot.data!.docs;

                  // Check if there are no new orders available
                  if (orders.isEmpty) {
                    return Center(
                      child: Text(
                        'No new orders available',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          color: AppColors().black,
                        ),
                      ),
                    );
                  }

                  // Build your UI using the orders data
                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      // Extract order details from each document snapshot
                      dynamic productsData =
                      orders[index].get("products");
                      List<Map<String, dynamic>> productList = [];
                      if (productsData != null &&
                          productsData is List) {
                        productList = List<Map<String,
                            dynamic>>.from(productsData);
                      }

                      print(
                          "Product List: $productList"); // Print productList

                      return Column(
                        children: [
                          OrderCard(
                            itemCount: productList.length,
                            data: productList,
                            orderID: snapshot.data!
                                .docs[index].id,
                            sellerName: "", // Pass the seller's name
                            paymentDetails: snapshot.data!
                                .docs[index]
                                .get("paymentDetails"),
                            totalAmount: snapshot.data!
                                .docs[index]
                                .get("totalAmount")
                                .toString(),
                            cartItems:
                            productList, // Pass the products list
                          ),
                          if (productList.length >
                              1)
                            SizedBox(
                                height:
                                10), // Adjust the height as needed
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }


}
