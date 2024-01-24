import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/assisstantMethod/assistant_methods.dart';
import 'package:flutter/material.dart';

class OrderInProgress extends StatefulWidget {
  @override
  _OrderInProgressState createState() => _OrderInProgressState();
}

class _OrderInProgressState extends State<OrderInProgress> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF890010),
            ),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Order In Progress",
              style: TextStyle(
                fontFamily: "Poppins",
              ),
            ),
          ),
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "picking")
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
      ),
    );
  }
}
