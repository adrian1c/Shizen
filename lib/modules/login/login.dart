import 'package:flutter_hooks/flutter_hooks.dart';

import '../../utils/allUtils.dart';
import 'package:flutter/services.dart';
import '../signup/signup.dart';
import '../../main.dart';

class EmailLogIn extends HookWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = useTextEditingController();
    TextEditingController passwordController = useTextEditingController();
    ValueNotifier _isLoading = useValueNotifier(false);
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
                              LoginField.emailValidator(value),
                          keyboardType: TextInputType.emailAddress,
                        ),
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
                              LogInButton(
                                formKey: _formKey,
                                context: context,
                                email: emailController,
                                password: passwordController,
                                isLoading: _isLoading,
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
                  child: SignUpRedirect(context: context),
                ),
              ],
            ),
          )),
    );
  }
}

class LoginField extends StatelessWidget {
  const LoginField({
    Key? key,
    required this.controller,
    required this.fieldText,
    required this.validator,
    this.widthPercentage = 1,
    this.obscureText = false,
    this.keyboardType,
  }) : super(key: key);

  final TextEditingController controller;
  final String fieldText;
  final double widthPercentage;
  final bool obscureText;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width * widthPercentage),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          style: TextStyle(color: Color(0xff58865C)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 0.0, left: 5.0),
            labelText: fieldText,
            labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
            enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Color(0xff35566D))),
          ),
          validator: validator,
        ),
      ),
    );
  }
}

class LogInButton extends StatelessWidget {
  const LogInButton(
      {Key? key,
      required this.formKey,
      required this.context,
      required this.email,
      required this.password,
      required this.isLoading})
      : super(key: key);

  final GlobalKey<FormState> formKey;
  final BuildContext context;
  final TextEditingController email;
  final TextEditingController password;
  final ValueNotifier isLoading;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, data, _) {
          if (data != true) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xff4B7586),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                minimumSize: Size(65.w, 45),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  isLoading.value = true;
                  await Provider.of<UserProvider>(context, listen: false)
                      .logInToDb(
                    email.text,
                    password.text,
                    context,
                  );
                  isLoading.value = false;
                }
              },
              child: Text(Words.enterButton,
                  style: Theme.of(context).textTheme.bodyText1),
            );
          }

          return SpinKitWave(color: Color(0xff4B7586), size: 30);
        });
  }
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
          MaterialPageRoute(
            builder: (context) => WelcomePage(),
          ));
    },
    child:
        Text(Words.cancelButton, style: Theme.of(context).textTheme.bodyText1),
  );
}

class SignUpRedirect extends StatelessWidget {
  const SignUpRedirect({Key? key, required this.context}) : super(key: key);

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?",
            style: Theme.of(context).textTheme.bodyText2),
        TextButton(
            style: TextButton.styleFrom(
              primary: Color(0xff58865C),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmailSignUp(),
                  ));
            },
            child: Text(Words.signupButton,
                style: Theme.of(context).textTheme.bodyText2)),
      ],
    );
  }
}
