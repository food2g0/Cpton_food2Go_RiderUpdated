import 'package:cloud_firestore/cloud_firestore.dart';
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
      child: Card(
        elevation: 2,
        child: Container(
          color: Colors.white70,
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(10),
          height: itemCount! * 125,
          child: ListView.builder(
            itemCount: itemCount,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              Items model = Items.fromJson(data![index].data()! as Map<String, dynamic>);
              return placedOrderDesignWidget(model, context, seperateQuantitiesList![index], sellerName);
            },
          ),
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, String seperateQuantitiesList, String? sellerName) {
  return Container(
    width: MediaQuery.of(context).size.width,
    height: 110,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display seller's name
        Row(
          children: [
            Image.network(model.thumbnailUrl!, width: 100,),
            const SizedBox(width: 10.0,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10,),
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
                        color: Colors.black45,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins"
                    ),
                  ),
                  Row(
                    children: [
                      const Text(
                        "Price: Php ",
                        style: TextStyle(fontSize: 10.0, color: Colors.red),
                      ),
                      Text(
                        model.productPrice.toString(),
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 10.0,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        "qty: x ",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        seperateQuantitiesList,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 10,
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
        ),
      ],
    ),
  );
}
