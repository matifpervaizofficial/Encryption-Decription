// ignore_for_file: prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../widgets/btn.dart';
import '../widgets/customfield.dart';
import 'login.dart';

class ForgitPassword extends StatefulWidget {
  static const String idScreen = 'forgotpass';

  const ForgitPassword({super.key});

  @override
  State<ForgitPassword> createState() => _ForgitPasswordState();
}

class _ForgitPasswordState extends State<ForgitPassword> {
  final TextEditingController _email = TextEditingController();
  //key for handling Auth
  final GlobalKey<FormState> formGlobalKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("Password reset email sent successfully");
    } catch (e) {
      print("Failed to send password reset email: $e");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff011826), // Customize the background color

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Form(
            key: formGlobalKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 300,
                ),
                const Text(
                  "Reset Your Password",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFieldInput(
                    validator: (value) {
                      if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    textEditingController: _email,
                    hintText: "Enter Your Email",
                    textInputType: TextInputType.visiblePassword),
                const SizedBox(
                  height: 30,
                ),
                MyCustomButton(
                    title: "Save",
                    borderrad: 25,
                    onaction: () {
                      if (formGlobalKey.currentState!.validate()) {
                        resetPassword(_email.text);
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "user is successfuly logged In ",
                            style: TextStyle(color: Colors.white),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.red,
                        ));
                      } else
                        // ignore: curly_braces_in_flow_control_structures
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            "Please a valid email address",
                            style: TextStyle(color: Colors.white),
                          ),
                          duration: const Duration(seconds: 1),
                          backgroundColor: Colors.red,
                        ));
                    },
                    color1: Colors.red,
                    color2: Colors.red,
                    width: MediaQuery.of(context).size.width - 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
