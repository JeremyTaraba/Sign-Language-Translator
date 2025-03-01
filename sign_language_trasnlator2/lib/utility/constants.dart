import 'package:flutter/material.dart';

TextStyle kTextFieldFont() {
  return const TextStyle(fontSize: 22);
}

InputDecoration kTextFieldDecoration() {
  return InputDecoration(
    contentPadding: EdgeInsets.all(10),
    filled: true,
    fillColor: Colors.grey[200],
    hintText: "Password",
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
  );
}
