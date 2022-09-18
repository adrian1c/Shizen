import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shizen_app/modules/progress/progress.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class RoutineProgressPage extends HookWidget {
  const RoutineProgressPage(
      {Key? key,
      required this.tid,
      required this.title,
      required this.timesCompleted})
      : super(key: key);

  final tid;
  final title;
  final timesCompleted;

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<PickerDateRange?> filterValue = useValueNotifier(null);
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(
        () => Database(uid).getRoutineActivity(tid, filterValue.value),
        [Provider.of<TabProvider>(context).progressActivity]);
    final snapshot = useFuture(future);

    if (snapshot.hasData) {
      return NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, val) => [
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: MultiSliver(
              children: [
                SliverAppBar(
                  backgroundColor: CustomTheme.dividerBackground,
                  shadowColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  forceElevated: false,
                  snap: false,
                  floating: true,
                  flexibleSpace: Container(
                    decoration:
                        BoxDecoration(color: CustomTheme.dividerBackground),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(color: Colors.black)),
                          Row(
                            children: [
                              Text('$timesCompleted',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline2!
                                      .copyWith(color: Colors.black)),
                              Icon(Icons.check_circle_rounded,
                                  color: Color.fromARGB(255, 147, 182, 117))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverAppBar(
                  backgroundColor: CustomTheme.dividerBackground,
                  automaticallyImplyLeading: false,
                  floating: false,
                  forceElevated: true,
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
                                                .rebuildPage(
                                                    'progressActivity');
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
                                              .rebuildPage('progressActivity');
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
                                      padding: const EdgeInsets.fromLTRB(
                                          5, 10, 5, 10),
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
              ],
            ),
          ),
          //  SliverPersistentHeader(delegate: Delegate(),pinned: true,)
        ],
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Activity'),
                  ],
                ),
                RoutineProgressActivity(
                  data: snapshot.data,
                ),
              ],
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: SpinKitWanderingCubes(
        color: Theme.of(context).primaryColor,
        size: 75.0,
      ),
    );
  }
}

class RoutineProgressActivity extends StatelessWidget {
  const RoutineProgressActivity({Key? key, required this.data})
      : super(key: key);

  final List<Map> data;

  @override
  Widget build(BuildContext context) {
    return data.length > 0
        ? GroupedListView(
            shrinkWrap: true,
            elements: data,
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
              return RoutineProgressActivityTile(
                taskId: element['activityId'],
                taskList: element['desc'],
                timeCompleted:
                    DateFormat("hh:mm a").format(element['dateCompleted']),
                note: element['note'],
                image: '555',
              );
            },
            order: GroupedListOrder.DESC,
          )
        : Text('You have no activities for this routine');
  }
}

class RoutineProgressActivityTile extends StatelessWidget {
  const RoutineProgressActivityTile(
      {Key? key,
      required this.taskId,
      required this.taskList,
      required this.timeCompleted,
      required this.note,
      required this.image});

  final String taskId;
  final taskList;
  final timeCompleted;
  final note;
  final image;

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
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Completed: $timeCompleted'),
                Text('Day: 5'),
              ],
            ),
            ConstrainedBox(
                constraints: BoxConstraints(minHeight: 5.h, minWidth: 100.w),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      boxShadow: CustomTheme.boxShadow,
                    ),
                    child: Column(
                      children: [
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
                                                bottomRight:
                                                    Radius.circular(15),
                                              )
                                            : null),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: AbsorbPointer(
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
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
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
                            }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(note)),
                              ),
                              // Padding(
                              //   padding: const EdgeInsets.symmetric(
                              //       horizontal: 10.0),
                              //   child: Divider(color: Colors.black),
                              // ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.symmetric(horizontal: 10),
                              //   child: Text('Test'),
                              // )
                            ],
                          ),
                        )
                      ],
                    ))),
          ],
        ),
      ),
    );
  }
}
