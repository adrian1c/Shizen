import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shizen_app/modules/progress/graph.dart';
import 'package:shizen_app/modules/progress/routineprogress.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/tasks.dart';
import 'package:shizen_app/modules/tasks/todoTab.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/utils/nestedFix.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:sliver_tools/sliver_tools.dart';
import "package:collection/collection.dart";
import 'dart:math';

// class ProgressPage extends HookWidget {
//   const ProgressPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final searchValue = useState(null);
//     final tabController = useTabController(
//       initialLength: 2,
//       initialIndex: 0,
//     );

//     final scrollController = useScrollController();
//     final scrollController2 = useScrollController();
//     final scrollController3 = useScrollController();

//     final tabIndex = useState(0);

//     useEffect(() {
//       tabController.addListener(() {
//         tabIndex.value = tabController.index == 0 ? 0 : 1;
//       });

//       return () {};
//     });

//     return NestedScrollView(
//       key: Keys.nestedScrollViewKeyProgressPage,
//       controller: scrollController,
//       physics: ScrollPhysics(parent: PageScrollPhysics()),
//       headerSliverBuilder: ((context, innerBoxIsScrolled) {
//         return [
//           SliverOverlapAbsorber(
//             handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//             sliver: MultiSliver(children: [
//               SliverAppBar(
//                 backgroundColor: CustomTheme.dividerBackground,
//                 shadowColor: Colors.transparent,
//                 automaticallyImplyLeading: false,
//                 floating: true,
//                 snap: true,
//                 forceElevated: false,
//                 centerTitle: true,
//                 title: Container(
//                   width: 60.w,
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).backgroundColor,
//                     borderRadius: BorderRadius.circular(
//                       25.0,
//                     ),
//                   ),
//                   child: TabBar(
//                     controller: tabController,
//                     // give the indicator a decoration (color and border radius)
//                     indicator: BoxDecoration(
//                       borderRadius: BorderRadius.circular(
//                         25.0,
//                       ),
//                       color: Theme.of(context).primaryColor,
//                     ),
//                     labelColor: Colors.white,
//                     unselectedLabelColor: Theme.of(context).primaryColor,
//                     tabs: [
//                       Tab(
//                         child: Icon(Icons.task_alt),
//                       ),
//                       Tab(
//                         child: Icon(Icons.track_changes),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SliverPinnedHeader(
//                 child: PreferredSize(
//                   preferredSize: Size(100.w, 3.h),
//                   child: AnimatedTextDivider(
//                       ['STATISTICS', 'ALL ROUTINES'], tabIndex),
//                 ),
//               ),
//             ]),
//           ),
//         ];
//       }),
//       body: TabBarView(
//           physics: CustomTabBarViewScrollPhysics(),
//           controller: tabController,
//           children: [
//             KeepAlivePage(
//               child: Builder(builder: (context) {
//                 return NestedFix(
//                   globalKey: Keys.nestedScrollViewKeyProgressPage,
//                   child:
//                       CustomScrollView(controller: scrollController2, slivers: [
//                     SliverOverlapInjector(
//                       // This is the flip side of the SliverOverlapAbsorber
//                       // above.
//                       handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                           context),
//                     ),
//                     RoutinesStats(targetUID: ,),
//                   ]),
//                 );
//               }),
//             ),
//             KeepAlivePage(
//               child: Builder(builder: (context) {
//                 return NestedFix(
//                   globalKey: Keys.nestedScrollViewKeyProgressPage,
//                   child:
//                       CustomScrollView(controller: scrollController3, slivers: [
//                     SliverOverlapInjector(
//                         handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                             context)),
//                     RoutinesList(
//                       searchValue: searchValue,
//                     )
//                   ]),
//                 );
//               }),
//             )
//           ]),
//     );
//   }
// }

class RoutinesStats extends HookWidget {
  const RoutinesStats({Key? key, required this.targetUID}) : super(key: key);

  final targetUID;

