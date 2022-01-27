import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './main.dart';
import './utils/allUtils.dart';
import './modules/tasks/tasks.dart';

class IntroScreen extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser != null) {
      print(currentUser);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => TaskPage(uid: currentUser!.uid)),
      );
    }
    return Center(
      child: Column(
        children: [
          Text(
            "SPLISH SPLASH",
            style: Theme.of(context).textTheme.headline2,
          )
        ],
      ),
    );
  }
}
