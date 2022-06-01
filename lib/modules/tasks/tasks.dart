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
    var tabController = useTabController(
      initialLength: 2,
      initialIndex: 0,
    );

    final scrollController = useScrollController();
    final scrollController2 = useScrollController();
    final scrollController3 = useScrollController();

    final tabIndex = useState(0);

    useEffect(() {
      tabController.addListener(() {
        tabIndex.value = tabController.index == 0 ? 0 : 1;
      });

      return () {};
    });
    String uid = Provider.of<UserProvider>(context).user.uid;

    return NestedScrollView(
      key: Keys.nestedScrollViewKeyTaskPage,
      controller: scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(children: [
              SliverAppBar(
                backgroundColor: CustomTheme.dividerBackground,
                shadowColor: Colors.transparent,
                automaticallyImplyLeading: false,
                floating: true,
                snap: true,
                forceElevated: false,
                centerTitle: true,
                title: Container(
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
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
                      color: Theme.of(context).primaryColor,
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Theme.of(context).primaryColor,
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
              ),
              SliverPinnedHeader(
                child: PreferredSize(
                  preferredSize: Size(100.w, 3.h),
                  child: AnimatedTextDivider(
                      ['TO DO TASKS', 'DAILY TRACKER'], tabIndex),
                ),
              ),
            ]),
          )
        ];
      },
      body: TabBarView(
        controller: tabController,
        physics: CustomTabBarViewScrollPhysics(),
        children: [
          KeepAlivePage(
            child: Builder(builder: (BuildContext context) {
              return NestedFix(
                globalKey: Keys.nestedScrollViewKeyTaskPage,
                child: CustomScrollView(
                    physics: ClampingScrollPhysics(),
                    controller: scrollController2,
                    slivers: [
                      SliverOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context)),
                      ToDoTask(
                        controller: scrollController,
                        uid: uid,
                      ),
                    ]),
              );
            }),
          ),
          KeepAlivePage(
            child: Builder(builder: (BuildContext context) {
              return NestedFix(
                globalKey: Keys.nestedScrollViewKeyTaskPage,
                child: CustomScrollView(
                    physics: ClampingScrollPhysics(),
                    controller: scrollController3,
                    slivers: [
                      SliverOverlapInjector(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context)),
                      TrackerTask(
                        controller: scrollController,
                        uid: uid,
                      )
                    ]),
              );
            }),
          ),
        ],
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
