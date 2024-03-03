import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cpton_food2go_rider/theme/Colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Stream<DocumentSnapshot> _userDataStream;

  @override
  void initState() {
    super.initState();
    _userDataStream = FirebaseFirestore.instance
        .collection('riders')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors().backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors().red,
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors().white,
            fontSize: 12.sp,
            fontFamily: "Poppins",
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _userDataStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Update userData with the latest snapshot data
          var userData = snapshot.data!;

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              _buildProfileItem('riderName', userData['riderName']),
              _buildProfileItem('riderEmail', userData['riderEmail']),
              _buildProfileItem('phone', userData['phone']),
              // Add more profile fields as needed
            ],
          );
        },
      ),

    );
  }

  Widget _buildProfileItem(String label, String value) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: AppColors().black,
          fontFamily: "Poppins",
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(value),
      trailing: IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          _editProfileField(label, value);
        },
      ),
    );
  }

  Future<void> _editProfileField(String label, String value) async {
    String? newValue = await showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController(text: value);
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: 'New $label'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (newValue != null && newValue != value) {
      // Update the profile field in Firestore
      FirebaseFirestore.instance
          .collection('riders')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        label: newValue,
      }).then((_) {
        print('New $label: $newValue');
        // Update the _userDataStream to trigger a rebuild
        setState(() {
          _userDataStream = FirebaseFirestore.instance
              .collection('riders')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots();
        });
      }).catchError((error) {
        print('Failed to update $label: $error');
      });
    }
  }


}
