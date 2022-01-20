import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './themes/custom_theme.dart';

import './constants/words.dart';
import './constants/images.dart';

import './splashscreen.dart';
import './modules/signup/signup.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          //TODO: Make error display
          return Container(
              child: Text('Ooops', textDirection: TextDirection.ltr));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shizen',
            theme: CustomTheme.lightTheme,
            home: IntroScreen(),
          );
        }

        //TODO: Make loading screen
        return Container(
            child: Text(
          'Loading',
          textDirection: TextDirection.ltr,
        ));
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  WelcomePage({Key? key}) : super(key: key);

  final String title = "Welcome Page";

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 100, 8, 100),
          child: Column(
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                Words.appTitle,
                style: Theme.of(context).textTheme.headline1,
              ),
              Text(
                Words.appDesc,
                style: Theme.of(context).textTheme.headline2,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 50, 0, 50),
                width: (MediaQuery.of(context).size.width * 0.8),
                child: Images.bonsai,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff4B7586),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  minimumSize:
                      Size((MediaQuery.of(context).size.width * 0.65), 45),
                ),
                onPressed: () {},
                child: Text(Words.buttonLogin,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff58865C),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  minimumSize:
                      Size((MediaQuery.of(context).size.width * 0.65), 45),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailSignUp(),
                      ));
                },
                child: Text(Words.buttonSignup,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
