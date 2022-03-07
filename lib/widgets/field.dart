import 'package:flutter/material.dart';
import 'package:shizen_app/utils/allUtils.dart';

class StyledContainerField extends StatelessWidget {
  const StyledContainerField(
      {Key? key, required this.child, this.pad, this.width, this.height})
      : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry? pad;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pad != null ? pad! : const EdgeInsets.all(8.0),
      child: Container(
          width: width != null ? width : 35.w,
          height: height != null ? height : 4.h,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.7),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(1, 1), // changes position of shadow
              ),
            ],
          ),
          child: child),
    );
  }
}

class StyledInputField {
  const StyledInputField({Key? key, required this.hintText});

  final String hintText;

  inputDecoration() {
    return InputDecoration(
      isDense: true,
      hintText: hintText,
      contentPadding: EdgeInsets.fromLTRB(10, 20, 10, 0),
      border: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(5),
        borderSide: new BorderSide(),
      ),
    );
  }
}
