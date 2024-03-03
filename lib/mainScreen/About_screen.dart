import 'package:carousel_slider/carousel_slider.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final List<String> images = [
    'images/image-1.jpg',
    'images/image-2.jpg',
    'images/image-3.jpg',
    // Add more image paths as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'About',
          style: TextStyle(
            color: AppColors().white,
            fontFamily: "Poppins",
            fontSize: 12.sp,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 200,
                aspectRatio: 16 / 9,
                viewportFraction: 0.8,
                initialPage: 0,
                enableInfiniteScroll: true,
                reverse: false,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 5),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
                enlargeCenterPage: true,
                scrollDirection: Axis.horizontal,
              ),
              items: images.map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Image.asset(
                        image,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.0),
              child: Text(
                'A Capstone Project of students in Pinamalayan Maritime Foundation and Technological '
                    'College Inc., Food2Go to be launched'
                    ' at Pinamalayan Oriental Mindoro this 2024 as a food delivery platform. '
                    ' Dedicated to helping customers get their tasty favourites '
                    'fast, it will quickly won the hearts and minds of customers in APAC',
                style: TextStyle(
                  color: AppColors().black,
                  fontSize: 12.0.sp,
                  fontFamily: "Poppins"
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
