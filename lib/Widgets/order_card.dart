import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (c) => OrderDetailsScreen(orderID: orderID)),
        );
      },
      child: Card(
        elevation: 2,
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                Items model = Items.fromJson(data![index].data()! as Map<String, dynamic>);
                return placedOrderDesignWidget(model, context, seperateQuantitiesList![index], sellerName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget placedOrderDesignWidget(Items model, BuildContext context, String separateQuantitiesList, String? sellerName) {
  return SizedBox(
    height: 140,
    child: Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.network(
              model.thumbnailUrl!,
              width: 150.w,
              height: 120.h,
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
                  model.productTitle!,
                  style: TextStyle(
                    color: AppColors().black,
                    fontSize: 12.sp,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5,),

                Row(
                  children: [
                    Image.asset(
                      "images/store.png",
                      width: 14.w,
                      height: 14.h,
                      color: AppColors().red,
                    ),
                    SizedBox(width: 5.w,),
                    Text(
                      sellerName ?? '',
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
                    Image.asset(
                     'images/peso.png',
                      width: 14,
                      height: 14,
                      color: AppColors().red,
                    ),
                    SizedBox(width: 5.w,),
                    Text(
                        model.productPrice.toString(),
                      style: TextStyle(
                        color: AppColors().black1,
                        fontSize: 14.0.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                    const SizedBox(width: 5),

                    Text(
                      "x ",
                      style: TextStyle(
                        color: AppColors().black1,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                        fontFamily: "Poppins",
                      ),
                    ),

                    Text(
                      separateQuantitiesList,
                      style: TextStyle(
                        color: AppColors().black1,
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
