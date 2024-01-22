import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/Widgets/shipment_address_design.dart';
import 'package:cpton_food2go_rider/Widgets/statusBanner.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/models/address.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String? orderID;

  OrderDetailsScreen({this.orderID});

  @override
  _OrderDetailsScreenState createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {

  String orderStatus = "";
  String orderByUser = "";
  String sellerId = "";
  getOrderInfo()
  {
    FirebaseFirestore.instance.collection("orders")
        .doc(widget.orderID)
        .get()
        .then((DocumentSnapshot)
        {
          orderStatus = DocumentSnapshot.data()!["status"].toString();
          orderByUser = DocumentSnapshot.data()!["orderBy"].toString();
          sellerId = DocumentSnapshot.data()!["sellerUID"].toString();

        });
  }
  @override
  void initState() {

    super.initState();
    getOrderInfo();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection("orders")
              .doc(widget.orderID)
              .get(),
          builder: (context, snapshot) {
            Map ? dataMap;
            if (snapshot.hasData) {
              dataMap = snapshot.data!.data()! as Map<String, dynamic>;
              orderStatus = dataMap["status"].toString();
            }
            return snapshot.hasData
                ? Container(
              child: Column(
                children: [
                  StatusBanner(
                    status: dataMap!["isSuccess"] == true,
                    orderStatus: orderStatus,
                  ),
                  const SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Total Amount Php " + dataMap["totalAmount"].toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Align(
                       alignment: Alignment.centerLeft,
                       child: Text(
                          "Order Id = " + widget.orderID!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: "Poppins",
                          ),
                        ),
                     ),
                   ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "Order at: " +
                              DateFormat("dd MMMM, yyyy - hh:mm aa").format(
                                DateTime.fromMillisecondsSinceEpoch(
                                  int.parse(dataMap["orderTime"]),
                                ),
                              ),
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontFamily: "Poppins",
                          ),
                        ),
                    ),
                  ),

                  const Divider(thickness: 4),

                  orderStatus == "ended"


                      ? Image.asset("images/delivered.jpg")
                      : Image.asset("images/state.jpg"),
                  const Divider(thickness: 4),
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection("users")
                        .doc(orderByUser)
                        .collection("userAddress")
                        .doc(dataMap["addressID"])
                        .get(),
                    builder: (context, snapshot) {
                      return snapshot.hasData
                          ? ShipmentAddressDesign(
                        model: Address.fromJson(
                          snapshot.data!.data()!
                          as Map<String, dynamic>
                        ),
                        orderStatus: orderStatus,
                        orderId : widget.orderID,
                        sellerId : sellerId,
                        orderByUser : orderByUser,
                      )
                          : Center(child: circularProgress());
                    },
                  ),
                ],
              ),
            )
                : Center(child: circularProgress());
          },
        ),
      ),
    );
  }
}
