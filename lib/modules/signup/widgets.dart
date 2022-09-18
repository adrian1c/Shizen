import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shizen_app/widgets/field.dart';

import '../../utils/allUtils.dart';
import '../login/login.dart';
import '../../main.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SignupField extends StatelessWidget {
  const SignupField({
    Key? key,
    required this.controller,
    required this.fieldText,
    required this.validator,
    this.widthPercentage = 1,
    this.keyboardType,
    this.obscureText = false,
    this.inputFormatters = const [],
  }) : super(key: key);

  final TextEditingController controller;
  final String fieldText;
  final double widthPercentage;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?) validator;
  final List<TextInputFormatter> inputFormatters;

  static String? emailValidator(String? value) {
    String valueString = value as String;
    if (valueString.isEmpty) {
      return "Enter an Email Address";
    } else if (!valueString.contains('@')) {
      return "Please enter a valid email address";
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    String valueString = value as String;
    if (valueString.isEmpty) {
      return "Enter password";
    } else if (valueString.length < 8) {
      return "Your password must be longer than 8 characters";
    }
    return null;
  }

  static String? confirmPasswordValidator(
      String? passValue, String? confValue) {
    String passVal = passValue as String;
    String confVal = confValue as String;
    if (confVal.isEmpty) {
      return "Enter password";
    } else if (confVal.length < 8) {
      return "Your password must be longer than 8 characters";
    } else if (confValue != passVal) {
      return "The two passwords are not the same";
    }
    return null;
  }

  static String? ageValidator(String? value) {
    String valueString = value as String;
    if (valueString.isEmpty) {
      return "You have not filled anything in";
    } else if (int.parse(valueString) > 130) {
      return "That is not a realistic age!";
    }
    return null;
  }

  static String? normalValidator(String? value) {
    String valueString = value as String;
    if (valueString.isEmpty) {
      return "You have not filled anything in";
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width * widthPercentage),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          style: TextStyle(color: Color(0xff58865C)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 0.0, left: 5.0),
            labelText: fieldText,
            labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
            enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Color(0xff35566D))),
          ),
          // The validator receives the text that the user has entered.
          validator: validator,
        ),
      ),
    );
  }
}

List<String> generateSearchKeywords(String name, String email) {
  List<String> results = [];
  name = name.toLowerCase().replaceAll(' ', '');
  email = email.toLowerCase().replaceAll(' ', '');

  var currName = name.substring(0, 3);
  for (var i = 3; i < name.length; i++) {
    currName += name[i];
    results.add(currName);
  }

  var currEmail = email.substring(0, 3);
  for (var i = 3; i < email.length; i++) {
    currEmail += email[i];
    results.add(currEmail);
  }

  return results;
}

Future<void> registerToDb(
  TextEditingController emailController,
  TextEditingController passwordController,
  TextEditingController nameController,
  TextEditingController ageController,
  BuildContext context,
) async {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  await LoaderWithToast(
          context: context,
          api: firebaseAuth
              .createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text)
              .then((result) async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('onboarding', false);
            await firestore.collection('users').doc(result.user!.uid).set({
              'email': emailController.text.trim(),
              'age': ageController.text.trim(),
              'name': nameController.text.trim(),
              'image': '',
              'friendCount': 0,
              'private': false,
              'searchKeywords': generateSearchKeywords(
                  nameController.text.trim(), emailController.text.trim())
            });
            await result.user!.sendEmailVerification();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()),
            );
            StyledPopup(
                    context: context,
                    title: 'Success!',
                    children: [
                      Text(
                          'An email has been sent to ${result.user!.email}. Please click on the link in the email to verify your account before logging in. If you cannot find the email, please check your SPAM folder too!'),
                    ],
                    cancelText: 'OK')
                .showPopup();
          }),
          msg: 'Success!',
          isSuccess: true)
      .show();
}

Widget signupButton(
  GlobalKey<FormState> _formKey,
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
  TextEditingController nameController,
  TextEditingController ageController,
  ValueNotifier _isLoading,
) {
  return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, data, _) {
        if (data != true) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xff4B7586),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              minimumSize: Size((MediaQuery.of(context).size.width * 0.65), 45),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _isLoading.value = true;
                await registerToDb(
                  emailController,
                  passwordController,
                  nameController,
                  ageController,
                  context,
                );
                _isLoading.value = false;
              }
            },
            child: Text(Words.submitButton,
                style: Theme.of(context).textTheme.bodyText1),
          );
        }

        return SpinKitWave(color: Color(0xff4B7586), size: 30);
      });
}

Widget cancelButton(BuildContext context) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: Color(0xffF24C4C),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      minimumSize: Size((MediaQuery.of(context).size.width * 0.65), 45),
    ),
    onPressed: () {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.leftToRight, child: WelcomePage()));
    },
    child:
        Text(Words.cancelButton, style: Theme.of(context).textTheme.bodyText1),
  );
}

Widget logInRedirect(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(Words.signupFieldHaveAccount,
          style: Theme.of(context).textTheme.bodyText2),
      TextButton(
          style: TextButton.styleFrom(
            primary: Color(0xff58865C),
          ),
          onPressed: () {
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.fade, child: EmailLogIn()));
          },
          child: Text(Words.loginButton,
              style: Theme.of(context).textTheme.bodyText2!.copyWith(
                  color: Color.fromARGB(255, 33, 63, 119),
                  decoration: TextDecoration.underline))),
    ],
  );
}
