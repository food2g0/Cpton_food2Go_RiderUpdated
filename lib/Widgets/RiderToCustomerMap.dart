import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Maps/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_search_advance/google_maps_place_search_advance.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import '../theme/Colors.dart';

class RiderToCustomerMap extends StatefulWidget {
  final String user_id;
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
  String? customersUID;

  RiderToCustomerMap({
    required this.user_id,
    this.sellerAddress,
    this.purchaserId,
    this.sellerId,
    this.getOrderID,
    required this.purchaserAddress,
    this.purchaserLat,
    this.riderName,
    this.purchaserLng,
    this.riderUID,
    this.customersUID
  });

  @override
  _RiderToCustomerMapState createState() => _RiderToCustomerMapState();
}

class _RiderToCustomerMapState extends State<RiderToCustomerMap> {



  final loc.Location location = loc.Location();
  late double destinationLatitude;
  late double destinationLongitude;
  late double originlatitude;
  late double originlongitude;
  StreamSubscription<loc.LocationData>? _locationSubscription;
  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _origin = null;
    _destination = null;
    _fetchDestinationData();
    _requestPermission();
    _subscribeToLocationUpdates();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _subscribeToLocationUpdates() async {
    FirebaseFirestore.instance
        .collection('location')
        .doc(widget.user_id)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      _updateUserLocationOnMap(snapshot);
    });
  }


  Future<void> _updateUserLocationOnMap(DocumentSnapshot snapshot) async {
    double originlatitude = snapshot['latitude'];
    double originlongitude = snapshot['longitude'];

    setState(() {
      _origin = Marker(
        markerId: const MarkerId('origin'),
        infoWindow: const InfoWindow(title: 'Origin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: LatLng(originlatitude, originlongitude),
      );

      if (_googleMapController != null) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: [
              LatLng(originlatitude, originlongitude),
              LatLng(destinationLatitude, destinationLongitude),
            ],
            color: Colors.blue,
            width: 5,
          ),
        );

        _googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(originlatitude, originlongitude),
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
      print("Setting destination data directly");

      // Use the existing purchaserLat and purchaserLng
      destinationLatitude = widget.purchaserLat!;
      destinationLongitude = widget.purchaserLng!;

      setState(() {
        _destination = Marker(
          markerId: MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: LatLng(destinationLatitude, destinationLongitude),
        );
      });

      print("_destination: $_destination");
    } catch (e) {
      print("Error setting destination data: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          widget.purchaserAddress!,
          style: TextStyle(fontSize: 12, color: AppColors().white),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            onMapCreated: (controller) {
              _googleMapController = controller;
            },
            markers: _getMarkers(),
            polylines: _polylines,
            initialCameraPosition: const CameraPosition(
              target: LatLng(0.0, 0.0),
            ),
          ),
          Positioned(
            bottom: 16.0,
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
            bottom: 70.0,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColors().red, // Set the background color
                  onPrimary: Colors.white, // Set the text color
                  minimumSize: Size(200.0, 50.0), // Set the button size
                ),
                child: Text('Parcel has been Picked',
                  style: TextStyle(
                      fontFamily: "Poppins"
                  ),),
              ),
            ),
          ),
        ],
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
      _locationSubscription = location.onLocationChanged.listen((loc.LocationData currentlocation) async {
        await _updateUserLocation(currentlocation.latitude!, currentlocation.longitude!);
      });
    } catch (e) {
      print("Error fetching location data: $e");
    }
  }


}
