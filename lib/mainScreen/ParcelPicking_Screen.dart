import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Maps/map.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/parcel_delivering_screen.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import '../Widgets/RidersToSellerMap.dart';


class ParcelPickingScreen extends StatefulWidget
{
  String? purchaserId;
  String? sellerId;
  String? getOrderID;
  String? purchaserAddress;
  String? purchaserName;
  double? purchaserLat;
  double? purchaserLng;
  String? riderName;
  String? riderUID;
  String? orderByUser;

  ParcelPickingScreen({
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.riderName,
    this.purchaserLng,
    this.riderUID,
    this.orderByUser,
    this.purchaserName
  });

  @override
  _ParcelPickingScreenState createState() => _ParcelPickingScreenState();
}



class _ParcelPickingScreenState extends State<ParcelPickingScreen>
{
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  double? sellerLat, sellerLng;
  String? sellerAddress;
  String? sellerName;



  @override
  void initState() {
    super.initState();
    _requestPermission();
    getSellerData();
    // location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    // location.enableBackgroundMode(enable: true);
  }

  getSellerData() async
  {
    FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerId)
        .get()
        .then((DocumentSnapshot)
    {
      sellerLat = DocumentSnapshot.data()!["lat"];
      sellerLng = DocumentSnapshot.data()!["lng"];
      sellerName = DocumentSnapshot.data()!["sellersName"];
      sellerAddress = DocumentSnapshot.data()!["sellersAddress"];
    });
  }



  confirmParcelHasBeenPicked(getOrderId, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {

    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderId).update({
      "status": "delivering",
      "address": completeAddress,
      // "lat": position!.latitude,
      // "lng": position!.longitude,
    });
    FirebaseFirestore.instance
        .collection("users").doc(widget.orderByUser)
        .collection("orders").doc(widget.getOrderID).update({
      "status": "delivering",
      "address": completeAddress,
      // "lat": position!.latitude,
      // "lng": position!.longitude,
    });


    Navigator.push(context, MaterialPageRoute(builder: (c)=> ParcelDeliveringScreen(
      purchaserId: purchaserId,
      purchaserAddress: purchaserAddress,
      sellerId: sellerId,
      getOrderId: getOrderId,
      purchaserName: widget.purchaserName,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().black,
        title:  Text(
          "Track Order",
          style: TextStyle(fontSize: 14.sp, color: AppColors().white, fontFamily: "Poppins"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "images/confirm1.png",
              width: 350,
            ),
            const SizedBox(height: 10,),
            Container(
              height: 100, // Set a specific height for your ListView.builder
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection("location").limit(1).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (context, index) {
                      if (snapshot.data?.docs == null || index >= snapshot.data!.docs.length) {
                        return Container(); // or any other widget indicating the absence of data
                      }

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
                              _listenLocation();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => RiderToSellerMap(
                                    user_id: snapshot.data!.docs[index].id,
                                    sellerUID: widget.sellerId ?? "",
                                    sellerAddress: sellerAddress,
                                    getOrderID: widget.getOrderID,
                                    sellerName: sellerName,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF31572c),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.navigation_outlined, color: Color(0xFFFFFFFF),),
                                Text(
                                  "Start Navigation",
                                  style: TextStyle(fontSize: 14, fontFamily: "Poppins", color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );

                    },
                  );

                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    confirmParcelHasBeenPicked(
                      widget.getOrderID,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF890010),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Color(0xFFFFFFFF),),
                      Text(
                        "Order has been Picked",
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': currentlocation.latitude,
        'orderID': widget.getOrderID,
        'longitude': currentlocation.longitude,
        'name': widget.riderName,
      }, SetOptions(merge: true));
    });
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
