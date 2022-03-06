import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shizen_app/main.dart';
import 'package:shizen_app/mainscaffoldstack.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class UserProvider extends ChangeNotifier {
  String uid = '';

  bool checkLoggedIn() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print("Logged in");
      uid = user.uid;
      return true;
    }
    print("Not logged in");
    return false;
  }

  Future<void> logInToDb(
    String email,
    String password,
    BuildContext context,
  ) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    await firebaseAuth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((result) {
      this.uid = result.user!.uid;
      print("Nice ${this.uid}");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => MainScaffoldStack(),
        ),
        (route) => false,
      );
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                TextButton(
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

  Future<void> signOut(context) async {
    await FirebaseAuth.instance.signOut().then((result) {
      this.uid = '';
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
          (route) => route is WelcomePage);
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(err.message),
              actions: [
                TextButton(
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
