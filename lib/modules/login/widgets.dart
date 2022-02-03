import '../../utils/allUtils.dart';
import '../signup/signup.dart';
import '../../main.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../mainScaffoldStack.dart';

class LoginField extends StatelessWidget {
  const LoginField({
    Key? key,
    required this.controller,
    required this.fieldText,
    required this.validator,
    this.widthPercentage = 1,
    this.obscureText = false,
  }) : super(key: key);

  final TextEditingController controller;
  final String fieldText;
  final double widthPercentage;
  final bool obscureText;
  final String? Function(String?) validator;

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

Widget loginButton(
  GlobalKey<FormState> _formKey,
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
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
                await Provider.of<UserProvider>(context, listen: false)
                    .logInToDb(
                  emailController,
                  passwordController,
                  context,
                );
                _isLoading.value = false;
              }
            },
            child: Text(Words.enterButton,
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
          MaterialPageRoute(
            builder: (context) => WelcomePage(),
          ));
    },
    child:
        Text(Words.cancelButton, style: Theme.of(context).textTheme.bodyText1),
  );
}

Widget signUpRedirect(BuildContext context) {
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
