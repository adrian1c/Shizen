import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shizen_app/main.dart';
import 'package:shizen_app/mainscaffoldstack.dart';
import 'package:shizen_app/models/user.dart';
import 'package:shizen_app/widgets/onboarding.dart';

class UserProvider extends ChangeNotifier {
  UserModel user = UserModel('', '', '', '', '');

  bool checkLoggedIn() {
    var currUser = FirebaseAuth.instance.currentUser;
    if (currUser != null) {
      user.uid = currUser.uid;
      FirebaseFirestore.instance
          .collection('users')
          .doc(this.user.uid)
          .get()
          .then((value) {
        var data = value.data();
        user.name = data!['name'];
        user.email = data['email'];
        user.age = data['age'];
        user.image = data['image'];
      });
      return true;
    }
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
        .then((result) async {
      user.uid = result.user!.uid;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(this.user.uid)
          .get()
          .then((value) {
        var data = value.data();
        user.name = data!['name'];
        user.email = data['email'];
        user.age = data['age'];
        user.image = data['image'];
      });
      await FirebaseMessaging.instance.getToken().then((value) {
        String? token = value;
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'pushToken': token}, SetOptions(merge: true));
      });
      final pref = await SharedPreferences.getInstance();
      var onboarding = pref.getBool('onboarding');
      if (onboarding != true) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => OnboardingPage(),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => MainScaffoldStack(),
          ),
          (route) => false,
        );
      }
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({'pushToken': null}, SetOptions(merge: true));
    await FirebaseAuth.instance.signOut().then((result) {
      user = UserModel('', '', '', '', '');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WelcomePage()),
          (route) => route is WelcomePage);

      Provider.of<TabProvider>(context, listen: false).resetPageIndex();
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

class TabProvider extends ChangeNotifier {
  int selectedIndex = 0;
  PageController pageController = PageController();
  int todo = 0;
  int tracker = 0;
  int community = 0;
  int comment = 0;
  int progress = 0;
  int profileUser = 0;
  int profileTracker = 0;
  int profileTodo = 0;
  int profilePosts = 0;
  bool communityLoad = false;

  void changeTabPage(index) {
    selectedIndex = index;
    pageController.animateToPage(
      selectedIndex,
      curve: Curves.linear,
      duration: Duration(milliseconds: 600),
    );
    notifyListeners();
  }

  void resetPageIndex() {
    selectedIndex = 0;
    pageController.jumpToPage(selectedIndex);
  }

  void rebuildCommunity() {
    communityLoad = !communityLoad;
    notifyListeners();
  }

  void rebuildPage(page) {
    switch (page) {
      case 'todo':
        todo++;
        break;
      case 'tracker':
        tracker++;
        break;
      case 'community':
        community++;
        break;
      case 'comment':
        comment++;
        break;
      case 'progress':
        progress++;
        break;
      case 'profileUser':
        profileUser++;
        break;
      case 'profileTodo':
        profileTodo++;
        break;
      case 'profileTracker':
        profileTracker++;
        break;
      case 'profilePosts':
        profilePosts++;
        break;
      default:
        break;
    }
    notifyListeners();
  }
}

class AppTheme extends ChangeNotifier {
  AppTheme({required this.darkTheme});

  final _prefs = SharedPreferences.getInstance();
  bool darkTheme;

  Future toggleTheme() async {
    final prefs = await _prefs;
    if (darkTheme) {
      darkTheme = false;
      await prefs.remove('darkTheme');
    } else {
      darkTheme = true;
      await prefs.setInt('darkTheme', 1);
    }
    notifyListeners();
  }
}
