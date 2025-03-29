import 'package:flutter/material.dart';
import 'package:sign_language_trasnlator2/pages/loginRegister/register_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// TODO: Camera is broken, will fix it next time using normal camera https://medium.com/@imthiyasv81450/object-detection-using-tensorflow-lite-model-in-flutter-d19b66ddf8d2

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Language Translator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      home: const RegisterPage(),
    );
  }
}
