
import 'package:cpton_food2go_rider/mainScreen/home_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    return Container(margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12.0),
      ),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: ()
            {
              Navigator.push(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 20,),
          Text(
            orderStatus == "ended" ? "Parcel Delivered $message"
                : "Order Placed $message",
            style: TextStyle(
                color: Colors.white
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