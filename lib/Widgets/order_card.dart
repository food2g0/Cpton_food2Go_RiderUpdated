import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/mainScreen/order_details_screen.dart';
import 'package:cpton_food2go_rider/models/items.dart';
import 'package:flutter/material.dart';


class OrderCard extends StatelessWidget {
  final int? itemCount;
  final List<DocumentSnapshot>? data;
  final String? orderID;
  final List<String>? seperateQuantitiesList;

  OrderCard({
    this.itemCount,
    this.data,
    this.orderID,
    this.seperateQuantitiesList,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (c)=>OrderDetailsScreen(orderID: orderID)));
      },
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Colors.black87,Colors.black])
        ),
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(10),
        height: itemCount! * 90, // Adjusted height
        child: ListView.builder(
          itemCount: itemCount,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            Items model =
            Items.fromJson(data![index].data()! as Map<String, dynamic>);
            return placedOrderDesignWidget(
              model,
              context,
              seperateQuantitiesList![index],
              orderID,
            );
          },
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(
    Items model,
    BuildContext context,
    String separateQuantities,
    String? orderID,
    ) {
  num productPrice = model.productPrice ?? 0.0;
  int quantity = int.tryParse(separateQuantities) ?? 0;

  num totalAmount = productPrice * quantity;

  return Container(
    width: 431,
    height: 84,
    child: Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: Container(
            width: 431,
            height: 84,
            decoration: ShapeDecoration(
              color: Color(0xFFD9D9D9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              width: 431,
              height: 84,
              decoration: BoxDecoration(
                color: Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 95,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: NetworkImage(model.thumbnailUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 10), // Adjust the spacing between image and text
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 157,
                      height: 15,
                      child: Text(
                        model.productTitle,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 153,
                      height: 21,
                      child: Text(
                        'Products Store name',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 153,
                      height: 21,
                      child: Text(
                        'Products Store address',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 10), // Adjust the spacing between text sections


              ],

            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 19,
                    height: 18,
                    child: Text(
                      "x $separateQuantities",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(width: 50), // Adjust the spacing between text sections
                  SizedBox(
                    height: 25,
                    child: Text(
                      "Php ${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Color(0xFFF40808),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )


          ],
        ),
        Stack(
          children: [
            Align(
              alignment: Alignment(.9, -0.6), // Adjust alignment as needed
              child: Container(
                width: 68,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        Stack(
          children: [
            Align(
              alignment: Alignment(.9, .6), // Adjust alignment as needed
              child: Container(
                width: 68,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.remove_red_eye,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),




      ],
    ),
  );
}