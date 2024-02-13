import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/Widgets/shipment_address_design.dart';
import 'package:cpton_food2go_rider/Widgets/statusBanner.dart';
import 'package:cpton_food2go_rider/models/address.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../Widgets/order_card.dart';

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
  String products = "";
  String paymentDetails = "";
  late Future<DocumentSnapshot> _orderInfoFuture;

  @override
  void initState() {
    super.initState();
    _orderInfoFuture = getOrderInfo();
  }

  Future<DocumentSnapshot> getOrderInfo() {
    return FirebaseFirestore.instance
        .collection("orders")
        .doc(widget.orderID)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          "Order Details",
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors().white,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: _orderInfoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: circularProgress());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            Map? dataMap = snapshot.data!.data()! as Map<String, dynamic>;
            orderStatus = dataMap["status"].toString();
            orderByUser = dataMap["orderBy"].toString();
            sellerId = dataMap["sellerUID"].toString();
            products = dataMap["products"].toString();
            paymentDetails = dataMap["paymentDetails"].toString();

            List<Map<String, dynamic>> productList = List<Map<String, dynamic>>.from(dataMap["products"]);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Text(
                    "Total Amount (including shipping fee): Php ${dataMap?["totalAmount"]}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0.w),
                  child: Text(
                    "Payment: ${dataMap?["paymentDetails"]}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                      color: AppColors().black
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Order Id = ${widget.orderID!}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Order at: ${DateFormat("dd MMMM, yyyy - hh:mm aa").format(
                      DateTime.fromMillisecondsSinceEpoch(
                        int.parse(dataMap?["orderTime"]),
                      ),
                    )}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors().black1,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                const Divider(thickness: 4),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    // Extract product details
                    Map<String, dynamic> product = productList[index];
                    // Return the product widget
                    return ListTile(
                      title: Text(product["productTitle"]),
                      titleTextStyle: TextStyle(color: AppColors().black,
                      fontFamily: "Poppins",
                      fontSize: 12.sp),
                      subtitle: Text("Price: ${product["productPrice"]}"),
                      subtitleTextStyle: TextStyle(fontSize: 12.sp,
                      fontFamily: "Poppins",
                      color: AppColors().black),
                      trailing: Text("Quantity: ${product["itemCounter"]}"),
                      // You can add more details as needed
                    );
                  },
                ),

                const Divider(thickness: 4),

                FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(orderByUser)
                      .collection("userAddress")
                      .doc(dataMap?["addressID"])
                      .get(),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? ShipmentAddressDesign(
                      model: Address.fromJson(
                        snapshot.data!.data()! as Map<String, dynamic>,
                      ),
                      orderStatus: orderStatus,
                      orderId: widget.orderID,
                      sellerId: sellerId,
                      orderByUser: orderByUser,
                    )
                        : Center(child: circularProgress());
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
