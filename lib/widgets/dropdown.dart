import 'package:flutter/material.dart';
import 'package:menu_button/menu_button.dart';
import 'package:sizer/sizer.dart';

class Dropdown extends StatelessWidget {
  const Dropdown(
      {Key? key,
      required this.items,
      required this.value,
      required this.onItemSelected})
      : super(key: key);

  final List<String> items;
  final ValueNotifier value;
  final onItemSelected;

  @override
  Widget build(BuildContext context) {
    return MenuButton<String>(
      menuButtonBackgroundColor: Colors.transparent,
      child: VisibilityItem(value: value),
      items: items,
      itemBuilder: (String value) => Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
        child: Text(value),
      ),
      toggledChild: Container(
        child: VisibilityItem(value: value),
      ),
      onItemSelected: onItemSelected,
      selectedItem: value.value,
      showSelectedItemOnList: false,
    );
  }
}

class VisibilityItem extends StatelessWidget {
  const VisibilityItem({Key? key, required this.value}) : super(key: key);

  final value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 4.h,
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.visibility,
                  size: 20, color: Theme.of(context).primaryColor),
              Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      value.value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.sp),
                    ),
                  )),
              const SizedBox(
                width: 15,
                height: 25,
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Dropdown2 extends StatelessWidget {
  const Dropdown2(
      {Key? key,
      required this.items,
      required this.callback,
      required this.visibilityValue})
      : super(key: key);

  final List<String> items;
  final callback;
  final ValueNotifier<String> visibilityValue;

  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 5.h,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: DropdownButton(
          elevation: 0,
          isExpanded: true,
          value: visibilityValue.value,
          onChanged: callback,
          underline: Container(color: Colors.transparent),
          items: items.map((location) {
            return DropdownMenuItem(
              child: new Text(location),
              value: location,
            );
          }).toList(),
        ),
      ),
    );
  }
}
