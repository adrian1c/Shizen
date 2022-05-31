import 'package:flutter/material.dart';

class Keys {
  static final nestedScrollViewKeyProgressPage = GlobalKey();
  static final nestedScrollViewKeyTaskPage = GlobalKey();
}

class NestedFix extends StatelessWidget {
  const NestedFix({Key? key, required this.child, required this.globalKey})
      : super(key: key);

  final Widget child;
  final globalKey;

  void absorbScrollBehaviour(double scrolled, key) {
    final NestedScrollView? nestedScrollView =
        key.currentWidget as NestedScrollView?;
    final ScrollController? primaryScrollController =
        nestedScrollView?.controller;
    primaryScrollController?.jumpTo(primaryScrollController.offset + scrolled);
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener(
        onNotification: (Notification notification) {
          if (notification is OverscrollNotification &&
              notification.overscroll == 0) {
            absorbScrollBehaviour(notification.overscroll, globalKey);
          }
          if (notification is ScrollUpdateNotification) {
            absorbScrollBehaviour(notification.scrollDelta ?? 0, globalKey);
          }
          return true;
        },
        child: child);
  }
}
