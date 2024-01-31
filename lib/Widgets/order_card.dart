import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import '../mainScreen/order_details_screen.dart';
import '../models/items.dart';

class OrderCard extends StatelessWidget {
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? seperateQuantitiesList;
  final String? sellerName;

  OrderCard({
    this.itemCount,
    this.data,
    this.orderID,
    this.seperateQuantitiesList,
    this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c) => OrderDetailsScreen(orderID: orderID)));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          border: Border.all(
            color: AppColors().red, // You can change the border color
            width: 1.0, // You can change the border width
          ),
        ),


        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        height: itemCount! * 120,
        child: ListView.builder(
          itemCount: itemCount,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Items model = Items.fromJson(data![index].data()! as Map<String, dynamic>);
            return placedOrderDesignWidget(model, context, seperateQuantitiesList![index], sellerName);
          },
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, String seperateQuantitiesList, String? sellerName) {
  return Row(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10.0), // You can adjust the border radius as needed
        child: Image.network(
          model.thumbnailUrl!,
          width: 100,
          height: 100, // Adjust the height to match the container size
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 10.0,),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
               model.productTitle!,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontFamily: "Poppins",
                fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 5,),
            Text(
              sellerName ?? '',
              style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins"
              ),
            ),
            Row(
              children: [
                const Text(
                  "Price: Php ",
                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                ),
                Text(
                  model.productPrice.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14.0,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  "qty: x ",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                Text(
                  seperateQuantitiesList,
                  style: const TextStyle(
                    color: Colors.black54,
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
    ],
  );
}
