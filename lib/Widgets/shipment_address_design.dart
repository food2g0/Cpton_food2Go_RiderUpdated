import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/assisstantMethod/get_current_location.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/home_screen.dart';

import 'package:cpton_food2go_rider/mainScreen/ParcelPicking_Screen.dart';
import 'package:cpton_food2go_rider/models/address.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart'as loc;
import 'package:permission_handler/permission_handler.dart';


import '../splashScreen/splash_screen.dart';

class ShipmentAddressDesign extends StatefulWidget
{
  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? sellerId;
  final String? orderByUser;


  ShipmentAddressDesign({this.model, this.orderStatus, this.orderId, this.sellerId, this.orderByUser, });

  @override
  State<ShipmentAddressDesign> createState() => _ShipmentAddressDesignState();
}

class _ShipmentAddressDesignState extends State<ShipmentAddressDesign> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  confirmedParcelShipment(BuildContext context, String getOrderID, String sellerId, String purchaserId,)
  {
    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderID)
        .update({
      "riderUID": sharedPreferences!.getString("uid"),
      "riderName": sharedPreferences!.getString("name"),
      "status": "picking",
      // "lat": position!.latitude,
      // "lng": position!.longitude,
      "address": completeAddress,
    });

    //send rider to shipmentScreen
    Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelPickingScreen(
      purchaserId: purchaserId,
      purchaserAddress: widget.model!.fullAddress,
      purchaserLat: widget.model!.lat,
      purchaserLng: widget.model!.lng,
      sellerId: sellerId,
      getOrderID: getOrderID,
    )));
  }

  @override
  Widget build(BuildContext context)
  {
    return Column(
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
                  const Text(
                    "Phone Number : ",
                    style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12),
                  ),
                  Text(widget.model!.phoneNumber!,  style: TextStyle(color: Colors.black, fontFamily: "Poppins", fontSize: 12), ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
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
            : Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: ()
              {
                _getLocation();
                _requestPermission();
                confirmedParcelShipment(context, widget.orderId!, widget.sellerId!, widget.orderByUser!);

              },
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent,
                        Colors.green,
                      ],
                      begin:  FractionalOffset(0.0, 0.0),
                      end:  FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    )
                ),
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: const Center(
                  child: Text(
                    "Confirm - To Deliver this Parcel",
                    style: TextStyle(color: Colors.white70, fontSize: 12.0),
                  ),
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
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF890010),
                        Colors.red,
                      ],
                      begin:  FractionalOffset(0.0, 0.0),
                      end:  FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp,
                    )
                ),
                width: MediaQuery.of(context).size.width - 40,
                height: 50,
                child: const Center(
                  child: Text(
                    "Go Back",
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
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
      await FirebaseFirestore.instance.collection("orders")
          .doc(widget.orderId)


      // FirebaseFirestore.instance.collection('location').doc('user1')
          .set({
        'Riderlatitude': _locationResult.latitude,
        'Riderlongitude': _locationResult.longitude,
        'name1': 'user1',
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