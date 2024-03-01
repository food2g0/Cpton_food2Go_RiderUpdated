import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'earning_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';

class OrderInProgress extends StatefulWidget {
  final int? currentIndex;

  const OrderInProgress({Key? key, this.currentIndex});
  @override
  _OrderInProgressState createState() => _OrderInProgressState();
}

class _OrderInProgressState extends State<OrderInProgress> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration:  BoxDecoration(
              color: AppColors().red,
            ),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order In Progress",
              style: TextStyle(
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors().white
              ),
            ),
          ),
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body:
        Expanded( // Add another Expanded widget here
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("orders")
                .where("status", isEqualTo: "accepted")
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
                        totalAmount:
                        snapshot.data!.docs[index].get("totalAmount").toString(),
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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => HomeScreen(currentIndex: 1)));
              } else if (index == 1) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => HistoryScreen(currentIndex: 1)));

              } else if (index == 2) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => EarningScreen(currentIndex: 2)));
              } else if (index == 3) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => OrderInProgress(currentIndex: 3)));
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
      ),
    );
  }
}
