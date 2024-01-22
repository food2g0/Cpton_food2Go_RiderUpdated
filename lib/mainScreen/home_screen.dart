import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/Widgets/riders_drawer.dart';
import 'package:cpton_food2go_rider/assisstantMethod/assistant_methods.dart';
import 'package:cpton_food2go_rider/assisstantMethod/get_current_location.dart';
import 'package:flutter/material.dart';

import '../authentication/auth_screen.dart';
import '../global/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    UserLocation uLocation = UserLocation();
    uLocation.getCurrentLocation();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFA19E9F),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF890010),
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Riders Dashboard",
            style: TextStyle(
              fontFamily: "Poppins",
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      drawer: RidersDrawer(),
      body: Column(
        children: [
          Container(
            height: 150,
            width: 460,
            decoration: const ShapeDecoration(
              color: Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "Welcome ",
                      ),
                      TextSpan(
                        text: sharedPreferences!.getString("name")!,
                        style: TextStyle(
                          color: Color(0xFF890010),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "New Order",
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("orders")
                  .where("status", isEqualTo: "normal")
                  .orderBy("orderTime", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                return snapshot.hasData
                    ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("items")
                          .where("productsID",
                          whereIn: separateOrderItemIDs(
                              (snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>)[
                              "productsIDs"]))
                          .where("orderBy",
                          whereIn: (snapshot.data!.docs[index].data()!
                          as Map<String, dynamic>)["uid"])
                          .orderBy("publishedDate", descending: true)
                          .get(),
                      builder: (context, snap) {
                        return snap.hasData
                            ? OrderCard(
                          itemCount: snap.data!.docs.length,
                          data: snap.data!.docs,
                          orderID: snapshot.data!.docs[index].id,
                          seperateQuantitiesList:
                          separateOrderItemQuantities(
                              (snapshot.data!.docs[index].data()!
                              as Map<String, dynamic>)["productsIDs"]),
                        )
                            : Center(child: circularProgress());
                      },
                    );
                  },
                )
                    : Center(child: circularProgress());
              },
            ),
          ),
        ],
      ),
    );
  }
}
