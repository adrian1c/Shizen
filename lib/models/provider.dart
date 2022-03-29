import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shizen_app/main.dart';
import 'package:shizen_app/mainscaffoldstack.dart';

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
  int profileUser = 0;
  int profilePosts = 0;

  void changeTabPage(index) {
    selectedIndex = index;
    pageController.jumpToPage(selectedIndex);
    notifyListeners();
  }

  void resetPageIndex() {
    selectedIndex = 0;
    pageController.jumpToPage(selectedIndex);
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
      case 'profileUser':
        profileUser++;
        break;
      case 'profilePosts':
        profilePosts++;
        break;
      default:
        print('Not a valid page');
    }
    notifyListeners();
    print(todo);
  }
}
