import '../../utils/allUtils.dart';
import './widgets.dart';

class EmailLogIn extends StatefulWidget {
  @override
  _EmailLogInState createState() => _EmailLogInState();
}

class _EmailLogInState extends State<EmailLogIn> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  ValueNotifier _isLoading = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    _isLoading.dispose();
  }

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
                              loginButton(
                                _formKey,
                                context,
                                emailController,
                                passwordController,
                                _isLoading,
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
