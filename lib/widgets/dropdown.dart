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
      width: 25.w,
      height: 4.h,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(child: Text(value.value, overflow: TextOverflow.ellipsis)),
            const SizedBox(
              width: 12,
              height: 17,
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
    );
  }
}
