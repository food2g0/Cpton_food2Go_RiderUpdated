import 'package:cpton_food2go_rider/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'global/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 873), // Design size same as the one used in ScreenUtil.init()
      builder: (context, _) => GetMaterialApp(
        title: 'Riders App',
        debugShowCheckedModeBanner: false,
        home: MySplashScreen(),
      ),
    );
  }
}



