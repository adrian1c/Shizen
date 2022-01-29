import 'package:shizen_app/utils/allUtils.dart';

class CancelButton extends StatelessWidget {
  CancelButton({Key? key, this.onPressed}) : super(key: key);

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xffF24C4C),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        minimumSize: Size((MediaQuery.of(context).size.width * 0.25), 45),
      ),
      onPressed: onPressed,
      child: Text(Words.cancelButton,
          style: Theme.of(context).textTheme.bodyText1),
    );
  }
}

class CreateButton extends StatelessWidget {
  CreateButton({Key? key, this.onPressed}) : super(key: key);

  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xff4B7586),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        minimumSize: Size((MediaQuery.of(context).size.width * 0.25), 45),
      ),
      onPressed: onPressed,
      child: Text("Create", style: Theme.of(context).textTheme.bodyText1),
    );
  }
}

class LogoutButton extends StatelessWidget {
  LogoutButton({Key? key, required this.uid, required this.context})
      : super(key: key);

  final String uid;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Color(0xff4B7586),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
        minimumSize: Size((MediaQuery.of(context).size.width * 0.25), 45),
      ),
      onPressed: () async => await Database(uid).signOut(context),
      child: Text("Logout", style: Theme.of(context).textTheme.bodyText1),
    );
  }
}
