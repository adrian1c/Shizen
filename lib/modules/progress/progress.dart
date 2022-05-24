import 'package:shimmer/shimmer.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/tasks.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class ProgressPage extends HookWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<PickerDateRange?> filterValue = useValueNotifier(null);
    final searchValue = useState(null);
    final tabController = useTabController(
      initialLength: 2,
      initialIndex: 0,
    );
    return Column(
      children: [
        Container(
          decoration:
              BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: filterValue.value == null
                        ? CustomTheme.activeIcon
                        : CustomTheme.activeButton,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    minimumSize:
                        Size((MediaQuery.of(context).size.width * 0.65), 45),
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Row(
                              children: [
                                Text('Selct Date / Range'),
                                TextButton(
                                    onPressed: () {
                                      filterValue.value = null;
                                      Provider.of<TabProvider>(context,
                                              listen: false)
                                          .rebuildPage('progress');
                                      Navigator.pop(context);
                                    },
                                    child: Text('CLEAR'))
                              ],
                            ),
                            content: SfDateRangePicker(
                              initialSelectedRange: filterValue.value,
                              selectionMode: DateRangePickerSelectionMode.range,
                              showActionButtons: true,
                              maxDate: DateTime.now(),
                              onCancel: () => Navigator.pop(context),
                              onSubmit: (value) {
                                filterValue.value = value as PickerDateRange?;
                                Provider.of<TabProvider>(context, listen: false)
                                    .rebuildPage('progress');
                                Navigator.pop(context);
                              },
                            ),
                          );
                        });
                  },
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt),
                      Text(filterValue.value != null
                          ? filterValue.value!.endDate != null
                              ? '${DateFormat("dd MMM yyyy").format((filterValue.value!.startDate!))} - ${DateFormat("dd MMM yyyy").format((filterValue.value!.endDate!))}'
                              : '${DateFormat("dd MMM yyyy").format((filterValue.value!.startDate!))}'
                          : 'Filter'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Container(
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
                // first tab [you can add an icon using the icon property]
                Tab(
                  child: Icon(Icons.task_alt),
                ),

                // second tab [you can add an icon using the icon property]
                Tab(
                  child: Icon(Icons.track_changes),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
              physics: CustomTabBarViewScrollPhysics(),
              controller: tabController,
              children: [
                KeepAlivePage(
                  child: Column(
                    children: [
                      TextDivider('COMPLETED TASKS'),
                      Expanded(
                        child: TodoTaskProgressList(
                            filterValue: filterValue, searchValue: searchValue),
                      ),
                    ],
                  ),
                ),
                KeepAlivePage(
                  child: Column(
                    children: [
                      TextDivider('CHECK-INS'),
                      Expanded(
                        child: TrackerProgressList(
                            filterValue: filterValue, searchValue: searchValue),
                      ),
                    ],
                  ),
                )
              ]),
        ),
      ],
    );
  }
}

class TodoTaskProgressList extends HookWidget {
  const TodoTaskProgressList(
      {Key? key, required this.filterValue, required this.searchValue})
      : super(key: key);

  final filterValue;
  final searchValue;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(
        () => Database(uid)
            .getTodoProgressList(filterValue.value, searchValue.value),
        [Provider.of<TabProvider>(context).progress]);
    final snapshot = useFuture(future);
    if (snapshot.hasData) {
      return snapshot.data.length > 0
          ? StickyGroupedListView(
              shrinkWrap: true,
              elements: snapshot.data,
              groupBy: (Map element) => DateTime(element['dateCompleted'].year,
                  element['dateCompleted'].month, element['dateCompleted'].day),
              groupSeparatorBuilder: (Map element) {
                var formattedDate =
                    DateFormat("dd MMM yyyy").format(element['dateCompleted']);
                return Container(
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
                  child: TodoTaskProgressTile(
                    taskId: element['taskId'],
                    title: element['title'],
                    taskList: element['desc'],
                    timeCompleted: element['dateCompleted'],
                  ),
                );
              },
              floatingHeader: true,
              order: StickyGroupedListOrder.DESC,
            )
          : Text('No To Do Tasks completed');
    }
    return SpinKitWanderingCubes(
      color: Theme.of(context).primaryColor,
      size: 75.0,
    );
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
                    constraints: BoxConstraints(minWidth: 25.w),
                    height: 5.h,
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
                Text(
                    'Completed at ${DateFormat("hh:mm a").format(timeCompleted)}')
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
                          return SizedBox(
                            height: 5.h,
                            child: Container(
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
                                    child: Checkbox(
                                      shape: CircleBorder(),
                                      activeColor:
                                          Theme.of(context).backgroundColor,
                                      checkColor: Colors.lightGreen[700],
                                      value: taskList[index]['status'],
                                      onChanged: (value) {},
                                    ),
                                  ),
                                  Text(taskList[index]['task'],
                                      softWrap: false,
                                      style: TextStyle(
                                          decoration: taskList[index]['status']
                                              ? TextDecoration.lineThrough
                                              : null)),
                                ],
                              ),
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
      return snapshot.data.length > 0
          ? StickyGroupedListView(
              shrinkWrap: true,
              elements: snapshot.data,
              groupBy: (Map element) => DateTime(element['dateCreated'].year,
                  element['dateCreated'].month, element['dateCreated'].day),
              groupSeparatorBuilder: (Map element) {
                var formattedDate =
                    DateFormat("dd MMM yyyy").format(element['dateCreated']);
                return Container(
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
              floatingHeader: true,
              order: StickyGroupedListOrder.DESC,
            )
          : Text('No Check-ins yet');
    }
    return SpinKitWanderingCubes(
      color: Theme.of(context).primaryColor,
      size: 75.0,
    );
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
