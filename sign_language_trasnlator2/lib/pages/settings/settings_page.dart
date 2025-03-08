import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sign_language_trasnlator2/utility/firebase_info.dart';
import 'package:sign_language_trasnlator2/utility/save_credentials.dart';
import 'package:sign_language_trasnlator2/utility/user_info.dart';

final _firestore = FirebaseFirestore.instance;

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepOrangeAccent,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.orange[50],
            body: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  profileData("Name", user_Info_Name),
                  //profileData("Age", "22"),

                  profileData("Email", auth.currentUser?.email),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton(
                          onPressed: () {
                            auth.signOut();
                            deleteLoginCredentials();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Logout",
                            style: TextStyle(fontSize: 34),
                          )),
                    ),
                  )
                ],
              ),
            ),
            bottomNavigationBar: BottomNav(
              selectedIndex: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget profileData(String title, String? Data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 30.0),
            child: Text(
              "$title",
              style: TextStyle(fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.deepOrangeAccent, width: 3),
              ),
              child: Center(
                child: Text(
                  "$Data",
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
