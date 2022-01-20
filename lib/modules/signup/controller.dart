import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import './signup.dart';
import '../../main.dart';

class SignUpController {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> registerToDb(
    TextEditingController emailController,
    TextEditingController passwordController,
    TextEditingController nameController,
    TextEditingController ageController,
    BuildContext context,
  ) async {
    await firebaseAuth
        .createUserWithEmailAndPassword(
            email: emailController.text, password: passwordController.text)
        .then((result) {
      firestore.collection('users').doc(result.user!.uid).set({
        'email': emailController.text,
        'age': ageController.text,
        'name': nameController.text,
      }).then((res) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
        );
      });
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    });
  }
}
