import 'package:flutter/material.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
  const StyledInputField(
      {Key? key,
      required this.hintText,
      required this.controller,
      this.inputValue});

  final String hintText;
  final TextEditingController controller;
  final inputValue;

  inputDecoration() {
    return InputDecoration(
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 5.0),
        child: Icon(
          Icons.search,
          size: 20,
        ),
      ),
      prefixIconConstraints:
          BoxConstraints(minHeight: 35, maxHeight: 35, maxWidth: 25),
      isDense: true,
      hintText: hintText,
      contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      suffixIcon: IconButton(
          color: Colors.grey[400],
          iconSize: 20,
          padding: EdgeInsets.only(right: 20),
          onPressed: () {
            controller.clear();
            if (inputValue != null) {
              inputValue.value = '';
            }
          },
          icon: Icon(Icons.cancel)),
      suffixIconConstraints:
          BoxConstraints(minHeight: 35, maxHeight: 35, maxWidth: 25),
      border: OutlineInputBorder(
        borderRadius: new BorderRadius.circular(5),
        borderSide: new BorderSide(),
      ),
      filled: true,
      fillColor: CustomTheme.lightTheme.backgroundColor,
    );
  }
}

class StyledPopup {
  const StyledPopup(
      {Key? key,
      required this.context,
      required this.title,
      required this.children,
      this.cancelText = 'Cancel',
      this.cancelFunction,
      this.textButton});

  final context;
  final String title;
  final List<Widget> children;
  final String cancelText;
  final Function()? cancelFunction;
  final TextButton? textButton;

  showPopup() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
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
                              Navigator.pop(context);
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
                              Navigator.pop(context);
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

class StyledToast {
  const StyledToast({Key? key, required this.msg});

  final msg;

  showSuccessToast() {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: CustomTheme.greenToast,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  showDeletedToast() {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: CustomTheme.redToast,
        textColor: Colors.white,
        fontSize: 16.0);
  }
}

class LoaderWithToast {
  const LoaderWithToast(
      {Key? key,
      required this.context,
      required this.api,
      required this.msg,
      required this.isSuccess});

  final BuildContext context;
  final Future api;
  final String msg;
  final bool isSuccess;

  show() async {
    context.loaderOverlay.show();
    await api.then((value) {
      context.loaderOverlay.hide();
      if (isSuccess) {
        StyledToast(msg: msg).showSuccessToast();
      } else {
        StyledToast(msg: 'Oops, something went wrong').showDeletedToast();
      }
    }).catchError((error) {
      context.loaderOverlay.hide();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error"),
              content: Text(error.message),
              actions: [
                TextButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
      StyledToast(msg: 'Oops, something went wrong').showDeletedToast();
    });
  }
}
