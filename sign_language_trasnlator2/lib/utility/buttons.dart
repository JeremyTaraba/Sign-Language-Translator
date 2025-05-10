import 'package:flutter/material.dart';

class _RoundedButton extends StatelessWidget {
  _RoundedButton(
      {required this.backgroundColor,
      required this.title,
      required this.onPressed,
      required this.textColor,
      this.horizontalPadding = 110});

  final Color? backgroundColor;
  final String title;
  final void Function() onPressed;
  final Color? textColor;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 8,
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 10,
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 32,
        ),
      ),
    );
  }
}

class SignUpButton extends StatelessWidget {
  SignUpButton({super.key, required this.onPressed});
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return _RoundedButton(
      backgroundColor: Colors.orange[50],
      title: "Sign up",
      onPressed: onPressed,
      textColor: Colors.deepOrangeAccent,
      horizontalPadding: 95,
    );
  }
}

class LoginButton extends StatelessWidget {
  LoginButton({super.key, required this.onPressed});
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return _RoundedButton(
      backgroundColor: Colors.deepOrangeAccent,
      title: "Login",
      onPressed: onPressed,
      textColor: Colors.orange[50],
    );
  }
}
