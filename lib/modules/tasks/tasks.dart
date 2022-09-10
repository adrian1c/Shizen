import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/modules/tasks/todoTab.dart';
import 'package:shizen_app/modules/tasks/trackerTab.dart';
import 'package:shizen_app/utils/nestedFix.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../utils/allUtils.dart';

class TaskPage extends HookWidget {
  const TaskPage({Key? key});

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;

    final scrollController = useScrollController();
    final scrollController2 = useScrollController();

    return KeepAlivePage(
      child: Builder(builder: (BuildContext context) {
        return CustomScrollView(
            physics: ClampingScrollPhysics(),
            controller: scrollController2,
            slivers: [
              ToDoTask(
                controller: scrollController,
                uid: uid,
              ),
            ]);
      }),
    );
  }
}

class CustomTabBarViewScrollPhysics extends ScrollPhysics {
  const CustomTabBarViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomTabBarViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomTabBarViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 2,
      );
}
