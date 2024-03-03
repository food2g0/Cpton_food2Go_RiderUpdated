import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../mainScreen/order_details_screen.dart';

class OrderCard extends StatelessWidget {
  final int itemCount;
  final List<Map<String, dynamic>> data;
  final String orderID;
  final String sellerName;
  final String? paymentDetails;
  final String? totalAmount;
  final List<Map<String, dynamic>> cartItems;
  final productData;

  OrderCard({
    required this.itemCount,
    required this.data,
    required this.orderID,
    required this.sellerName,
    this.paymentDetails,
    this.totalAmount,
    required this.cartItems, this.productData,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ()  {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => OrderDetailsScreen(orderID: orderID)),
        );
      },
      child: Container(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                return placedOrderDesignWidget(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget placedOrderDesignWidget(BuildContext context, int index) {
    Map<String, dynamic> snapshot = data[index];
    return SizedBox(
      height: 100.h,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                cartItems[index]['thumbnailUrl'], // Use cartItems instead of data
                width: 100.w,
                height: 100.h,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItems[index]['productTitle'], // Use cartItems instead of data
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5,),
                  Row(
                    children: [
                      Text(
                        "Seller: ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        sellerName,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Price: ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        cartItems[index]['productPrice'].toString(), // Use cartItems instead of data
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          fontFamily: "Poppins",
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "x ",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        cartItems[index]['itemCounter'].toString(), // Use cartItems instead of data
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
