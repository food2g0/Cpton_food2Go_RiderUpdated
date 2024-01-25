import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Maps/map.dart';
import 'package:cpton_food2go_rider/Widgets/RiderToSellerMap.dart';
import 'package:cpton_food2go_rider/assisstantMethod/get_current_location.dart';
import 'package:cpton_food2go_rider/global/global.dart';
import 'package:cpton_food2go_rider/mainScreen/parcel_delivering_screen.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';


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
                      title:
                      Text(snapshot.data!.docs[index]['name'].toString()),
                      subtitle: Row(
                        children: [
                          Text(snapshot.data!.docs[index]['latitude']
                              .toString()),
                          SizedBox(
                            width: 20,
                          ),
                          Text(snapshot.data!.docs[index]['longitude']
                              .toString()),

                        ],
                      ),
                      trailing: IconButton(icon: Icon(Icons.directions),
                        onPressed: ()

                        {
                          _listenLocation();
                          _getLocation();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyMap(
                               user_id: snapshot.data!.docs[index].id, // Pass the user_id parameter
                              sellerUID: widget.sellerId ?? "", // Pass the sellerUID parameter
                            ),
                          ));
                          _listenLocation();
                        },
                      ),
                    );
                  });
            },
          )),
          GestureDetector(
            onTap: () {

            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/restaurant.png',
                  width: 50,
                ),
                const SizedBox(width: 7,),
                Column(
                  children: const [
                    SizedBox(height: 12,),
                    Text(
                      "Show Cafe/Restaurant Location",
                      style: TextStyle(
                        fontFamily: "Signatra",
                        fontSize: 18,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 40,),

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
                  width: MediaQuery.of(context).size.width - 90,
                  height: 50,
                  child: const Center(
                    child: Text(
                      "Order has been Picked - Confirmed",
                      style: TextStyle(color: Colors.white, fontSize: 15.0),
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