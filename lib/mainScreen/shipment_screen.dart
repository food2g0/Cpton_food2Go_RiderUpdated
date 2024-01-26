import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Maps/map.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/parcel_delivering_screen.dart';
import 'package:flutter/material.dart';
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
  double? purchaserLat;
  double? purchaserLng;
  String? riderName;


  ParcelPickingScreen({
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.riderName,
    this.purchaserLng,
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
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    Navigator.push(context, MaterialPageRoute(builder: (c)=> ParcelDeliveringScreen(
      purchaserId: purchaserId,
      purchaserAddress: purchaserAddress,
      purchaserLat: purchaserLat,
      purchaserLng: purchaserLng,
      sellerId: sellerId,
      getOrderId: getOrderId,
    )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:  const Color(0xFF890010),
        title: const Text("Track Order",style: TextStyle(
          fontSize: 18,
          color: Colors.white70,
          fontFamily: "Poppins"
        ),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Image.asset(
            "images/confirm1.png",
            width: 350,
          ),

          const SizedBox(height: 5,),
          Expanded(child: StreamBuilder(stream:
          FirebaseFirestore.instance.collection('location')
              .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index){
                    return ListTile(
                      title: Text(snapshot.data!.docs[index]['name'].toString()),
                      subtitle: Row(
                        children: [
                          Visibility(
                            visible: false, // Set visibility to false to hide the latitude Text
                            child: Text(snapshot.data!.docs[index]['latitude'].toString()),
                          ),
                          SizedBox(width: 20),
                          Visibility(
                            visible: false, // Set visibility to false to hide the longitude Text
                            child: Text(snapshot.data!.docs[index]['longitude'].toString()),
                          ),
                        ],
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          _listenLocation();
                          _getLocation();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MyMap(
                                user_id: snapshot.data!.docs[index].id,
                                sellerUID: widget.sellerId ?? "", sellerAddress: sellerAddress,

                              ),
                            ),
                          );
                          _listenLocation();
                        },
                        child: Text("Track Order"), // Replace with your desired button text
                      ),
                    );

                  });
            },
          )),


          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Center(
              child: InkWell(
                onTap: ()
                {
                  // UserLocation uLocation = UserLocation();
                  // uLocation.getCurrentLocation();

                  //confirmed - that rider has picked parcel from seller
                  confirmParcelHasBeenPicked(
                      widget.getOrderID,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng
                  );
                },
                child: Container(
                 color: Color(0xFF890010),
                  width: MediaQuery.of(context).size.width - 90,
                  height: 60,
                  child: const Center(
                    child: Text(
                      "Order has been Picked - Confirmed",
                      style: TextStyle(color: Colors.white, fontSize: 12.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],

      ),






    );
  }
  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection("riders")
          .doc(sharedPreferences!.getString("uid"))
          .collection("location")
          .doc()

      // FirebaseFirestore.instance.collection('location').doc('user1')
          .set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'name': 'user1',
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
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
        'longitude': currentlocation.longitude,

      }, SetOptions(merge: true));
    });
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