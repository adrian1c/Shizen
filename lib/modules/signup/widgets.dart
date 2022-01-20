import 'package:flutter/material.dart';
import '../../constants/words.dart';
import '../../themes/custom_theme.dart';

class SignupField extends StatelessWidget {
  const SignupField(
      {Key? key,
      required this.nameController,
      required this.fieldText,
      required this.widthPercentage})
      : super(key: key);

  final TextEditingController nameController;
  final String fieldText;
  final double widthPercentage;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: SizedBox(
        width: (MediaQuery.of(context).size.width * widthPercentage),
        child: TextFormField(
          controller: nameController,
          style: TextStyle(color: Color(0xff58865C)),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.only(top: 0.0, left: 5.0),
            labelText: fieldText,
            labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
            enabledBorder: UnderlineInputBorder(
                borderSide: const BorderSide(color: Color(0xff35566D))),
          ),
          // The validator receives the text that the user has entered.
          validator: (value) {
            if (value!.isEmpty) {
              return 'Enter';
            }
            return null;
          },
        ),
      ),
    );
  }
}
