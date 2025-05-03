import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_language_trasnlator2/utility/bottom_nav.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, String>> textHistory = [
    {'date': '9/26', 'message': 'Hi, how are you?'},
    {'date': '9/25', 'message': 'Goodbye'},
    {'date': '9/24', 'message': 'Goodbye'},
    //Messages goes here
  ];

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
      body: Padding(
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
                  '${textHistory[index]['date']} | "${textHistory[index]['message']}"',
                  style: GoogleFonts.roboto(fontSize: 18),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNav(
        selectedIndex: 0,
      ),
    );
  }
}
