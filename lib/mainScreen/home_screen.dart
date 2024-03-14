import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/Widgets/order_card.dart';
import 'package:cpton_food2go_rider/Widgets/riders_drawer.dart';
import 'package:cpton_food2go_rider/mainScreen/main_Screen.dart';
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

  bool isRiderAvailable = false; // Flag to track rider's availability


  @override
  void initState() {
    super.initState();
    _pages = [
       RiderDashboard(),
      HistoryScreen(),
      EarningsScreen(),
      OrderInProgress(),
    ];
  }
  void _onItemTapped(int index) {
    setState(() {
      if (index >= 0 && index < _pages.length) {
        _selectedIndex = index;
      }
    });
  }
@override
Widget build(BuildContext context)
{
  if (_selectedIndex != 0) {
    return Scaffold(
      body: _pages[_selectedIndex],
        bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: AppColors().black,
        ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors().red
            ),
            child: BottomNavigationBar(
              items:<BottomNavigationBarItem> [
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
              currentIndex: _selectedIndex,
              selectedItemColor: AppColors().white,
              unselectedItemColor: AppColors().white,
              selectedLabelStyle:  TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
                fontSize: 10.sp,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontFamily: "Poppins",
              ),
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }else{
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
      child: Scaffold(
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SafeArea(
              child: _pages[_selectedIndex],
            ),
            ),
          ],
        ),
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            canvasColor: AppColors().black,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors().red
              ),
              child: BottomNavigationBar(
                items:<BottomNavigationBarItem> [
                  BottomNavigationBarItem(
                    icon: Container(
                      width: 20.w,
                      height: 20.h,
                      child: Image.asset(
                          'images/home.png', color: AppColors().white1 ),
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      width: 20.w,
                      height: 20.h,
                      child: Image.asset(
                          'images/history.png', color: AppColors().white1 ),
                    ),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      width: 20.w,
                      height: 20.h,
                      child: Image.asset(
                          'images/cuba.png', color: AppColors().white1 ),
                    ),
                    label: 'Earnings',
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      width: 20.w,
                      height: 20.h,
                      child: Image.asset(

                          'images/motorbike.png', color: AppColors().white1 ),
                    ),
                    label: 'On Process',
                  ),
                ],
                currentIndex: _selectedIndex,
                selectedItemColor: AppColors().white,
                unselectedItemColor: AppColors().white,
                selectedLabelStyle:  TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                  fontSize: 10.sp,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamily: "Poppins",
                ),
                onTap: _onItemTapped,
              ),
            ),
          ),
        ),

      ),
    );
  }
  }
}


