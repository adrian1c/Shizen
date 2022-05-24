import 'package:google_fonts/google_fonts.dart';
import './allUtils.dart';

class CustomTheme {
  // static const Color _primaryColor = Color(0xff3d4785);
  // static const Color _scaffoldBackground = Color.fromARGB(255, 220, 224, 233);

  static const Color _primaryColor = Color.fromARGB(255, 72, 97, 100);
  static const Color _scaffoldBackground = Color.fromARGB(255, 216, 208, 208);

  static const Color _white = Color.fromARGB(255, 239, 235, 241);
  static const Color _black = Color(0xff444444);

  static const Color onboardingColor = Color.fromARGB(255, 199, 209, 194);

  static const Color completeColor = Color.fromARGB(255, 150, 175, 138);
  static const Color incompleteColor = Color.fromARGB(100, 199, 201, 211);

  static const Color activeIcon = Color.fromARGB(255, 71, 102, 148);
  static const Color inactiveIcon = Color.fromARGB(66, 121, 121, 121);

  static const Color activeButton = Color.fromARGB(255, 99, 133, 99);
  static const Color redButton = Color.fromARGB(255, 184, 87, 87);

  static const Color greyedButton = Color.fromARGB(255, 199, 199, 199);

  static const Color milestoneHeader = Color.fromARGB(255, 100, 127, 168);
  static const Color milestoneBody = Color.fromARGB(255, 175, 183, 196);

  static const Color milestoneDoneHeader = Color.fromARGB(255, 117, 165, 117);
  static const Color milestoneDoneBody = Color.fromARGB(255, 162, 185, 162);

  static const Color greyedOutField = Color.fromARGB(255, 167, 168, 170);

  static final boxShadow = kElevationToShadow[3];

  static final TextTheme _lightTextTheme = TextTheme(
    headline1: _headline1,
    headline2: _headline2,
    bodyText1: _bodyText1,
    bodyText2: _bodyText2,
    overline: _hashtagText,
    headline4: _headline4,
    headline5: _headline5,
  );

  static final TextStyle _headline1 = TextStyle(
      color: Colors.black87, fontSize: 16.sp, fontWeight: FontWeight.w600);

  static final TextStyle _headline2 = TextStyle(
      color: Color.fromARGB(255, 230, 235, 245),
      fontSize: 14.sp,
      fontWeight: FontWeight.w400);

  static final TextStyle _headline4 =
      TextStyle(color: _white, fontSize: 15.sp, fontWeight: FontWeight.w600);

  static final TextStyle _headline5 =
      TextStyle(color: _black, fontSize: 13.sp, fontWeight: FontWeight.w200);
  static final TextStyle _bodyText1 = TextStyle(
      color: Color.fromARGB(255, 230, 235, 245),
      fontSize: 15.sp,
      fontWeight: FontWeight.w600);

  static final TextStyle _bodyText2 =
      TextStyle(color: _black, fontWeight: FontWeight.normal);

  static final TextStyle titleTextStyle = TextStyle(
      color: _primaryColor,
      fontWeight: FontWeight.bold,
      fontSize: 50.sp,
      letterSpacing: 10.sp);

  static final TextStyle _hashtagText = TextStyle(
      color: _white,
      fontSize: 13.sp,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      decoration: TextDecoration.underline);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: _primaryColor,
      primaryColorDark: _black,
      backgroundColor: _white,
      appBarTheme: AppBarTheme(backgroundColor: _primaryColor),
      scaffoldBackgroundColor: _scaffoldBackground,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: _primaryColor, foregroundColor: _white),
      dialogTheme: DialogTheme(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return activeButton;
          }
          return Colors.white;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return Color.fromARGB(255, 128, 153, 130);
          }
          return Colors.grey;
        }),
      ),
      // inputDecorationTheme: InputDecorationTheme(
      //   iconColor: _lightPrimaryColor,
      //   enabledBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(color: _lightPrimaryColor),
      //   ),
      //   focusedBorder: UnderlineInputBorder(
      //     borderSide: BorderSide(color: _lightPrimaryColor),
      //   ),
      // ),
      fontFamily: GoogleFonts.poppins().fontFamily,
      textTheme: _lightTextTheme,
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
