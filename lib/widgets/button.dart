import 'package:shizen_app/utils/allUtils.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        primary: Colors.transparent,
        shadowColor: Colors.transparent,
        minimumSize: Size((MediaQuery.of(context).size.width * 0.25), 45),
      ),
      onPressed: () => Navigator.of(context).pop(),
      child: Text(Words.cancelButton,
          style: TextStyle(
              color: CustomTheme.cancelText,
              fontSize: 15.sp,
              fontWeight: FontWeight.w600)),
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
              primary: data != false
                  ? CustomTheme.activeButton
                  : CustomTheme.greyedOutField,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              minimumSize: Size((75.w), 45),
            ),
            onPressed: data != false ? onPressed : () {},
            child: Text(buttonLabel ?? "Create",
                style: Theme.of(context).textTheme.bodyText1),
          );
        });
  }
}