  completionsMonth(data, month) {
    var result = {};
    var days;
    var maxCompletions = 0;
    switch (month) {
      case 'Jan':
      case 'Mar':
      case 'May':
      case 'Jul':
      case 'Aug':
      case 'Oct':
      case 'Dec':
        days = 31;
        break;
      case 'Feb':
        days = 28;
        break;
      default:
        days = 30;
    }

    for (var i in data) {
      var temp = DateFormat("dd MMM yy")
          .format((i['dateCompleted'] as Timestamp).toDate());
      result.containsKey(temp) ? result[temp] += 1 : result[temp] = 1;
    }

    List<FlSpot> spots = List.generate(days, (i) {
      i += 1;
      var text = '$i $month 22';
      if (result.containsKey(text)) {
        maxCompletions = max(result[text], maxCompletions);
        return FlSpot(i.toDouble(), result[text].toDouble());
      } else {
        return FlSpot(i.toDouble(), 0.toDouble());
      }
    });

    return [spots, maxCompletions];
  }

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final selectedMonth = useState(DateFormat("MMM").format(DateTime.now()));
    final future = useMemoized(() => Database(uid).getAllRoutineData(targetUID),
        [Provider.of<TabProvider>(context).progress]);
    final snapshot = useFuture(future);

    if (snapshot.hasData) {
      var result = completionsMonth(snapshot.data, selectedMonth.value);
      var chartData = result[0];
      var maxCompletions = result[1];
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: 100.w,
            height: 35.h,
            child: LineChartSample1(
                spots: chartData,
                maxCompletions: maxCompletions,
                month: selectedMonth),
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SizedBox(
          width: 100.w,
          height: 30.h,
          child: SpinKitWanderingCubes(
              color: Theme.of(context).primaryColor, size: 75),
        ),
      ),
    );
  }
}

class RoutinesList extends HookWidget {
  const RoutinesList({Key? key, required this.searchValue}) : super(key: key);

  final searchValue;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(
        () => Database(uid).getProgressRoutines(searchValue.value),
        [Provider.of<TabProvider>(context).progress]);
    final snapshot = useFuture(future);

    if (snapshot.hasData) {
      var docsLength = snapshot.data.length;

      return docsLength > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              var element = snapshot.data[index];
              return RoutineProgressTile(
                taskId: element['taskId'],
                title: element['title'],
                taskList: element['desc'],
                timesCompleted: element['timesCompleted'],
              );
            }, childCount: snapshot.data.length))
          : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                  child: Text(
                    'You have no routines.\n You can create them by clicking on the button below!',
                    textAlign: TextAlign.center,
                  ));
            }, childCount: 1));
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: SpinKitWanderingCubes(
          color: Theme.of(context).primaryColor,
          size: 75.0,
        ),
      );
    }, childCount: 1));
  }
}

class RoutineProgressTile extends StatelessWidget {
  const RoutineProgressTile({
    Key? key,
    required this.taskId,
    required this.title,
    required this.taskList,
    required this.timesCompleted,
  });

