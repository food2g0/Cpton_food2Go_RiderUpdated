import 'package:flutter/cupertino.dart';

class ShipmentScreen extends StatefulWidget {

  String? purchaserId;
  String? sellerId;
  String? getOrderID;
  String? purchaserAddress;
  double? purchaserLat;
  double? purchaserLng;

  ShipmentScreen({
    this.sellerId,
    this.getOrderID,
    this.purchaserAddress,
    this.purchaserId,
    this.purchaserLat,
    this.purchaserLng,
});


  @override
  State<ShipmentScreen> createState() => _ShipmentScreenState();
}

class _ShipmentScreenState extends State<ShipmentScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
