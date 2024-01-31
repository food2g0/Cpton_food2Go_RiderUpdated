import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/Widgets/riders_drawer.dart';
import 'package:cpton_food2go_rider/assisstantMethod/assistant_methods.dart';
import 'package:cpton_food2go_rider/mainScreen/order_in_progress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../authentication/auth_screen.dart';
import '../global/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF890010),
          ),
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Riders Dashboard",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 16,
              color: Colors.white70,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
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
                    SizedBox(height: 10,),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("riders")
                          .doc(_auth.currentUser!.uid)
                          .collection("ridersRecord")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        // Process the ratings data
                        var ratings = snapshot.data!.docs
                            .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as num?)
                            .toList();

                        // Retrieve the average rating
                        double averageRating = 0;
                        if (ratings.isNotEmpty) {
                          var totalRating = ratings
                              .map((rating) => rating ?? 0)
                              .reduce((a, b) => a + b);
                          averageRating = totalRating / ratings.length;
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  'Your current Ratings: ${averageRating.toStringAsFixed(2)}/5.00',
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 10),
                                SmoothStarRating(
                                  rating: averageRating,
                                  allowHalfRating: false,
                                  starCount: 5,
                                  size: 30,
                                  color: Colors.yellow,
                                  borderColor: Colors.black45,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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
                fontWeight: FontWeight.w700,
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
                    // Get seller's UID
                    String sellerUID =
                    (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["sellerUID"];

                    return FutureBuilder<QuerySnapshot>(
                      future: FirebaseFirestore.instance
                          .collection("items")
                          .where(
                        "productsID",
                        whereIn: separateOrderItemIDs(
                          (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"],
                        ),
                      )
                          .where(
                        "orderBy",
                        whereIn: (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["uid"],
                      )
                          .orderBy("publishedDate", descending: true)
                          .get(),
                      builder: (context, snap) {
                        return snap.hasData
                            ? FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("sellers")
                              .doc(sellerUID)
                              .get(),
                          builder: (context, sellerSnap) {
                            return sellerSnap.hasData
                                ? OrderCard(
                              itemCount: snap.data!.docs.length,
                              data: snap.data!.docs,
                              orderID: snapshot.data!.docs[index].id,
                              seperateQuantitiesList: separateOrderItemQuantities(
                                (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"],
                              ),
                              sellerName: sellerSnap.data!["sellersName"], // Pass the seller's name
                            )
                                : Center(child: circularProgress());
                          },
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
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: Color(0xFF890010), // Background color
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            // Handle navigation to different screens based on index
            if (index == 0) {
              // Navigate to Home screen
            } else if (index == 1) {
              // Navigate to History screen
            } else if (index == 2) {
              // Navigate to Earnings screen
            } else if (index == 3) {
              // Navigate to Ongoing Delivery screen
              Navigator.push(context, MaterialPageRoute(builder: (c) => OrderInProgress()));
            }
          },
          selectedItemColor: Colors.white, // Selected item color
          unselectedItemColor: Colors.grey, // Unselected item color
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.monetization_on),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.delivery_dining),
              label: 'Ongoing Delivery',
            ),
          ],
        ),
      ),
    );
  }
}