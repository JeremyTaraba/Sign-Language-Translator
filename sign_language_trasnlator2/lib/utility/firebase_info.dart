import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_language_trasnlator2/utility/user_info.dart';

final _firestore = FirebaseFirestore.instance; //for the database
final auth = FirebaseAuth.instance;
late User loggedInUser;

String? userEmail = "";

void getCurrentUserInfo() async {
  try {
    // make sure user is authenticated
    final user = await auth.currentUser!;
    if (user != null) {
      loggedInUser = user; // gets the logged in user
      userEmail = loggedInUser.email;
    }
  } catch (e) {
    print(e);
  }
}

Future<String> getCurrentUsername() async {
  try {
    // make sure user is authenticated
    final user = await auth.currentUser!;
    if (user != null) {
      loggedInUser = user; // gets the logged in user
    }
    user_email = loggedInUser.email!;

    //for getting the username
    var docRef = _firestore.collection('profile_info').doc(loggedInUser.email);
    DocumentSnapshot doc = await docRef.get();
    final data = await doc.data() as Map<String, dynamic>;

    if (data["name"] != "") {
      return data["name"];
    }
  } catch (e) {
    print(e);
  }
  return "";
}
