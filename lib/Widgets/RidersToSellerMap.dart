import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import '../assisstantMethod/assistant_methods.dart';
import '../global/global.dart';
import '../mainScreen/parcel_delivering_screen.dart';
import 'order_card.dart';

class RiderToSellerMap extends StatefulWidget {
  final String user_id;
  final String sellerUID;
  final String? sellerAddress;
  bool parcelPicked = false;
  String? purchaserId;
  String? sellerId;
  String? getOrderID;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;
  String? riderName;
  String? riderUID;
  String? sellerName;

  RiderToSellerMap({
    required this.user_id,
    required this.sellerUID,
    this.sellerAddress,
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserLat,
    this.riderName,
    this.purchaserLng,
    this.riderUID,
    this.sellerName,
  });

  @override
  _RiderToSellerMapState createState() => _RiderToSellerMapState();
}

class _RiderToSellerMapState extends State<RiderToSellerMap> {
  late Stream<DocumentSnapshot> _orderStream;
  final loc.Location location = loc.Location();
  double destinationLatitude = 0.0; // Default value
  double destinationLongitude = 0.0; // Default value
  double originlatitude = 0.0; // Default value
  double originlongitude = 0.0; // Default value
  double mapPadding = 0;
  StreamSubscription<DocumentSnapshot>? _locationSubscription;
  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _origin = null;
    originlatitude = 0.0;
    originlongitude = 0.0;
    _destination = null;
    _fetchDestinationData();
    _requestPermission();
    _subscribeToLocationUpdates();
    _orderStream = FirebaseFirestore.instance
        .collection('orders')
        .doc(widget.getOrderID)
        .snapshots();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _subscribeToLocationUpdates() async {
    _locationSubscription = FirebaseFirestore.instance
        .collection('location')
        .doc(widget.user_id)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      _updateUserLocationOnMap(snapshot);
    });
  }

  Future<void> _updateUserLocationOnMap(DocumentSnapshot snapshot) async {
    double originLatitude = snapshot['latitude'];
    double originLongitude = snapshot['longitude'];

    setState(() {
      _origin = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: LatLng(originLatitude, originLongitude),
      );

      if (_googleMapController != null) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              LatLng(originLatitude, originLongitude),
              LatLng(destinationLatitude, destinationLongitude),
            ],
            color: Colors.blue,
            width: 5,
          ),
        );

        _googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(originLatitude, originLongitude),
              zoom: 15.0,
              tilt: 45.0,
            ),
          ),
        );
      }
    });
  }

  Future<void> _updateUserLocation(double latitude, double longitude) async {
    try {
      await FirebaseFirestore.instance.collection('location').doc(widget.user_id).set(
        {
          'latitude': latitude,
          'longitude': longitude,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Error updating user location: $e");
    }
  }

  Future<void> _fetchDestinationData() async {
    try {
      print("Fetching destination data for sellerUID: ${widget.sellerUID}");

      var sellerSnapshot =
      await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUID).get();

      if (sellerSnapshot.exists) {
        destinationLatitude = sellerSnapshot.data()!["lat"];
        destinationLongitude = sellerSnapshot.data()!["lng"];

        setState(() {
          _destination = Marker(
            markerId: MarkerId('destination'),
            infoWindow: const InfoWindow(title: 'Destination'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            position: LatLng(destinationLatitude, destinationLongitude),
          );
        });

        print("_destination: $_destination");
      } else {
        print("Seller snapshot does not exist.");
      }
    } catch (e) {
      print("Error fetching destination data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    String purchaserAddress = widget.sellerAddress ?? "...";
    String limitedAddress = purchaserAddress.length > 40 ? purchaserAddress.substring(0, 40) : purchaserAddress;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          widget.sellerAddress!,
          style: TextStyle(fontSize: 12, color: AppColors().white),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var orderData = snapshot.data!.data() as Map<String, dynamic>?;

          if (orderData == null) {
            return Center(child: Text('No order data available'));
          }

          String paymentDetails = orderData['paymentDetails'] ?? '';
          double totalAmount = orderData['totalAmount'] ?? 0.0;

          return Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                onMapCreated: (controller) {
                  _googleMapController = controller;

                  setState(() {
                    mapPadding = 350.h;
                  });
                },
                padding: EdgeInsets.only(bottom: mapPadding),
                markers: _getMarkers(),
                polylines: _polylines,
                initialCameraPosition: CameraPosition(
                  target: LatLng(originlatitude, originlongitude),
                  zoom: 15.0,
                ),
              ),
              Positioned(
                bottom: 50.0,
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.black,
                  onPressed: () {
                    _fetchDestinationData();
                  },
                  child: const Icon(Icons.location_on),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors().black,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                    child: Column(
                      children: [
                        Text(
                          "18 mins",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.lightGreenAccent,
                          ),
                        ),
                        const SizedBox(height: 18,),
                        const Divider(
                          thickness: 2,
                          height: 2,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Address: ",
                              style: TextStyle(
                                color: AppColors().white,
                                fontSize: 12.sp,
                                fontFamily: "Poppins",
                              ),
                            ),
                            SizedBox(width: 14.w,),
                            Text(
                              limitedAddress,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors().red,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Name:",
                              style: TextStyle(
                                color: AppColors().white,
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 14.w,),
                            Text(
                              widget.sellerName.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Payment Details:",
                              style: TextStyle(
                                color: AppColors().white,
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 14.w,),
                            Text(
                              paymentDetails,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Total Amount:",
                              style: TextStyle(
                                color: AppColors().white,
                                fontFamily: "Poppins",
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(width: 14.w,),
                            Text(
                              totalAmount.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24,),
                        const Divider(
                          thickness: 2,
                          height: 2,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10.0),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Handle button press
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ), backgroundColor: AppColors().red,
                          ),
                          icon: const Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 25,
                          ),
                          label: Text(
                            "Navigate",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Set<Marker> _getMarkers() {
    final Set<Marker> markers = {};

    if (_origin != null) markers.add(_origin!);
    if (_destination != null) markers.add(_destination!);

    return markers;
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted.');
      _fetchLocationData();
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _fetchLocationData() async {
    try {
      _locationSubscription = location.onLocationChanged.listen((loc.LocationData currentLocation) async {
        await _updateUserLocation(currentLocation.latitude!, currentLocation.longitude!);
      }) as StreamSubscription<DocumentSnapshot<Object?>>?;
    } catch (e) {
      print("Error fetching location data: $e");
    }
  }
}
