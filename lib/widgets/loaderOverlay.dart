import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shizen_app/utils/allUtils.dart';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitWave(color: Colors.blue, size: 50.0),
          Text('Please wait politely... I\'m working hard',
              style: CustomTheme.lightTheme.textTheme.bodyText1),
        ],
      ),
    );
  }
}
