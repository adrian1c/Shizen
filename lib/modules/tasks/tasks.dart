import 'package:flutter/physics.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/modules/tasks/todoTab.dart';
import 'package:shizen_app/modules/tasks/trackerTab.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import './addtodo.dart';
import './addtracker.dart';
import '../../utils/allUtils.dart';

class TaskPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final todoChanged = useState(0);
    final trackerChanged = useState(0);
    ValueNotifier isSwitching = useValueNotifier(true);
    var tabController = useTabController(
      initialLength: 2,
      initialIndex: 0,
    );
    tabController.addListener(() {
      if (tabController.index == 0) {
        isSwitching.value = true;
      } else {
        isSwitching.value = false;
      }
    });
    tabController.animation!.addListener(() {
      tabController.animation!.value < 0.5
          ? isSwitching.value = true
          : isSwitching.value = false;
    });
    String uid = Provider.of<UserProvider>(context).uid;

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Column(
              children: [
                Container(
                  width: 60.w,
                  height: 5.h,
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
                        child: Text('To Do', style: TextStyle(fontSize: 12.sp)),
                      ),
                      Tab(
                        child: Text('Daily Tracker',
                            style: TextStyle(fontSize: 12.sp)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                      physics: CustomTabBarViewScrollPhysics(),
                      controller: tabController,
                      children: <Widget>[
                        KeepAlivePage(
                          child: ToDoTask(
                            uid: uid,
                            todoChanged: todoChanged,
                          ),
                        ),
                        KeepAlivePage(
                            child: TrackerTask(
                                uid: uid, trackerChanged: trackerChanged)),
                      ]),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => isSwitching.value
                              ? AddToDoTask(todoChanged: todoChanged)
                              : AddTrackerTask(
                                  trackerChanged: trackerChanged)));
                },
                child: ValueListenableBuilder(
                    valueListenable: isSwitching,
                    builder: (context, data, _) {
                      if (data == true) {
                        return Text("Add To Do Task");
                      } else {
                        return Text("Add Tracker");
                      }
                    }),
              ),
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
