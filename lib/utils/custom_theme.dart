import 'package:google_fonts/google_fonts.dart';
import './allUtils.dart';

class CustomTheme {
  static const Color _lightPrimaryColor = Color(0xff4B7586);
  static const Color _lightSecondaryColor = Color(0xffF3F7F9);

  static const Color _darkPrimaryColor = Color(0xff4B7586);
  static const Color _darkSecondaryColor = Color(0xffF3F7F9);

  static const Color todoTaskContainerColor = Color(0xffd9d4c4);
  static const Color todoTaskBorderColor = Color(0xffecb613);

  static const Color todoTaskCompleteColor = Color(0xffadd388);
  static const Color todoTaskCheckboxColor = Color(0xff6e9249);

  static final TextTheme _lightTextTheme = TextTheme(
      headline1: _headline1,
      headline2: _headline2,
      bodyText1: _bodyText1,
      overline: _hashtagText,
      headline4: _headline4);

  static final TextStyle _headline1 = TextStyle(
      color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.w600);

  static final TextStyle _headline2 = TextStyle(
      color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w400);

  static final TextStyle _headline4 = TextStyle(
      color: Colors.black54, fontSize: 15.sp, fontWeight: FontWeight.w400);

  static final TextStyle _bodyText1 = TextStyle(
      color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600);

  static final TextStyle _hashtagText = TextStyle(
      color: Colors.blue[800],
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      decoration: TextDecoration.underline);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: _lightPrimaryColor,
      backgroundColor: Color(0xffFFFFFF),
      appBarTheme: AppBarTheme(backgroundColor: Colors.blueGrey[800]),
      scaffoldBackgroundColor: _lightSecondaryColor,
      fontFamily: GoogleFonts.sourceSansPro().fontFamily,
      textTheme: _lightTextTheme,
      // textTheme: TextTheme(
      //   //Title
      //   headline1: TextStyle(
      //     color: Color(0xff4B7586),
      //     fontSize: 50,
      //     fontFamily: GoogleFonts.libreFranklin().fontFamily,
      //     fontWeight: FontWeight.w900,
      //     letterSpacing: 15.0,
      //   ),
      //   //Subtitle
      //   headline2: TextStyle(
      //     color: Color(0xff4B7586),
      //     fontSize: 23,
      //     fontWeight: FontWeight.normal,
      //     fontFamily: GoogleFonts.workSans().fontFamily,
      //   ),
      //   //ButtonText
      //   bodyText1: TextStyle(
      //     color: Color(0xffF3F7F9),
      //     fontSize: 18,
      //     fontWeight: FontWeight.bold,
      //   ),
      //   //Text
      //   bodyText2: TextStyle(
      //     color: Color(0xff4B7586),
      //     fontSize: 20,
      //     fontWeight: FontWeight.normal,
      //   ),
      // ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Color(0xff000000),
      backgroundColor: Color(0xff000000),
      scaffoldBackgroundColor: Color(0xff000000),
      fontFamily: GoogleFonts.sourceSansPro().fontFamily,
      textTheme: TextTheme(
        //Title
        headline1: TextStyle(
          color: Color(0xff000000),
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
