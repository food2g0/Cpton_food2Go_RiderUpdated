
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../authentication/auth_screen.dart';
import '../global/global.dart';

class RidersDrawer extends StatelessWidget {
  const RidersDrawer({super.key });

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    print("Debug riderAvatarUrl in RidersDrawer: ${sharedPreferences?.getString("riderAvatarUrl")}");
    return Drawer(
      child: ListView(
        children: [
          Container(
            color: AppColors().black, // Set your desired background color here
            padding: const EdgeInsets.only(top: 25, bottom: 10),
            child: Column(
              children: [
                // Header of the drawer
                Material(
                  borderRadius: const BorderRadius.all(Radius.circular(80)),
                  elevation: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: CircleAvatar(
                        backgroundImage: sharedPreferences!.getString("riderAvatarUrl") != null
                            ? NetworkImage(
                          sharedPreferences!.getString("riderAvatarUrl")!.toString(),
                        )
                            : AssetImage('images/avatar.png') as ImageProvider<Object>, // Explicit cast
                      ),
                    ),
                  ),
                ),






                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.centerLeft,
                 child: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 16),
                 child: Text(
                  capitalize (sharedPreferences!.getString("name")!),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: "Roboto",
                  ),
                ),
                 )
                ),
              ],
            ),
          ),
          //body drawer

          ListTile(
            leading:  Icon(
              Icons.fastfood_rounded,
              color: AppColors().red,
            ),
            title: Text("Orders",
            style: TextStyle(
              color: AppColors().black,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
              fontSize: 14.sp
            ),),
            onTap: () {

            },
          ),
          ListTile(
            leading:  Icon(
              Icons.info_rounded,
              color: AppColors().red,
            ),
            title:  Text("About",
            style: TextStyle(
             color: AppColors().black,
              fontFamily: "Poppins",
              fontWeight: FontWeight.w500,
             fontSize: 14.sp
              ),),
            onTap: () {
              // Handle the About item tap
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite_border,
              color: AppColors().red,
            ),
            title:  Text("Favorites",
              style: TextStyle(
                  color: AppColors().black,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp
              ),),
            onTap: () {
              // Handle the Favorites item tap
            },
          ),
          ListTile(
            leading:  Icon(
              Icons.logout_rounded,
              color: AppColors().red,
            ),
            title: Text("Logout",
              style: TextStyle(
                  color: AppColors().black,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp
              ),),
            onTap: () {
              firebaseAuth.signOut().then((value){
                Navigator.push(context, MaterialPageRoute(builder: (c)=> const AuthScreen()));
              });
            },
          ),
        ],
      ),
    );
  }
}
