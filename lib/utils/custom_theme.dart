import 'package:google_fonts/google_fonts.dart';
import './allUtils.dart';
import '../modules/tasks/tasks.dart';
import '../modules/friends/friends.dart';
import '../modules/community/community.dart';

class CustomTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Color(0xff4B7586),
      scaffoldBackgroundColor: Color(0xffF3F7F9),
      fontFamily: GoogleFonts.sourceSansPro().fontFamily,
      textTheme: TextTheme(
        //Title
        headline1: TextStyle(
          color: Color(0xff4B7586),
          fontSize: 50,
          fontFamily: GoogleFonts.libreFranklin().fontFamily,
          fontWeight: FontWeight.w900,
          letterSpacing: 15.0,
        ),
        //Subtitle
        headline2: TextStyle(
          color: Color(0xff4B7586),
          fontSize: 23,
          fontWeight: FontWeight.normal,
          fontFamily: GoogleFonts.workSans().fontFamily,
        ),
        //ButtonText
        bodyText1: TextStyle(
          color: Color(0xffF3F7F9),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        //Text
        bodyText2: TextStyle(
          color: Color(0xff4B7586),
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
