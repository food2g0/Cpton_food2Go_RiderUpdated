import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/home_screen.dart';

import 'package:cpton_food2go_rider/mainScreen/ParcelPicking_Screen.dart';
import 'package:cpton_food2go_rider/models/address.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart'as loc;
import 'package:permission_handler/permission_handler.dart';


import '../splashScreen/splash_screen.dart';

class ShipmentAddressDesign extends StatefulWidget {
  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? sellerId;
  final String? orderByUser;
  final String? riderUID;


  ShipmentAddressDesign({this.model, this.orderStatus, this.orderId, this.sellerId, this.orderByUser, this.riderUID, });

  @override
  State<ShipmentAddressDesign> createState() => _ShipmentAddressDesignState();
}

class _ShipmentAddressDesignState extends State<ShipmentAddressDesign> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  bool canProceed = true;

  Future<void> confirmedParcelShipment(BuildContext context, String getOrderID, String sellerId, String purchaserId) async {
    // Get a reference to the order document
    DocumentReference orderRef = FirebaseFirestore.instance.collection("orders").doc(getOrderID);

    // Update the order status to "accepted" and set the rider details
    await orderRef.update({
      "riderUID": sharedPreferences!.getString("uid"),
      "riderName": sharedPreferences!.getString("name"),
      "status": "accepted",
      "address": completeAddress,
    });
    DocumentReference orderRefs = FirebaseFirestore.instance.collection("users").doc(widget.orderByUser)
    .collection("orders").doc(getOrderID);

    await orderRefs.update({
      "riderUID": sharedPreferences!.getString("uid"),
      "riderName": sharedPreferences!.getString("name"),
      "status": "accepted",
      "address": completeAddress,
    });

    // Get the updated order snapshot
    DocumentSnapshot orderSnapshot = await orderRef.get();

    // Check if the order is already accepted by another rider
    String currentStatus = orderSnapshot["status"];
    String updatedRiderUID = orderSnapshot["riderUID"];

    if (currentStatus == "accepted" && updatedRiderUID != sharedPreferences!.getString("uid")) {
      // Parcel has already been accepted by another rider
      Fluttertoast.showToast(
        msg: "Parcel has already been accepted by another rider",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Set canProceed to false
      canProceed = false;
    }

    // Check if the updated riderUID is equal to the current user's UID
    if (canProceed && updatedRiderUID == sharedPreferences!.getString("uid")) {
      // Send the rider to ParcelPickingScreen
      Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelPickingScreen(
        purchaserId: purchaserId,
        purchaserAddress: widget.model!.fullAddress,
        purchaserLat: widget.model!.lat,
        purchaserLng: widget.model!.lng,
        purchaserName: widget.model!.name!,
        sellerId: sellerId,
        getOrderID: getOrderID,
      )));
    }
  }




  @override
  Widget build(BuildContext context)
  {
    return
      Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
              'Shipping Details:',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontFamily: "Poppins")
          ),
        ),
        const SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              TableRow(
                children: [
                  const Text(
                    "Name : ",
                    style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12),
                  ),
                  Text(widget.model!.name!,style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12),),
                ],
              ),
              TableRow(
                children: [
                   Text(
                    "Phone Number : ",
                    style: TextStyle(color: AppColors().black, fontFamily: "Poppins", fontSize: 12),
                  ),
                  Text(widget.model!.phoneNumber!,  style: TextStyle(color: AppColors().black, fontFamily: "Poppins", fontSize: 12), ),
                ],
              ),
            ],
          ),
        ),
         SizedBox(
          height: 5.h,
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            widget.model!.fullAddress!,
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 12,
            ),
          ),
        ),

        widget.orderStatus == "ended"
            ? Container()
            : Center(
          child: InkWell(
            onTap: () {
              _getLocation();
              _requestPermission();
              confirmedParcelShipment(context, widget.orderId!, widget.sellerId!, widget.orderByUser!);
            },
            child: Container(
              decoration: BoxDecoration(
               color: AppColors().green
              ),
              width: MediaQuery.of(context).size.width - 40,
              height: 50,
              child: Center(
                child: Text(
                  "Confirm - To Deliver this Parcel",
                  style: TextStyle(color: AppColors().white, fontSize: 12.sp),
                ),
              ),
            ),
          ),
        ),


        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: ()
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
              child: Container(
                decoration: BoxDecoration(
                   color: AppColors().red
                ),
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: Center(
                  child: Text(
                    "Go Back",
                    style: TextStyle(color: Colors.white, fontSize: 12.0.sp),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 20,),
      ],
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude1': _locationResult.latitude,
        'longitude1': _locationResult.longitude,
        'name': 'john'
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }
  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}