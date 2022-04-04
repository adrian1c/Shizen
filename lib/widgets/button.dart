import 'package:shizen_app/utils/allUtils.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
  const CreateButton(
      {Key? key,
      required this.onPressed,
      required this.isValid,
      this.buttonLabel})
      : super(key: key);

  final Function()? onPressed;
  final ValueNotifier isValid;
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) {
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
            onPressed: data != false ? onPressed : () {},
            child: Text(buttonLabel ?? "Create",
                style: Theme.of(context).textTheme.bodyText1),
          );
        });
  }
}
