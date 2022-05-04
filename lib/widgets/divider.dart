import 'package:shizen_app/utils/allUtils.dart';

class TextDivider extends StatelessWidget {
  const TextDivider(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Row(children: <Widget>[
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 0.0, right: 10.0),
              child: Divider(
                color: Colors.black,
                height: 5.h,
              )),
        ),
        Text(
          text,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 10.0, right: 0.0),
              child: Divider(
                color: Colors.black,
                height: 5.h,
              )),
        ),
      ]),
    );
  }
}
