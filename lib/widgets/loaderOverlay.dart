import 'package:shizen_app/utils/allUtils.dart';
import 'dart:math';

class Loader extends StatelessWidget {
  const Loader({Key? key}) : super(key: key);

  final List<String> loadingMsg = const [
    'Please wait politely... I\'m working hard',
    'Making big moves...',
    'Server (over)loading...',
    'Cogs turning...',
    'Patience is the key to success...',
    'Waves be waving...',
    'Server be serving...',
    'Something is happening somewhere...',
    'I\'ll be done in a jiffy...'
  ];

  @override
  Widget build(BuildContext context) {
    var random = Random();
    var randomNum = random.nextInt(loadingMsg.length - 1);
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitWave(color: Color.fromARGB(255, 70, 79, 92), size: 30.0),
          Text(loadingMsg[randomNum],
              style: CustomTheme.loaderOverlayTextStyle),
        ],
      ),
    );
  }
}
