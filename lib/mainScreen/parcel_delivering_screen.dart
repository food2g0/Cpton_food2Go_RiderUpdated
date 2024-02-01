import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/RiderToCustomerMap.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';


import '../global/global.dart';
import '../splashScreen/splash_screen.dart';


class ParcelDeliveringScreen extends StatefulWidget
{
  String? purchaserId;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? customersUID;
  String? sellerId;
  String? getOrderId;

  ParcelDeliveringScreen({
    this.purchaserId,
    this.purchaserAddress,
    this.purchaserLat,
    this.purchaserLng,
    this.customersUID,
    this.sellerId,
    this.getOrderId,
  });


  @override
  _ParcelDeliveringScreenState createState() => _ParcelDeliveringScreenState();
}




class _ParcelDeliveringScreenState extends State<ParcelDeliveringScreen>
{
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  double? customerLat, customerLng;
  String? customerAddress;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    getCustomerData();
    getOrderByOrderId(widget.getOrderId);
    getOrderDetails();
    // location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    // location.enableBackgroundMode(enable: true);
  }

  Future<Map<String, dynamic>?> getOrderByOrderId(String? orderId) async {
    if (orderId != null) {
      try {
        DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
            .collection("orders")
            .doc(orderId)
            .get();

        if (orderSnapshot.exists) {
          // Order details are available, you can access them using orderSnapshot.data()
          Map<String, dynamic>? orderData = orderSnapshot.data() as Map<String, dynamic>?;

          if (orderData != null) {
            print("Order Details for Order ID $orderId: $orderData");
            return orderData; // Return the order details
          } else {
            print("Error: Order data is null for Order ID $orderId");
          }
        } else {
          print("Order not found for Order ID $orderId!");
        }
      } catch (e) {
        print("Error fetching order details: $e");
      }
    }

    // Return null if order details are not found
    return null;
  }


  Future<void> getOrderDetails() async {
    // Call the method to get order details for a specific order ID
    Map<String, dynamic>? orderDetails = await getOrderByOrderId(widget.getOrderId);

    // Check if orderDetails is not null before using it
    if (orderDetails != null) {
      // Access orderBy value
      String? orderBy = orderDetails['orderBy'];
      print("orderBy: $orderBy");
    }
  }

  Future<void> getCustomerData() async {
    try {
      // Call the method to get order details for a specific order ID
      Map<String, dynamic>? orderDetails = await getOrderByOrderId(widget.getOrderId);

      if (orderDetails != null) {
        // Access orderBy value
        String? orderBy = orderDetails['orderBy'];
        String? addressID = orderDetails['addressID'];
        print("orderBy: $orderBy");
        print("addressID: $addressID");

        // Use the orderBy value to fetch customer data
        DocumentSnapshot customerSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(orderBy)
            .collection("userAddress")
            .doc(addressID)
            .get();

        if (customerSnapshot.exists) {
          // Customer details are available, you can access them using customerSnapshot.data()
          Map<String, dynamic>? customerData = customerSnapshot.data() as Map<String, dynamic>?;

          if (customerData != null) {
            print("Customer Details: $customerData");

            // Print individual data fields
            print("Customer Latitude: ${customerData['lat']}");
            print("Customer Longitude: ${customerData['lng']}");
            print("Customer Full Address: ${customerData['fullAddress']}");

            // Assign customer data to class variables if needed
            setState(() {
              customerLat = customerData['lat'];
              customerLng = customerData['lng'];
              customerAddress = customerData['fullAddress'];
            });
          } else {
            print("Error: Customer data is null for user ID $orderBy");
          }
        } else {
          print("Customer not found for user ID $orderBy!");
        }
      }
    } catch (e) {
      print("Error fetching customer details: $e");
    }
  }




  confirmParcelHasBeenDelivered(getOrderId, sellerId, purchaserId, purchaserAddress, purchaserLat, purchaserLng)
  {

    FirebaseFirestore.instance
        .collection("orders")
        .doc(getOrderId).update({
      "status": "ended",
      "address": completeAddress,
      // "lat": position!.latitude,
      // "lng": position!.longitude,
      "earnings": "", //pay per parcel delivery amount
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("riders")
          .doc(sharedPreferences!.getString("uid"))
          .update(
          {
            "earnings": "", //total earnings amount of rider
          });
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerId)
          .update(
          {
            "earnings": "", //total earnings amount of seller
          });
    }).then((value)
    {
      FirebaseFirestore.instance
          .collection("users")
          .doc(purchaserId)
          .collection("orders")
          .doc(getOrderId).update(
          {
            "status": "ended",
            "riderUID": sharedPreferences!.getString("uid"),
          });
    });

    Navigator.push(context, MaterialPageRoute(builder: (c)=> const MySplashScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF890010),
        title: const Text(
          "Track Order",
          style: TextStyle(fontSize: 18, color: Colors.white70, fontFamily: "Poppins"),
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
                stream: FirebaseFirestore.instance.collection("orders").limit(1).snapshots(),
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

                      return  Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              getCustomerData();
                              try {
                                // Call getCustomerData to retrieve customer details
                                await getCustomerData();

                                // Access customerLat, customerLng, and customerAddress from the updated state
                                double? customerLatitude = customerLat;
                                double? customerLongitude = customerLng;
                                String? purchaserAddress = customerAddress;

                                // Check if values are not null before using them
                                if (customerLatitude != null && customerLongitude != null && purchaserAddress != null) {
                                  // Start location listening
                                  _listenLocation();

                                  // Navigate to RiderToCustomerMap with the updated values
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RiderToCustomerMap(
                                        user_id: snapshot.data!.docs[index].id,
                                        customerLatitude: customerLat,
                                        customerLongitude: customerLng,
                                        purchaserAddress: customerAddress,
                                      ),
                                    ),
                                  );
                                } else {
                                  print("Error: Customer data is null");
                                }
                              } catch (e) {
                                print("Error on button press: $e");
                              }
                            },

                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF31572c),
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.navigation_outlined, color: Color(0xFFFFFFFF)),
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
                    confirmParcelHasBeenDelivered(
                      widget.getOrderId,
                      widget.sellerId,
                      widget.purchaserId,
                      widget.purchaserAddress,
                      widget.purchaserLat,
                      widget.purchaserLng,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF890010),
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check, color: Color(0xFFFFFFFF),),
                      Text(
                        "Order has been Delivered",
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
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //
  //         Image.asset(
  //           "images/confirm1.png",
  //           width: 350,
  //         ),
  //
  //         const SizedBox(height: 5,),
  //
  //         GestureDetector(
  //           onTap: ()
  //           {
  //             //show location from rider current location towards seller location
  //             // MapUtils.lauchMapFromSourceToDestination(position!.latitude, position!.longitude, widget.purchaserLat, widget.purchaserLng);
  //           },
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //
  //               Image.asset(
  //                 'images/restaurant.png',
  //                 width: 50,
  //               ),
  //
  //               const SizedBox(width: 7,),
  //
  //               Column(
  //                 children: const [
  //                   SizedBox(height: 12,),
  //
  //                   Text(
  //                     "Show Cafe/Restaurant Location",
  //                     style: TextStyle(
  //                       fontFamily: "Signatra",
  //                       fontSize: 18,
  //                       letterSpacing: 2,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //
  //             ],
  //           ),
  //         ),
  //
  //         const SizedBox(height: 40,),
  //
  //         Padding(
  //           padding: const EdgeInsets.all(10.0),
  //           child: Center(
  //             child: InkWell(
  //               onTap: ()
  //               {
  //                 //rider location update
  //                 // UserLocation uLocation = UserLocation();
  //                 // uLocation.getCurrentLocation();
  //
  //                 //confirmed - that rider has picked parcel from seller
  //                 confirmParcelHasBeenDelivered(
  //                     widget.getOrderId,
  //                     widget.sellerId,
  //                     widget.purchaserId,
  //                     widget.purchaserAddress,
  //                     widget.purchaserLat,
  //                     widget.purchaserLng
  //                 );
  //               },
  //               child: Container(
  //                 decoration: const BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [
  //                         Colors.cyan,
  //                         Colors.amber,
  //                       ],
  //                       begin:  FractionalOffset(0.0, 0.0),
  //                       end:  FractionalOffset(1.0, 0.0),
  //                       stops: [0.0, 1.0],
  //                       tileMode: TileMode.clamp,
  //                     )
  //                 ),
  //                 width: MediaQuery.of(context).size.width - 90,
  //                 height: 50,
  //                 child: const Center(
  //                   child: Text(
  //                     "Order has been Delivered - Confirm",
  //                     style: TextStyle(color: Colors.white, fontSize: 15.0),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //
  //       ],
  //     ),
  //   );
  // }

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
        'name': 'john'
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

