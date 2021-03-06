import 'package:flutter/services.dart';

import '../../utils/allUtils.dart';
import './widgets.dart';

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

  ValueNotifier _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    ageController.dispose();
    _isLoading.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 60.0, bottom: 30.0),
              child: Text(
                Words.signupDesc,
                style: CustomTheme.lightTheme.textTheme.headline1,
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
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
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
                        keyboardType: TextInputType.name,
                      ),
                      SignupField(
                        controller: ageController,
                        fieldText: Words.signupFieldAge,
                        widthPercentage: 0.25,
                        keyboardType: TextInputType.number,
                        validator: (String? value) =>
                            SignupField.ageValidator(value),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                  SignupField(
                    controller: passwordController,
                    fieldText: Words.passwordField,
                    obscureText: true,
                    validator: (String? value) =>
                        SignupField.passwordValidator(value),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                  ),
                  SignupField(
                    controller: confirmPasswordController,
                    fieldText: Words.signupFieldConfirmPassword,
                    obscureText: true,
                    validator: (String? value) =>
                        SignupField.confirmPasswordValidator(
                            passwordController.text, value),
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        signupButton(
                          _formKey,
                          context,
                          emailController,
                          passwordController,
                          nameController,
                          ageController,
                          _isLoading,
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
    );
  }
}
