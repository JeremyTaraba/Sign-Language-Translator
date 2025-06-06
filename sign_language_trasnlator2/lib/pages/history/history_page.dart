import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utility/firebase_info.dart';

final _firestore = FirebaseFirestore.instance; //for the database

class HistoryPage extends StatefulWidget {
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final List<Map<String, String>> textHistory = [
    //Messages goes here
  ];

  Future<String> getTextDatabase() async {
    print("textDatabase");
    var docRef = _firestore.collection('chat_history').doc(loggedInUser.email);
    DocumentSnapshot doc = await docRef.get();
    final data = await doc.data() as Map<String, dynamic>;

    data.forEach((k, v) {
      String text = "";

      for (String t in v.values) {
        text += "\n$t";
      }
      Map<String, String> dayTextValue = {"date": k.toString(), "message": text};
      print(dayTextValue);
      textHistory.add(dayTextValue);
    });
    return "done";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: Text(
          'Text History',
          style: GoogleFonts.lato(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
        elevation: 5,
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<String>(
          future: getTextDatabase(),
          builder: (context, AsyncSnapshot<String> snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: textHistory.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        leading: Icon(Icons.message, color: Colors.deepOrangeAccent),
                        title: Text(
                          '${textHistory[index]['date']}:  ${textHistory[index]['message']}',
                          style: GoogleFonts.roboto(fontSize: 18),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      bottomNavigationBar: BottomNav(
        selectedIndex: 0,
      ),
    );
  }
}
