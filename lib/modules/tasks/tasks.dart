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
      controller: scrollController2,
      physics: ScrollPhysics(parent: PageScrollPhysics()),
      floatHeaderSlivers: true,
      headerSliverBuilder: ((context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(children: [
              SliverAppBar(
                backgroundColor: CustomTheme.dividerBackground,
                shadowColor: Colors.transparent,
                automaticallyImplyLeading: false,
                floating: true,
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
          ),
        ];
      }),
      body: TabBarView(
          physics: CustomTabBarViewScrollPhysics(),
          controller: tabController,
          children: <Widget>[
            KeepAlivePage(child: Builder(
              builder: (context) {
                return NestedFix(
                  globalKey: Keys.nestedScrollViewKeyTaskPage,
                  child:
                      CustomScrollView(controller: scrollController, slivers: [
                    SliverOverlapInjector(
                      // This is the flip side of the SliverOverlapAbsorber
                      // above.
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return ToDoTask(
                              uid: uid, controller: scrollController);
                        },
                        childCount: 1,
                      ),
                    ),
                  ]),
                );
              },
            )),
            KeepAlivePage(child: Builder(
              builder: (context) {
                return NestedFix(
                  globalKey: Keys.nestedScrollViewKeyTaskPage,
                  child:
                      CustomScrollView(controller: scrollController, slivers: [
                    SliverOverlapInjector(
                      // This is the flip side of the SliverOverlapAbsorber
                      // above.
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return TrackerTask(
                              uid: uid, controller: scrollController);
                        },
                        childCount: 1,
                      ),
                    ),
                  ]),
                );
              },
            )),
          ]),
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
