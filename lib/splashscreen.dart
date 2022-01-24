import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import './main.dart';
import './utils/images.dart';

class IntroScreen extends StatelessWidget {
  Future<Widget> checkLogIn() async {
    User? result = FirebaseAuth.instance.currentUser;
    if (result != null) {
      return Future.value(new WelcomePage());
    } else {
      return Future.value(new WelcomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Images.bonsai,
      title:
          Text('SPLISH SPLASH', style: Theme.of(context).textTheme.headline2),
      backgroundColor: Colors.grey.shade200,
      showLoader: true,
      loadingText: Text("Loading..."),
      futureNavigator: checkLogIn(),
      // navigator: WelcomePage(),
      // durationInSeconds: 10,
    );
  }
}
