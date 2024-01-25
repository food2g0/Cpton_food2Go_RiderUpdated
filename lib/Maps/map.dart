import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MapScreen extends StatefulWidget {
  final String sellerUID;
  final String user_id;

  MapScreen(QuerySnapshot<Object?> snapshot,  { required this.sellerUID,  required this.user_id});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  late double destinationLatitude;
  late double destinationLongitude;

  late LatLng initialCameraPosition;
  late GoogleMapController _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Set<Polyline> _polylines = {};
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _origin = null;
    _destination = null;
    _fetchLocationData();
    _fetchDestinationData();
    _requestPermission();
    _subscribeToLocationUpdates();
  }
  void _subscribeToLocationUpdates() {
    _subscription = FirebaseFirestore.instance
        .collection('location')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      MapScreen(snapshot, sellerUID: widget.sellerUID, user_id: '',);
    });
  }

  Future<void> _fetchLocationData() async {
    try {
      var locationData =
      await FirebaseFirestore.instance.collection('location').doc('user1').get();

      double originLatitude = locationData['latitude'];
      double originLongitude = locationData['longitude'];

      setState(() {
        initialCameraPosition = LatLng(originLatitude, originLongitude);
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Origin'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: LatLng(originLatitude, originLongitude),
        );

        _polylines.add(
          Polyline(
            polylineId: PolylineId('route'),
            points: [
              LatLng(originLatitude, originLongitude),
              LatLng(destinationLatitude, destinationLongitude),
            ],
            color: Colors.blue,
            width: 5,
          ),
        );
      });
    } catch (e) {
      print("Error fetching location data: $e");
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

          _polylines.add(
            Polyline(
              polylineId: PolylineId('route'),
              points: [
                LatLng(initialCameraPosition.latitude, initialCameraPosition.longitude),
                LatLng(destinationLatitude, destinationLongitude),
              ],
              color: Colors.blue,
              width: 5,
            ),
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
  void dispose() {
    _googleMapController.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.hybrid,
        onMapCreated: (controller) {
          _googleMapController = controller;
          _googleMapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: initialCameraPosition,
                zoom: 15.0,
              ),
            ),
          );
        },
        markers: _getMarkers(),
        polylines: _polylines,
        initialCameraPosition: CameraPosition(
          target: initialCameraPosition,
          zoom: 15.0,
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.black,
            onPressed: () {
              _googleMapController.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: initialCameraPosition,
                    zoom: 10.0,
                  ),
                ),
              );
            },
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.red,
            foregroundColor: Colors.black,
            onPressed: () {
              _centerToSellerLocation();
              _printSellerLocation();
            },
            child: const Icon(Icons.location_on),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            backgroundColor: Colors.green,
            foregroundColor: Colors.black,
            onPressed: () {
              _listenLocation();
            },
            child: const Icon(Icons.location_searching),
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

  void _centerToSellerLocation() {
    if (_destination != null) {
      _googleMapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _destination!.position.latitude,
              _destination!.position.longitude,
            ),
            northeast: LatLng(
              _destination!.position.latitude,
              _destination!.position.longitude,
            ),
          ),
          100.0,
        ),
      );
    }
  }

  void _printSellerLocation() async {
    var sellerSnapshot =
    await FirebaseFirestore.instance.collection('sellers').doc(widget.sellerUID).get();
    if (sellerSnapshot.exists) {
      double sellerLatitude = sellerSnapshot.data()!["lat"];
      double sellerLongitude = sellerSnapshot.data()!["lng"];
      print("Seller Latitude: $sellerLatitude");
      print("Seller Longitude: $sellerLongitude");
    } else {
      print("Seller data not found!");
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentLocation) async {
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': currentLocation.latitude,
        'longitude': currentLocation.longitude,
        'name': 'john',
      }, SetOptions(merge: true));
    });
  }

  Future<void> _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Location permission granted.');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
