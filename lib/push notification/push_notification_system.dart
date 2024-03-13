import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PushNotificationSystem {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initializeCloudMessaging() async {
    // Terminated
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        // Display the order request
      }
    });

    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // Handle foreground messages
    });

    // Background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // Handle background messages
    });
  }

  Future<String?> generatingAndGetToken() async {
    String? registrationToken;


    try {
      registrationToken = await messaging.getToken();

      if (registrationToken != null && registrationToken.isNotEmpty) {
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('riders')
            .doc(currentUserId)
            .update({
          'registrationToken': registrationToken,
        });
        print('Registration token saved successfully: $registrationToken');
        print("FCM Registration Token: ");
        print(registrationToken);
      } else {
        print('Failed to get registration token');
      }
    } catch (e) {
      print('Failed to save registration token: $e');
    }

    // Subscribe to topics
    messaging.subscribeToTopic("allRiders");
    messaging.subscribeToTopic("allUsers");
    messaging.subscribeToTopic("allSellers");

    return registrationToken;
  }
}
