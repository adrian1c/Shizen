import 'package:grouped_list/sliver_grouped_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/tasks.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/utils/nestedFix.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProgressPage extends HookWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<PickerDateRange?> filterValue = useValueNotifier(null);
    final searchValue = useState(null);

    final scrollController = useScrollController();
    final scrollController2 = useScrollController();

    final tabIndex = useState(0);

    return NestedScrollView(
      key: Keys.nestedScrollViewKeyProgressPage,
      controller: scrollController,
      physics: ScrollPhysics(parent: PageScrollPhysics()),
      headerSliverBuilder: ((context, innerBoxIsScrolled) {
        return [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(children: [
              SliverAppBar(
                backgroundColor: CustomTheme.dividerBackground,
                shadowColor: Colors.transparent,
                automaticallyImplyLeading: false,
                floating: false,
                forceElevated: false,
                centerTitle: true,
                title: Container(
                  // width: 75.w,
                  decoration:
                      BoxDecoration(color: CustomTheme.dividerBackground),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: filterValue.value == null
                              ? CustomTheme.activeIcon
                              : CustomTheme.activeButton,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                          minimumSize: Size(50.w, 40)),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Selct Date / Range'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          filterValue.value = null;
                                          Provider.of<TabProvider>(context,
                                                  listen: false)
                                              .rebuildPage('progress');
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'REMOVE FILTER',
                                          style: TextStyle(color: Colors.red),
                                        )),
                                    SfDateRangePicker(
                                      initialSelectedRange: filterValue.value,
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      showActionButtons: true,
                                      maxDate: DateTime.now(),
                                      onCancel: () => Navigator.pop(context),
                                      onSubmit: (value) {
                                        filterValue.value =
                                            value as PickerDateRange?;
                                        Provider.of<TabProvider>(context,
                                                listen: false)
                                            .rebuildPage('progress');
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: filterValue.value == null
                            ? [
                                Center(
                                    child: Text(
                                  'No Date Filter',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .backgroundColor
                                          .withAlpha(150)),
                                ))
                              ]
                            : [
                                Icon(Icons.calendar_month_rounded,
                                    color: Theme.of(context).backgroundColor),
                                Center(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 10, 5, 10),
                                    child: Text(filterValue.value!.endDate !=
                                            null
                                        ? '${DateFormat("d MMM yyyy").format((filterValue.value!.startDate!))} - ${DateFormat("dd MMM yyyy").format((filterValue.value!.endDate!))}'
                                        : '${DateFormat("d MMM yyyy").format((filterValue.value!.startDate!))}'),
                                  ),
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPinnedHeader(
                child: PreferredSize(
                  preferredSize: Size(100.w, 3.h),
                  child: AnimatedTextDivider(['ACTIVITY'], tabIndex),
                ),
              ),
            ]),
          ),
        ];
      }),
      body: KeepAlivePage(
        child: Builder(builder: (context) {
          return NestedFix(
            globalKey: Keys.nestedScrollViewKeyProgressPage,
            child: CustomScrollView(controller: scrollController2, slivers: [
              SliverOverlapInjector(
                // This is the flip side of the SliverOverlapAbsorber
                // above.
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              ProgressList(
                filterValue: filterValue,
                searchValue: searchValue,
              ),
            ]),
          );
        }),
      ),
    );
  }
}

class ProgressList extends HookWidget {
  const ProgressList({
    Key? key,
    required this.filterValue,
    required this.searchValue,
  }) : super(key: key);

  final filterValue;
  final searchValue;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(
        () =>
            Database(uid).getProgressList(filterValue.value, searchValue.value),
        [Provider.of<TabProvider>(context).progress]);
    final snapshot = useFuture(future);
    if (snapshot.hasData) {
      var docsLength = snapshot.data.length;

      return docsLength > 0
          ? SliverGroupedListView(
              elements: snapshot.data,
              groupBy: (Map element) => DateTime(element['dateCompleted'].year,
                  element['dateCompleted'].month, element['dateCompleted'].day),
              groupHeaderBuilder: (Map element) {
                var formattedDate =
                    DateFormat("dd MMM yyyy").format(element['dateCompleted']);
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
                  child: element['type'] == 'todo'
                      ? TodoTaskProgressTile(
                          taskId: element['taskId'],
                          title: element['title'],
                          taskList: element['desc'],
                          timeCompleted: element['dateCompleted'],
                        )
                      : TrackerProgressTile(
                          name: element['trackerName'],
                          note: element['note'],
                          timeCompleted: element['dateCompleted'],
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
                    'You have no completed tasks yet',
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
                              'recur': [
                                false,
                                false,
                                false,
                                false,
                                false,
                                false,
                                false
                              ],
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
