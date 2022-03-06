import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shizen_app/utils/allUtils.dart';

class LoaderOverlay extends StatelessWidget {
  const LoaderOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SpinKitWave(color: Colors.blue, size: 50.0),
        Text('Please wait politely... I\'m working hard',
            style: CustomTheme.lightTheme.textTheme.bodyText1),
      ],
    );
  }
}
