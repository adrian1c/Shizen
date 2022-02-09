import 'package:shizen_app/utils/allUtils.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("Built cancelbutton");
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xffF24C4C),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        minimumSize: Size((MediaQuery.of(context).size.width * 0.25), 45),
      ),
      onPressed: () => Navigator.of(context).pop(),
      child: Text(Words.cancelButton,
          style: Theme.of(context).textTheme.bodyText1),
    );
  }
}

class CreateButton extends StatelessWidget {
  const CreateButton({Key? key, required this.onPressed, required this.isValid})
      : super(key: key);

  final Function()? onPressed;
  final ValueNotifier isValid;

  @override
  Widget build(BuildContext context) {
    print("Built CreateButton");
    return ValueListenableBuilder(
        valueListenable: isValid,
        builder: (context, data, _) {
          return ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: data != false ? Color(0xff4B7586) : Colors.grey[400],
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              minimumSize: Size((MediaQuery.of(context).size.width * 0.25), 45),
            ),
            onPressed: data != false
                ? onPressed
                : () {
                    print("Not valid");
                  },
            child: Text("Create", style: Theme.of(context).textTheme.bodyText1),
          );
        });
  }
}

class LogoutButton extends StatefulWidget {
  LogoutButton(
      {Key? key,
      required this.uid,
      required this.context,
      required this.isLoading})
      : super(key: key);

  final String uid;
  final BuildContext context;
  final ValueNotifier isLoading;

  @override
  _LogoutButtonState createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.isLoading,
        builder: (context, data, _) {
          if (data != true) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xff4B7586),
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                minimumSize:
                    Size((MediaQuery.of(context).size.width * 0.25), 45),
              ),
              onPressed: () async {
                widget.isLoading.value = true;
                await Provider.of<UserProvider>(context, listen: false)
                    .signOut(context);
                widget.isLoading.value = false;
              },
              child:
                  Text("Logout", style: Theme.of(context).textTheme.bodyText1),
            );
          }

          return SpinKitWave(color: Color(0xff4B7586), size: 30);
        });
  }
}
