import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:month_year_picker/month_year_picker.dart';

import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/loaderOverlay.dart';
import 'package:shizen_app/widgets/onboarding.dart';

import './modules/signup/signup.dart';
import './modules/login/login.dart';
import './mainScaffoldStack.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shizen_app/utils/notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  await NotificationService().initNotifications();
  var sp = await SharedPreferences.getInstance();
  var theme = sp.getInt('darkTheme');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserProvider>(
        lazy: false,
        create: (context) => UserProvider(),
      ),
      ChangeNotifierProvider(create: (context) => TabProvider()),
      ChangeNotifierProvider(
          create: (context) =>
              AppTheme(darkTheme: theme != null ? true : false))
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  Future getOnboarding() async {
    final pref = await SharedPreferences.getInstance();
    var result = pref.getBool('onboarding');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return GlobalLoaderOverlay(
              useDefaultLoading: false,
              overlayWidget: Loader(),
              overlayOpacity: 0.85,
              child: MaterialApp(
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  MonthYearPickerLocalizations.delegate,
                ],
                scrollBehavior: MyCustomScrollBehavior(),
                debugShowCheckedModeBanner: false,
                title: 'Shizen',
                theme: Provider.of<AppTheme>(context).darkTheme
                    ? CustomTheme.darkTheme
                    : CustomTheme.lightTheme,
                home: Provider.of<UserProvider>(context).checkLoggedIn()
                    ? FutureBuilder(
                        future: getOnboarding(),
                        builder: (context, data) {
                          if (data.hasData && data.data == true) {
                            return MainScaffoldStack();
                          }

                          if (data.hasData && data.data == false) {
                            return OnboardingPage();
                          }

                          return SpinKitWanderingCubes(
                            color: Theme.of(context).primaryColor,
                            size: 75.0,
                          );
                        })
                    : WelcomePage(),
              ));
        },
      ),
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
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 120, 8, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  Words.appTitle,
                  style: CustomTheme.titleTextStyle,
                ),
                Text(
                  Words.appDesc,
                  style: Theme.of(context)
                      .textTheme
                      .headline2!
                      .copyWith(color: Colors.black),
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
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: EmailLogIn()));
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
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: EmailSignUp()));
                  },
                  child: Text(Words.signupButton,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
