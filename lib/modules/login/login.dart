import 'package:flutter/material.dart';

import './widgets.dart';
import './controller.dart';
import '../../utils/images.dart';
import '../../utils/words.dart';
import '../../themes/custom_theme.dart';

class EmailLogIn extends StatefulWidget {
  @override
  _EmailLogInState createState() => _EmailLogInState();
}

class _EmailLogInState extends State<EmailLogIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Color(0xffF3F7F9)),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(title: Text("Login")),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Text(
                    Words.loginDesc,
                    style: CustomTheme.lightTheme.textTheme.headline2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  width: (MediaQuery.of(context).size.width * 0.7),
                  child: Images.login,
                ),
                Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(children: <Widget>[
                        LoginField(
                            controller: emailController,
                            fieldText: Words.emailField,
                            validator: (String? value) =>
                                LoginField.emailValidator(value)),
                        LoginField(
                            controller: passwordController,
                            fieldText: Words.passwordField,
                            obscureText: true,
                            validator: (String? value) =>
                                LoginField.passwordValidator(value)),
                        Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xff4B7586),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  minimumSize: Size(
                                      (MediaQuery.of(context).size.width *
                                          0.65),
                                      45),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    LogInController().logInToDb(
                                      emailController,
                                      passwordController,
                                      context,
                                    );
                                  }
                                },
                                child: Text(Words.enterButton,
                                    style:
                                        Theme.of(context).textTheme.bodyText1),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30),
                                child: cancelButton(context),
                              ),
                            ],
                          ),
                        )
                      ]),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: signUpRedirect(context),
                ),
              ],
            ),
          )),
    );
  }
}
