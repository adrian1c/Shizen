import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import '../../main.dart';
import './widgets.dart';
import './controller.dart';
import '../../constants/words.dart';
import '../../themes/custom_theme.dart';

class EmailSignUp extends StatefulWidget {
  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController ageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Color(0xffF3F7F9)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: Text("Sign Up")),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(
                      top: 30.0, left: 20.0, bottom: 30.0),
                  child: Text(
                    Words.signupDesc,
                    style: CustomTheme.lightTheme.textTheme.headline2,
                  ),
                ),
                Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                        child: Column(children: <Widget>[
                      SignupField(
                          nameController: emailController,
                          fieldText: Words.signupFieldEmail,
                          widthPercentage: 1),
                      Row(
                        children: [
                          SignupField(
                              nameController: nameController,
                              fieldText: Words.signupFieldName,
                              widthPercentage: 0.5),
                          SignupField(
                              nameController: ageController,
                              fieldText: Words.signupFieldAge,
                              widthPercentage: 0.25),
                        ],
                      ),
                      SignupField(
                          nameController: passwordController,
                          fieldText: Words.signupFieldPassword,
                          widthPercentage: 1),
                      SignupField(
                          nameController: confirmPasswordController,
                          fieldText: Words.signupFieldConfirmPassword,
                          widthPercentage: 1),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: ConstrainedBox(
                                constraints: BoxConstraints.tightFor(
                                    width: 80, height: 35),
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Color(0xffE7B76F)),
                                        shape: MaterialStateProperty.all(
                                            RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        20.0)))),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        SignUpController().registerToDb(
                                          emailController,
                                          passwordController,
                                          nameController,
                                          ageController,
                                          context,
                                        );
                                      }
                                    },
                                    child: Text('OK',
                                        style: TextStyle(
                                            fontSize: 20,
                                            shadows: [
                                              Shadow(
                                                blurRadius: 2.0,
                                                color: Color(0xff000000),
                                                offset: Offset(1.0, 1.0),
                                              )
                                            ],
                                            letterSpacing: 3.0))),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => EmailLogIn(),
                                //     ));
                              },
                              child: Text(
                                'BACK',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xffE7B76F),
                                    shadows: [
                                      Shadow(
                                        blurRadius: 2.0,
                                        color: Color(0xff000000),
                                        offset: Offset(1.0, 1.0),
                                      )
                                    ]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ])))
              ],
            ),
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
  }
}
