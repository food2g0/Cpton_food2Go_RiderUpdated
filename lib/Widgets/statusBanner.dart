
import 'package:cpton_food2go_rider/mainScreen/home_screen.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatusBanner extends StatelessWidget
{

  final bool? status;
  final String? orderStatus;

  StatusBanner({this.orderStatus,this.status});


  @override
  Widget build(BuildContext context)
  {
    String? message;
    IconData? iconData;

    status! ? iconData  = Icons.done : Icons.cancel;

    status! ? message = "successful"  : message = "unsuccessful";
    return Container(margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        color: AppColors().black,
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: 20,),
          Text(
            orderStatus == "ended" ? "Parcel Delivered $message"
                : "Order Placed $message",
            style: TextStyle(
                color: AppColors().white,
              fontFamily: "Poppins",
              fontSize: 12.sp,
            ),

          ),
          const SizedBox(width: 5,),

          CircleAvatar(
            radius: 8,
            backgroundColor: Colors.green,
            child: Center(
              child: Icon(
                iconData,
                color: Colors.black,
                size: 14,
              ),
            ),
          )

        ],
      ),
    );
  }
}