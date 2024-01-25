import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class MyMap extends StatefulWidget {
  final String user_id;

  MyMap(this.user_id);

  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;

  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscribeToLocationUpdates();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribeToLocationUpdates() {
    _subscription = FirebaseFirestore.instance
        .collection('location')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      mymap(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('location').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return GoogleMap(
            mapType: MapType.satellite,
            markers: createMarkers(context, snapshot),
            polylines: createPolylines(snapshot),
            initialCameraPosition: CameraPosition(
              target: LatLng(
                snapshot.data!.docs.singleWhere((element) => element.id == widget.user_id)['latitude'],
                snapshot.data!.docs.singleWhere((element) => element.id == widget.user_id)['longitude'],
              ),
              zoom: 10.47,
            ),
            onMapCreated: (GoogleMapController controller) async {
              setState(() {
                _controller = controller;
                _added = true;
              });
            },
          );
        },
      ),
    );
  }

  Set<Marker> createMarkers(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot == null || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Set(); // Return an empty set if no data or empty snapshot
    }

    final latitude = snapshot.data!.docs.singleWhere((element) => element.id == widget.user_id)['latitude'];
    final longitude = snapshot.data!.docs.singleWhere((element) => element.id == widget.user_id)['longitude'];

    return {
      Marker(
        position: LatLng(latitude, longitude),
        markerId: MarkerId('id'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueMagenta),
      ),
    };
  }

  Set<Polyline> createPolylines(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot == null || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Set(); // Return an empty set if no data or empty snapshot
    }

    List<LatLng> polylinePoints = snapshot.data!.docs.map((doc) {
      double latitude = doc['latitude'];
      double longitude = doc['longitude'];
      return LatLng(latitude, longitude);
    }).toList();

    final polylineId = PolylineId('route');
    final polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      points: polylinePoints,
    );

    return {polyline};
  }

  Future<void> mymap(QuerySnapshot snapshot) async {
    if (_controller != null) {
      await _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              snapshot.docs.singleWhere((element) => element.id == widget.user_id)['latitude'],
              snapshot.docs.singleWhere((element) => element.id == widget.user_id)['longitude'],
            ),
            zoom: 15,
          ),
        ),
      );
    }
  }
}
