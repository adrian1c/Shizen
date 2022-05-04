import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/modules/tasks/todoTab.dart';
import 'package:shizen_app/modules/tasks/trackerTab.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import '../../utils/allUtils.dart';

class TaskPage extends HookWidget {
  const TaskPage({Key? key, required this.isSwitching});

  final isSwitching;

  @override
  Widget build(BuildContext context) {
    var tabController = useTabController(
      initialLength: 2,
      initialIndex: 0,
    );
    String uid = Provider.of<UserProvider>(context).user.uid;
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 60.w,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(
                  25.0,
                ),
              ),
              child: TabBar(
                controller: tabController,
                // give the indicator a decoration (color and border radius)
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    25.0,
                  ),
                  color: Colors.blueGrey[700],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.blueGrey[700],
                tabs: [
                  Tab(
                    child: Icon(Icons.task_alt),
                  ),
                  Tab(
                    child: Icon(Icons.track_changes),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
            ),
            Expanded(
              child: TabBarView(
                  physics: CustomTabBarViewScrollPhysics(),
                  controller: tabController,
                  children: <Widget>[
                    KeepAlivePage(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextDivider('TO DO TASKS'),
                            ToDoTask(
                              uid: uid,
                            ),
                          ],
                        ),
                      ),
                    ),
                    KeepAlivePage(
                        child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextDivider('DAILY TRACKER'),
                          TrackerTask(uid: uid),
                        ],
                      ),
                    )),
                  ]),
            ),
          ],
        ),
      ),
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
