import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:sign_language_trasnlator2/pages/history/history_page.dart';
import 'package:sign_language_trasnlator2/pages/loginRegister/register_page.dart';
import 'package:sign_language_trasnlator2/utility/buttons.dart';
import 'package:sign_language_trasnlator2/utility/constants.dart';
import 'package:sign_language_trasnlator2/utility/firebase_info.dart';
import 'package:sign_language_trasnlator2/utility/save_credentials.dart';
import 'package:sign_language_trasnlator2/utility/snackbar.dart';
import 'package:sign_language_trasnlator2/utility/user_info.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
  String password = "";
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.deepOrangeAccent,
      child: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    stops: [0.1, 0.3, 0.5],
                    colors: [Color.fromARGB(255, 252, 92, 23), Color.fromARGB(255, 255, 162, 122), Color.fromARGB(255, 255, 193, 166)],
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(
                      "Login",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 70,
                        fontFamily: "Mogra",
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight / 5),
                child: AnimatedContainer(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(50), topLeft: Radius.circular(50)),
                  ),
                  duration: const Duration(seconds: 2),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 25, top: 50),
                        child: TextField(
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            email = value;
                          },
                          style: kTextFieldFont(),
                          autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: kTextFieldDecoration().copyWith(hintText: "Email"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 25.0),
                        child: TextField(
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            password = value;
                          },
                          style: kTextFieldFont(),
                          autocorrect: false,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: kTextFieldDecoration().copyWith(hintText: "Password"),
                        ),
                      ),
                      LoginButton(onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });

                        try {
                          final user = await _auth.signInWithEmailAndPassword(email: email, password: password);
                          if (user == null) {
                            return;
                          }

                          user_Info_Name = await getCurrentUsername();

                          saveLoginCredentials(email, password);

                          Navigator.push(context, MaterialPageRoute(builder: (context) => HistoryPage()));
                        } catch (e) {
                          mySnackBar(e.toString().split(']')[1], context);
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      }),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: GestureDetector(
                          onTap: () {
                            mySnackBar("Please email management team to reset your password", context);
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 20),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: AlignmentDirectional.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(fontSize: 20),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                                  },
                                  child: const Text(
                                    "Sign up",
                                    style: TextStyle(
                                      color: Colors.deepOrangeAccent,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
