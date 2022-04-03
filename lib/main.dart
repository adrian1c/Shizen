import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/loaderOverlay.dart';

import './modules/signup/signup.dart';
import './modules/login/login.dart';
import './mainScaffoldStack.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(
        lazy: false,
        create: (context) => UserProvider(),
      ),
      ChangeNotifierProvider(create: (context) => TabProvider()),
      ChangeNotifierProvider(create: (context) => AppTheme())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  Future initNotifications() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();
        var initializationSettingsAndroid =
            new AndroidInitializationSettings('ic_launcher');
        var initializationSettingsIOS = new IOSInitializationSettings();
        var initializationSettings = new InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
        flutterLocalNotificationsPlugin.initialize(initializationSettings);

        var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
          Platform.isAndroid
              ? 'com.example.shizen_app'
              : 'com.example.shizen_app',
          'Flutter chat demo',
          channelDescription: 'your channel description',
          playSound: true,
          enableVibration: true,
          importance: Importance.max,
          priority: Priority.high,
        );
        var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
        var platformChannelSpecifics = new NotificationDetails(
            android: androidPlatformChannelSpecifics,
            iOS: iOSPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin.show(
            0,
            message.notification!.title,
            message.notification!.body,
            platformChannelSpecifics,
            payload: 'test');
      }
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_initialization, initNotifications()]),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          //TODO: Make error display
          return Container(
              child: Text('Ooops', textDirection: TextDirection.ltr));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Sizer(
              builder: (context, orientation, deviceType) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Shizen',
                  theme: Provider.of<AppTheme>(context).darkTheme
                      ? CustomTheme.darkTheme
                      : CustomTheme.lightTheme,
                  home: Provider.of<UserProvider>(context).checkLoggedIn()
                      ? LoaderOverlay(
                          useDefaultLoading: false,
                          overlayWidget: Loader(),
                          child: MainScaffoldStack())
                      : WelcomePage(),
                );
              },
            ),
          );
        }

        //TODO: Make loading screen
        return Center(
          child: Container(
              child: Text(
            'Nice to meet you!',
            textDirection: TextDirection.ltr,
          )),
        );
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
          padding: const EdgeInsets.fromLTRB(8, 120, 8, 0),
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
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmailLogIn(),
                      ));
                },
                child: Text(Words.loginButton,
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
                child: Text(Words.signupButton,
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