  final String taskId;
  final String title;
  final taskList;
  final int timesCompleted;

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: InkWell(
        onLongPress: () => StyledPopup(
                context: context,
                title: 'Delete To Do Task',
                children: [Text('Are you sure you want to delete this task?')],
                textButton: TextButton(
                    onPressed: () async {
                      await LoaderWithToast(
                              context: context,
                              api: Database(uid).deleteToDoTask(taskId),
                              msg: 'Task Deleted',
                              isSuccess: false)
                          .show();
                      Provider.of<TabProvider>(context, listen: false)
                          .rebuildPage('todo');
                      Navigator.pop(context);
                    },
                    child: Text('Delete',
                        style: TextStyle(color: Colors.red[400]))))
            .showPopup(),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: Text('Activity'),
                      ),
                      body: RoutineProgressPage(
                          tid: taskId,
                          title: title,
                          timesCompleted: timesCompleted))));
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(context).backgroundColor,
              boxShadow: CustomTheme.boxShadow),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                          color:
                              Theme.of(context).primaryColor.withAlpha(200))),
                  Row(
                    children: [
                      Text('$timesCompleted',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.check_circle_rounded,
                          color: Color.fromARGB(255, 147, 182, 117))
                    ],
                  )
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Divider(),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: taskList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      constraints: BoxConstraints(minHeight: 5.h),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: taskList[index]['status']
                            ? CustomTheme.completeColor
                            : Theme.of(context).backgroundColor,
                      ),
                      child: Row(
                        children: [
                          AbsorbPointer(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                shape: CircleBorder(),
                                activeColor: Theme.of(context).backgroundColor,
                                checkColor: Colors.lightGreen[700],
                                value: taskList[index]['status'],
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(taskList[index]['task'],
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      decoration: taskList[index]['status']
                                          ? TextDecoration.lineThrough
                                          : null)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

// class TodoTaskProgressList extends HookWidget {
//   const TodoTaskProgressList({
//     Key? key,
//     required this.filterValue,
//     required this.searchValue,
//   }) : super(key: key);

//   final filterValue;
//   final searchValue;

//   @override
//   Widget build(BuildContext context) {
//     final String uid = Provider.of<UserProvider>(context).user.uid;
//     final future = useMemoized(
//         () => Database(uid)
//             .getTodoProgressList(filterValue.value, searchValue.value),
//         [Provider.of<TabProvider>(context).progress]);
//     final snapshot = useFuture(future);
//     if (snapshot.hasData) {
//       var docsLength = snapshot.data.length;

// return docsLength > 0
//     ? SliverGroupedListView(
//         elements: snapshot.data,
//         groupBy: (Map element) => DateTime(element['dateCompleted'].year,
//             element['dateCompleted'].month, element['dateCompleted'].day),
//         groupHeaderBuilder: (Map element) {
//           var formattedDate =
//               DateFormat("dd MMM yyyy").format(element['dateCompleted']);
//           return Container(
//             margin: const EdgeInsets.only(top: 10),
//             height: 5.h,
//             child: Align(
//               alignment: Alignment.center,
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(99, 114, 133, 143),
//                   borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     '$formattedDate',
//                     style: TextStyle(color: Colors.white),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//         itemBuilder: (context, dynamic element) {
//           return Padding(
//             padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
//             child: TodoTaskProgressTile(
//               taskId: element['taskId'],
//               title: element['title'],
//               taskList: element['desc'],
//               timeCompleted: element['dateCompleted'],
//             ),
//           );
//         },
//         order: GroupedListOrder.DESC,
//       )
//     : SliverList(
//         delegate: SliverChildBuilderDelegate((context, index) {
//         return Padding(
//             padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
//             child: Text(
//               'You have no completed tasks yet',
//               textAlign: TextAlign.center,
//             ));
//       }, childCount: 1));
//     }
//     return SliverList(
//         delegate: SliverChildBuilderDelegate((context, index) {
//       return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 50.0),
//         child: SpinKitWanderingCubes(
//           color: Theme.of(context).primaryColor,
//           size: 75.0,
//         ),
//       );
//     }, childCount: 1));
//   }
// }

class TodoTaskProgressTile extends StatelessWidget {
  const TodoTaskProgressTile(
      {Key? key,
      required this.taskId,
      required this.title,
      required this.taskList,
      required this.timeCompleted})
      : super(key: key);

  final String taskId;
  final String title;
  final taskList;
  final timeCompleted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(title: Text('Create Similar Task?'), actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      List task = [];

                      for (var i = 0; i < taskList.length; i++) {
                        var tempMap = {
                          'task': taskList[i]['task'],
                          'status': false
                        };
                        task.add(tempMap);
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddToDoTask(
                            editParams: {
                              'id': null,
                              'title': title,
                              'desc': task,
                              'reminder': null,
                              'isPublic': false,
                            },
                            isEdit: false,
                          ),
                        ),
                      );
                    },
                    child: Text("Yes")),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel"),
                ),
              ]);
            });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                    constraints: BoxConstraints(minWidth: 25.w, minHeight: 5.h),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(200),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(title,
                          style: Theme.of(context).textTheme.headline4),
                    ))),
                Text('${DateFormat("d MMM @ h:mm a").format(timeCompleted)}')
              ],
            ),
            ConstrainedBox(
                constraints: BoxConstraints(minHeight: 5.h, minWidth: 100.w),
                child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(200),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                          topRight: Radius.circular(15)),
                      boxShadow: CustomTheme.boxShadow,
                    ),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: taskList.length,
                        itemBuilder: (context, index) {
                          return Container(
                            constraints: BoxConstraints(minHeight: 5.h),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            decoration: BoxDecoration(
                                color: taskList[index]['status']
                                    ? CustomTheme.completeColor
                                    : Theme.of(context).backgroundColor,
                                borderRadius: index == 0
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomLeft: taskList.length == 1
                                            ? Radius.circular(15)
                                            : Radius.zero,
                                        bottomRight: taskList.length == 1
                                            ? Radius.circular(15)
                                            : Radius.zero,
                                      )
                                    : index == taskList.length - 1
                                        ? BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          )
                                        : null),
                            child: Row(
                              children: [
                                AbsorbPointer(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: Checkbox(
                                      shape: CircleBorder(),
                                      activeColor:
                                          Theme.of(context).backgroundColor,
                                      checkColor: Colors.lightGreen[700],
                                      value: taskList[index]['status'],
                                      onChanged: (value) {},
                                    ),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Text(taskList[index]['task'],
                                        textAlign: TextAlign.justify,
                                        style: TextStyle(
                                            decoration: taskList[index]
                                                    ['status']
                                                ? TextDecoration.lineThrough
                                                : null)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }))),
          ],
        ),
      ),
    );
  }
}

