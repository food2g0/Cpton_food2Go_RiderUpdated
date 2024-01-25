import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/assisstantMethod/get_current_location.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/home_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/order_details_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/shipment_screen.dart';
import 'package:cpton_food2go_rider/models/address.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../splashScreen/splash_screen.dart';

class ShipmentAddressDesign extends StatelessWidget
{
  final Address? model;
  final String? orderStatus;
  final String? orderId;
  final String? sellerId;
  final String? orderByUser;


  ShipmentAddressDesign({this.model, this.orderStatus, this.orderId, this.sellerId, this.orderByUser, });



  confirmedParcelShipment(BuildContext context, String getOrderID, String sellerId, String purchaserId,)
  {
    if (sharedPreferences != null && position != null) {
      FirebaseFirestore.instance
          .collection("orders")
          .doc(getOrderID)
          .update({
        "riderUID": sharedPreferences!.getString("uid"),
        "riderName": sharedPreferences!.getString("name"),
        "status": "picking",
        "lat": position?.latitude,
        "lng": position?.longitude,
        "address": completeAddress,
      });
    } else {
      // Handle the case where sharedPreferences or position is null
      print("sharedPreferences or position is null");
    }


    //send rider to shipmentScreen
    Navigator.push(context, MaterialPageRoute(builder: (context) => ParcelPickingScreen(
      purchaserId: purchaserId,
      purchaserAddress: model!.fullAddress,
      purchaserLat: model!.lat,
      purchaserLng: model!.lng,
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
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),
        const SizedBox(
          height: 6.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 5),
          width: MediaQuery.of(context).size.width,
          child: Table(
            children: [
              TableRow(
                children: [
                  const Text(
                    "Name",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(model!.name!),
                ],
              ),
              TableRow(
                children: [
                  const Text(
                    "Phone Number",
                    style: TextStyle(color: Colors.black),
                  ),
                  Text(model!.phoneNumber!),
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
            model!.fullAddress!,
            textAlign: TextAlign.justify,
          ),
        ),


        orderStatus == "ended"
            ? Container()
            : Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: InkWell(
              onTap: ()
              {
                UserLocation uLocation = UserLocation();
                uLocation.getCurrentLocation();

                confirmedParcelShipment(context, orderId!, sellerId!, orderByUser!);

              },
              child: Container(
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.cyan,
                        Colors.amber,
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
                    style: TextStyle(color: Colors.white, fontSize: 15.0),
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
                        Colors.cyan,
                        Colors.amber,
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
}