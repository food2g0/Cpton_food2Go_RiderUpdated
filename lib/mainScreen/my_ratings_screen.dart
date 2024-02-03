import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../theme/Colors.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({Key? key}) : super(key: key);

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: AppColors().white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: AppColors().red,
        title: Text(
          "My Ratings",
          style: TextStyle(
            color: AppColors().white,
            fontFamily: "Poppins",
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("riders")
            .doc(_auth.currentUser!.uid)
            .collection("ridersRecord")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Process the ratings data
          var ratings = snapshot.data!.docs
              .map((doc) {
            final rating = (doc.data() as Map<String, dynamic>)['rating'] as num?;
            final comment = (doc.data() as Map<String, dynamic>)['comment'] as String?;
            return {'rating': rating, 'comment': comment};
          })
              .toList();

          // Retrieve the average rating
          double totalRating = ratings.fold(0, (sum, ratingData) => sum + ((ratingData['rating'] as num?) ?? 0));
          double averageRating = ratings.isNotEmpty ? totalRating / ratings.length : 0;

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Card(
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your current Ratings: ',
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors().black,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SmoothStarRating(
                            rating: averageRating,
                            allowHalfRating: false,
                            starCount: 5,
                            size: 35,
                            color: AppColors().black,
                            borderColor: AppColors().black1,
                          ),
                          SizedBox(width: 15),
                          Text(
                            '${averageRating.toStringAsFixed(2)}/5.00',
                            style: TextStyle(
                              fontFamily: "Poppins",
                              color: AppColors().black1,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: ratings.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.sp),
                            child: Card(
                              elevation: 3.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.sp),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SmoothStarRating(
                                      rating: (ratings[index]['rating'] as num?)?.toDouble() ?? 0.0,
                                      allowHalfRating: false,
                                      starCount: 5,
                                      size: 20,
                                      color: Colors.yellow,
                                      borderColor: Colors.black45,
                                    ),
                                    SizedBox(height: 15.h),
                                    Text(
                                      'Comment: ${(ratings[index]['comment'] as String?) ?? ""}',
                                      style: TextStyle(
                                        fontFamily: "Poppins",
                                        color: AppColors().black1,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
