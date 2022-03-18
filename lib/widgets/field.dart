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

class StyledPopup {
  const StyledPopup(
      {Key? key,
      required this.title,
      required this.children,
      this.cancelText = 'Cancel',
      this.cancelFunction,
      this.textButton});

  final String title;
  final List<Widget> children;
  final String cancelText;
  final Function()? cancelFunction;
  final TextButton? textButton;

  showPopup() {
    OneContext().showDialog(builder: (_) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
        actions: textButton != null
            ? [
                textButton!,
                TextButton(
                  onPressed: cancelFunction != null
                      ? cancelFunction
                      : () {
                          OneContext().popDialog();
                        },
                  child: Text(cancelText,
                      style: cancelText != 'Cancel'
                          ? null
                          : TextStyle(color: Colors.red)),
                ),
              ]
            : [
                TextButton(
                  onPressed: cancelFunction != null
                      ? cancelFunction
                      : () {
                          OneContext().popDialog();
                        },
                  child: Text(cancelText,
                      style: cancelText != 'Cancel'
                          ? null
                          : TextStyle(color: Colors.red)),
                ),
              ],
      );
    });
  }
}

class StyledSnackbar {
  const StyledSnackbar({Key? key, required this.message});

  final String message;

  showSuccess() {
    OneContext().showSnackBar(
        builder: (_) => SnackBar(
              margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 80.h),
              content: Text(
                message,
                textAlign: TextAlign.center,
              ),
              backgroundColor: Color(0xff17bd46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                  label: 'OK',
                  onPressed: () => OneContext().hideCurrentSnackBar()),
            ));
  }

  showError() {
    OneContext().showSnackBar(
        builder: (_) => SnackBar(
              margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 80.h),
              content: Text(
                message,
                textAlign: TextAlign.center,
              ),
              backgroundColor: Color(0xffF24C4C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                  label: 'OK',
                  onPressed: () => OneContext().hideCurrentSnackBar()),
            ));
  }
}
