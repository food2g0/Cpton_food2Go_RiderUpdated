import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/Widgets/riders_drawer.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import '../global/global.dart';
import '../mainScreen/earning_screen.dart';
import '../mainScreen/history_screen.dart';
import '../mainScreen/order_in_progress.dart';
import 'my_ratings_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? currentIndex;
  const HomeScreen({Key? key,this.currentIndex}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with SingleTickerProviderStateMixin{
  int _currentIndex = 0;
  FirebaseAuth _auth = FirebaseAuth.instance;
  int _selectedIndex = 0;
  List<Widget> _pages = [];


  @override
  void initState() {
    super.initState();
    getPerParcelDeliveryAmount();
    getRiderPreviousEarnings();

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
      backgroundColor: AppColors().white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors().red,
          ),
        ),
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Riders Dashboard",
            style: TextStyle(
              fontFamily: "Poppins",
              fontSize: 14,
              color: AppColors().white,
            ),
          ),
        ),
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
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppColors().black,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
              switch (index) {
                case 0:
                // Navigate to Home Screen
                  break;
                case 1:
                  _navigateToHistory(context);
                  break;
                case 2:
                  _navigateToEarnings(context);
                  break;
                case 3:
                  _navigateToOnDeliver(context);
                  break;
              }
            });
          },

          items: [
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset(
                    'images/home.png', color: Colors.white),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset(
                    'images/history.png', color: Colors.white),
              ),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset(
                    'images/cuba.png', color: Colors.white),
              ),
              label: 'Earnings',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 20.w,
                height: 20.h,
                child: Image.asset(

                    'images/motorbike.png', color: Colors.white),
              ),
              label: 'On Process',
            ),
          ],
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          // Change as needed
          selectedLabelStyle: TextStyle(
            fontFamily: 'Poppins', // Change the font family as needed
            fontSize: 10.sp, // Change the font size as needed
            fontWeight: FontWeight.bold, // Change the font weight as needed
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Poppins', // Change the font family as needed
            fontSize: 10.sp, // Change the font size as needed
            fontWeight: FontWeight.normal, // Change the font weight as needed
          ),
        ),
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

