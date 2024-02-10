import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/home_screen.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Widgets/order_card.dart';
import '../Widgets/progress_bar.dart';
import '../assisstantMethod/assistant_methods.dart';
import 'history_screen.dart';
import 'order_in_progress.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({Key? key}) : super(key: key);

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    String riderUID = FirebaseAuth.instance.currentUser!.uid;
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
            child: Container(
              height: 200,
              child: Card(
                color: AppColors().white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
                      Text(
                        '\Php $previousRiderEarnings',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors().red,
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
                    .where("riderUID", isEqualTo: riderUID) // Filter by rider ID
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
          ),
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: AppColors().black,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Handle navigation to different screens based on index
            if (index == 0) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));
            } else if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => HistoryScreen()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => EarningScreen()));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (c) => OrderInProgress()));
            }
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining),
              label: 'Ongoing Delivery',
            ),
          ],
        ),
      ),
    );
  }
}
