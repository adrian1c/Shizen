import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/utils/allUtils.dart';

class TextDivider extends StatelessWidget {
  const TextDivider(this.text, {Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: SizedBox(
          height: 3.h,
          child: Row(children: <Widget>[
            Expanded(
              child: new Container(
                  margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                  child: Divider(
                    color: Theme.of(context).primaryColor,
                    height: 5.h,
                  )),
            ),
            Text(
              text,
              style: TextStyle(
                  height: 1,
                  fontWeight: FontWeight.w200,
                  color: Theme.of(context).primaryColor),
            ),
            Expanded(
              child: new Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 0.0),
                  child: Divider(
                    color: Theme.of(context).primaryColor,
                    height: 5.h,
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}

class AnimatedTextDivider extends HookWidget {
  const AnimatedTextDivider(this.text, this.indexValue, {Key? key})
      : super(key: key);

  final List<String> text;
  final ValueNotifier<int> indexValue;

  @override
  Widget build(BuildContext context) {
    final nameList = List.generate(
        text.length,
        (index) => AnimatedOpacity(
              opacity: indexValue.value == index ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Row(children: <Widget>[
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 1.h,
                      )),
                ),
                Text(text[index],
                    style: TextStyle(
                        height: 1,
                        fontWeight: FontWeight.w200,
                        color: Theme.of(context).primaryColor)),
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 10.0, right: 0.0),
                      child: Divider(
                        color: Theme.of(context).primaryColor,
                        height: 1.h,
                      )),
                ),
              ]),
            ));
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
            color: CustomTheme.dividerBackground,
            boxShadow: CustomTheme.boxShadow),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              Stack(alignment: Alignment.center, children: nameList),
            ],
          ),
        ),
      ),
    );
  }
}
