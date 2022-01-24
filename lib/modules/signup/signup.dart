import 'package:flutter/material.dart';

import './widgets.dart';
import './controller.dart';
import '../../utils/words.dart';
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
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
  }

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
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
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
                        controller: emailController,
                        fieldText: Words.emailField,
                        validator: (String? value) =>
                            SignupField.emailValidator(value),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SignupField(
                            controller: nameController,
                            fieldText: Words.signupFieldName,
                            widthPercentage: 0.5,
                            validator: (String? value) =>
                                SignupField.normalValidator(value),
                          ),
                          SignupField(
                            controller: ageController,
                            fieldText: Words.signupFieldAge,
                            widthPercentage: 0.25,
                            keyboardType: TextInputType.number,
                            validator: (String? value) =>
                                SignupField.ageValidator(value),
                          ),
                        ],
                      ),
                      SignupField(
                        controller: passwordController,
                        fieldText: Words.passwordField,
                        obscureText: true,
                        validator: (String? value) =>
                            SignupField.passwordValidator(value),
                      ),
                      SignupField(
                        controller: confirmPasswordController,
                        fieldText: Words.signupFieldConfirmPassword,
                        obscureText: true,
                        validator: (String? value) =>
                            SignupField.passwordValidator(value),
                      ),
                      Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xff4B7586),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                minimumSize: Size(
                                    (MediaQuery.of(context).size.width * 0.65),
                                    45),
                              ),
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
                              child: Text(Words.submitButton,
                                  style: Theme.of(context).textTheme.bodyText1),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: cancelButton(context),
                            ),
                          ],
                        ),
                      ),
                    ]))),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: logInRedirect(context),
                ),
              ],
            ),
          ),
        ));
  }
}
