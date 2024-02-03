import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/Widgets/progress_bar.dart';
import 'package:cpton_food2go_rider/Widgets/riders_drawer.dart';
import 'package:cpton_food2go_rider/assisstantMethod/assistant_methods.dart';
import 'package:cpton_food2go_rider/mainScreen/earning_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/history_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/my_ratings_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/order_in_progress.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  void initState() {
    super.initState();
    getPerParcelDeliveryAmount();
    getRiderPreviousEarnings();
  }


  getRiderPreviousEarnings()
  {
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get().then((snap)
    {
      previousRiderEarnings = snap.data()!["earnings"].toString();
    });
  }

  getPerParcelDeliveryAmount()
  {
    FirebaseFirestore.instance
        .collection("perDelivery")
        .doc("Xho8zZ64d1kXIUhuJ6q9")
        .get().then((snap)
    {
      perOrderDeliveryAmount = snap.data()!["amount"].toString();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration:  BoxDecoration(
            color: AppColors().red,
          ),
        ),
        title:  Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Riders Dashboard",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 14.sp,
              color: AppColors().white,
            ),
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      drawer: RidersDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Card(
              color: AppColors().white,
              elevation: 2,
              child: Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors().black,
                          ),
                          children: [
                            TextSpan(
                              text: "Welcome ",
                            ),
                            TextSpan(
                              text: sharedPreferences!.getString("name")!,
                              style: TextStyle(
                                color: AppColors().black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h,),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align to the start (left)
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Your current Ratings: ',
                                        style: TextStyle(
                                          fontFamily: "Poppins",
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors().black1,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (c)=> RatingScreen())); },
                                        child: Text("View Ratings", style:
                                          TextStyle(
                                            color: AppColors().red,
                                            fontFamily: "Poppins",
                                            fontSize: 12.sp
                                          ),),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10.h),
                                  Row(
                                    children: [
                                      SmoothStarRating(
                                        rating: averageRating,
                                        allowHalfRating: false,
                                        starCount: 5,
                                        size: 25,
                                        color: Colors.yellow,
                                        borderColor: Colors.black45,
                                      ),
                                      SizedBox(width: 5), // Adjust spacing as needed
                                      Text('${averageRating.toStringAsFixed(2)}/5.00',
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: AppColors().black1,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w600
                                      ),),

                                    ],
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
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors().black,
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
                                  ? Column(
                                children: [
                                  OrderCard(
                                    itemCount: snap.data!.docs.length,
                                    data: snap.data!.docs,
                                    orderID: snapshot.data!.docs[index].id,
                                    seperateQuantitiesList: separateOrderItemQuantities(
                                      (snapshot.data!.docs[index].data()! as Map<String, dynamic>)["productsIDs"],
                                    ),
                                    sellerName: sellerSnap.data!["sellersName"], // Pass the seller's name
                                  ),
                                  if (snap.data!.docs.length > 1)
                                    SizedBox(height: 10), // Adjust the height as needed
                                ],
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
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          canvasColor: AppColors().black, // Background color
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
              Navigator.push(context, MaterialPageRoute(builder: (c)=> HistoryScreen()));
            } else if (index == 2) {
              // Navigate to Earnings screen
              Navigator.push(context, MaterialPageRoute(builder: (c)=> EarningScreen()));

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