class TrackerProgressList extends HookWidget {
  const TrackerProgressList(
      {Key? key, required this.filterValue, required this.searchValue})
      : super(key: key);

  final filterValue;
  final searchValue;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(
        () => Database(uid)
            .getTrackerProgressList(filterValue.value, searchValue.value),
        [Provider.of<TabProvider>(context).progress]);
    final snapshot = useFuture(future);

    if (snapshot.hasData) {
      var docsLength = snapshot.data.length;

      return docsLength > 0
          ? SliverGroupedListView(
              elements: snapshot.data,
              groupBy: (Map element) => DateTime(element['dateCreated'].year,
                  element['dateCreated'].month, element['dateCreated'].day),
              groupHeaderBuilder: (Map element) {
                var formattedDate =
                    DateFormat("dd MMM yyyy").format(element['dateCreated']);
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  height: 5.h,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(99, 114, 133, 143),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$formattedDate',
                          style: TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemBuilder: (context, dynamic element) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TrackerProgressTile(
                    name: element['trackerName'],
                    note: element['note'],
                    timeCompleted: element['dateCreated'],
                  ),
                );
              },
              order: GroupedListOrder.DESC,
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                  child: Text(
                    'You have no check-ins yet',
                    textAlign: TextAlign.center,
                  ));
            }, childCount: 1));
    }
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: SpinKitWanderingCubes(
          color: Theme.of(context).primaryColor,
          size: 75.0,
        ),
      );
    }, childCount: 1));
  }
}

class TrackerProgressTile extends StatelessWidget {
  const TrackerProgressTile(
      {Key? key,
      required this.name,
      required this.note,
      required this.timeCompleted})
      : super(key: key);

  final name;
  final note;
  final timeCompleted;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).backgroundColor,
            boxShadow: CustomTheme.boxShadow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name,
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                        color: Theme.of(context).primaryColor.withAlpha(200))),
                Text(
                    'Checked-in at \n${DateFormat("hh:mm a").format(timeCompleted)}',
                    textAlign: TextAlign.right),
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            Divider(),
            Text(note)
          ],
        ),
      ),
    );
  }
}
