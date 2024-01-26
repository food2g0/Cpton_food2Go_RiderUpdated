
import 'package:flutter/material.dart';

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
            color: Colors.black87, // Set your desired background color here
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
                        backgroundImage: NetworkImage(
                            sharedPreferences!.getString("riderAvatarUrl").toString()
                        ),

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
            leading: const Icon(
              Icons.local_offer,
              color: Colors.red,
            ),
            title: const Text("Vouchers and Offers"),
            onTap: () {
              // Handle the Home item tap
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.fastfood_rounded,
              color: Colors.red,
            ),
            title: const Text("Orders"),
            onTap: () {

            },
          ),
          ListTile(
            leading: const Icon(
              Icons.info_rounded,
              color: Colors.red,
            ),
            title: const Text("About"),
            onTap: () {
              // Handle the About item tap
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.favorite_border,
              color: Colors.red,
            ),
            title: const Text("Favorites"),
            onTap: () {
              // Handle the Favorites item tap
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            title: const Text("Logout"),
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
