import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/assisstantMethod/assistant_methods.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';

import '../global/global.dart';
import 'earning_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';

class OrderInProgress extends StatefulWidget {
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
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "accepted")
              .where("riderUID", isEqualTo: sharedPreferences!.getString("uid"))
              .orderBy("orderTime", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: circularProgress());
            }

            if (snapshot.data!.docs.isEmpty) {
              // The stream has no items
              return Center(child: Text("No orders in progress"));
            }

            // The stream has items, proceed with building the UI
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("items")
                      .where(
                    "productsID",
                    whereIn: separateOrderItemIDs(
                      (snapshot.data!.docs[index].data()!
                      as Map<String, dynamic>)["productsIDs"],
                    ),
                  )
                      .where(
                    "orderBy",
                    whereIn: (snapshot.data!.docs[index].data()!
                    as Map<String, dynamic>)["uid"],
                  )
                      .orderBy("publishedDate", descending: true)
                      .snapshots(),
                  builder: (context, snap) {
                    return snap.hasData
                        ? OrderCard(
                      itemCount: snap.data!.docs.length,
                      data: snap.data!.docs,
                      orderID: snapshot.data!.docs[index].id,
                      seperateQuantitiesList:
                      separateOrderItemQuantities(
                        (snapshot.data!.docs[index].data()!
                        as Map<String, dynamic>)["productsIDs"],
                      ),
                    )
                        : Center(child: circularProgress());
                  },
                );
              },
            );
          },
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
      ),
    );
  }
}
