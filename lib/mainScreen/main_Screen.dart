import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/authentication/auth_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/earning_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/history_screen.dart';
import 'package:cpton_food2go_rider/mainScreen/order_in_progress.dart';
import 'package:cpton_food2go_rider/mainScreen/my_ratings_screen.dart';
import 'package:cpton_food2go_rider/push%20notification/push_notification_system.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:battery/battery.dart';
import '../global/global.dart';

class RiderDashboard extends StatefulWidget {
  final int? currentIndex;

  const RiderDashboard({Key? key,this.currentIndex}) : super(key: key);

  @override
  _RiderDashboardState createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard>  with SingleTickerProviderStateMixin{
  int _currentIndex = 0;
  FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  List<Widget> _pages = [];
  final Battery _battery = Battery();

  bool isRiderAvailable = false; // Flag to track rider's availability


  @override
  void initState() {
    super.initState();
    getPerParcelDeliveryAmount();
    getRiderPreviousEarnings();
    checkRiderAvailability();
    _checkBatteryLevel(); // Call method to check battery level

  }
  void checkRiderAvailability() {
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get()
        .then((snap) {
      setState(() {
        // Update isRiderAvailable based on the availability field in Firestore
        isRiderAvailable = snap.data()!["availability"] == "yes";
      });
    });
  }
  Future<void> _checkBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;
    if (batteryLevel < 15) {
      _showLowBatteryAlert(); // Show alert if battery level is lower than 15%
    }
  }
  void _showLowBatteryAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Low Battery Alert'),
          content: Text('Your device battery is lower than 15%. Please charge your device.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  getRiderPreviousEarnings() {
    FirebaseFirestore.instance
        .collection("riders")
        .doc(sharedPreferences!.getString("uid"))
        .get()
        .then((snap) {
      setState(() {
        previousRiderEarnings = snap.data()!["earnings"].toString();
      });
    });
  }

  getPerParcelDeliveryAmount() {
    FirebaseFirestore.instance
        .collection("perDelivery")
        .doc("b292YYxmdWdVF729PMoB")
        .get()
        .then((snap) {
      setState(() {
        perOrderDeliveryAmount = snap.data()!["amount"].toString();
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundWhite,
      body: Padding(
          padding: const EdgeInsets.all(8.0),

          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("riders")
                  .doc(_auth.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var status = snapshot.data!.get("status");
                if (status == "blocked") {
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('You have been blocked', style: TextStyle(color: AppColors().black,
                          fontFamily: "Poppins",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600),),
                          content: Text('You have been blocked for some reason.', style: TextStyle(fontFamily: "Poppins",
                          fontSize: 10.sp),),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(); // Close the dialog
                                // Navigate to authentication screen
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthScreen()));
                              },
                              child: Text('OK', style: TextStyle(color: AppColors().red,
                              fontFamily: "Poppins"),),
                            ),
                          ],
                        );
                      },
                    );
                  });
                  return SizedBox(); // Return an empty SizedBox while showing the AlertDialog
                }

                return Column(
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    if (isRiderAvailable)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "New Order",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors().black,
                          ),
                        ),
                      ),
                    if (isRiderAvailable)
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection("orders")
                              .where("status", isEqualTo: "To Pick")
                              .orderBy("orderTime", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }

                            // Extract orders data from snapshot
                            List<DocumentSnapshot> orders = snapshot.data!.docs;

                            // Build your UI using the orders data
                            return ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                // Extract order details from each document snapshot
                                dynamic productsData = orders[index].get("products");
                                List<Map<String, dynamic>> productList = [];
                                if (productsData != null && productsData is List) {
                                  productList =
                                  List<Map<String, dynamic>>.from(productsData);
                                }

                                print("Product List: $productList"); // Print productList

                                return Column(
                                  children: [
                                    OrderCard(
                                      itemCount: productList.length,
                                      data: productList,
                                      orderID: snapshot.data!.docs[index].id,
                                      sellerName: "", // Pass the seller's name
                                      paymentDetails:
                                      snapshot.data!.docs[index].get("paymentDetails"),
                                      totalAmount:
                                      snapshot.data!.docs[index].get("totalAmount").toString(),
                                      cartItems: productList, // Pass the products list
                                    ),
                                    if (productList.length > 1)
                                      SizedBox(height: 10), // Adjust the height as needed
                                  ],
                                );

                              },
                            );
                          },
                        ),
                      ),
                    if (!isRiderAvailable) // Conditionally render based on rider's availability
                      Center(
                        child: Text(
                          "You are currently not available for new orders.",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 14,
                            color: AppColors().black,
                          ),
                        ),
                      ),

                  ],

                );
              }
          )

      ),


    );
  }
  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          HistoryScreen()), // Replace HistoryScreen with the actual screen you want to navigate to
    );
  }

  void _navigateToEarnings(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => EarningScreen()));
  }


} void _navigateToOnDeliver(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => OrderInProgress()), // Replace NotificationScreen with the actual screen you want to navigate to
  );
}



class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Home Tab Content'),
    );
  }
}

class HistoryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String riderUID = FirebaseAuth.instance.currentUser!.uid;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors().red,
          title: Text("History",
            style: TextStyle(
              fontSize: 14.sp,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w700,
              color: AppColors().white,
            ),),
        ),

        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("orders")
              .where("status", isEqualTo: "rated")
              .where("riderUID", isEqualTo: riderUID) // Filter by rider ID
              .orderBy("orderTime", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            // Extract orders data from snapshot
            List<DocumentSnapshot> orders = snapshot.data!.docs;

            // Build your UI using the orders data
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                // Extract order details from each document snapshot
                dynamic productsData = orders[index].get("products");
                List<Map<String, dynamic>> productList = [];
                if (productsData != null && productsData is List) {
                  productList =
                  List<Map<String, dynamic>>.from(productsData);
                }

                print("Product List: $productList"); // Print productList

                return Column(
                  children: [
                    OrderCard(
                      itemCount: productList.length,
                      data: productList,
                      orderID: snapshot.data!.docs[index].id,
                      sellerName: "", // Pass the seller's name
                      paymentDetails:
                      snapshot.data!.docs[index].get("paymentDetails"),
                      totalAmount: snapshot.data!.docs[index].get("totalAmount").toString(),
                      cartItems: productList, // Pass the products list
                    ),
                    if (productList.length > 1)
                      SizedBox(height: 10), // Adjust the height as needed
                  ],
                );
              },
            );
          },
        ),

      ),
    );
  }
}

class NewOrderTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('New Order Tab Content'),
    );
  }

}
