import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/modules/tasks/addtracker.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';

class TrackerTask extends HookWidget {
  const TrackerTask({Key? key, required this.uid, required this.controller})
      : super(key: key);

  final controller;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(() => Database(uid).getTrackerTasks(),
        [Provider.of<TabProvider>(context).tracker]);
    final snapshot = useFuture(future);
    if (snapshot.hasData) {
      print('Gotem');
      var docsLength = snapshot.data.docs.length;

      return docsLength > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              var taskDoc = snapshot.data.docs[index];
              if (index == 0) {
                return TrackerTile(uid: uid, task: taskDoc);
              }
              return Column(
                children: [
                  Divider(),
                  TrackerTile(uid: uid, task: taskDoc),
                ],
              );
            }, childCount: snapshot.data.docs.length))
          : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                  child: Text(
                    'You have no trackers.\n You can create trackers by clicking on the button below!',
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

class TrackerTile extends HookWidget {
  const TrackerTile({
    Key? key,
    required this.task,
    required this.uid,
  }) : super(key: key);

  final task;
  final String uid;

  checkInPopup(context, controller, checkinData, currStreakDate) {
    final _formKey = GlobalKey<FormState>();
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Today\'s Note'),
                content: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: controller,
                    style: TextStyle(color: Color(0xff58865C)),
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 10,
                    maxLength: 500,
                    decoration: InputDecoration(
                      hintText: "Description",
                      contentPadding: EdgeInsets.all(10.0),
                      labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Content cannot be empty';
                      }
                      return null;
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          var ciData =
                              currentDayCheckIn(checkinData, currStreakDate);
                          await Database(uid).checkInTracker(
                              task.id,
                              task['title'],
                              DateTime.now().difference(currStreakDate).inDays +
                                  1,
                              controller.text,
                              null,
                              ciData != null ? ciData['checkinId'] : null);
                          controller.clear();
                          Provider.of<TabProvider>(context, listen: false)
                              .rebuildPage('tracker');
                          Provider.of<TabProvider>(context, listen: false)
                              .rebuildPage('profileUser');
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Save")),
                  TextButton(
                    onPressed: () {
                      controller.clear();
                      Navigator.pop(context);
                    },
                    child: Text("Cancel"),
                  ),
                ]));
  }

  Map? currentDayCheckIn(List checkinData, currStreakDate) {
    for (var i = 0; i < checkinData.length; i++) {
      if (checkinData[i]['day'] ==
          DateTime.now().difference(currStreakDate).inDays + 1) {
        var result = checkinData[i].data();
        result['checkinId'] = checkinData[i].id;
        return result;
      }
    }
    return null;
  }

  String getNextMilestone(milestoneList, currDay) {
    for (var i = 0; i < milestoneList.length; i++) {
      if (milestoneList[i]['day'] > currDay) {
        return 'Day ${milestoneList[i]['day']} - ${milestoneList[i]['reward']}';
      }
    }
    return 'You\'ve completed all milestones!';
  }

  @override
  Widget build(BuildContext context) {
    final checkInController = useTextEditingController();
    final noteController = useTextEditingController();
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future =
        useMemoized(() => Database(uid).getCheckInButtonData(task.id), []);
    final snapshot = useFuture(future);
    final hasLoaded = useState(false);
    var currCheckIn;
    if (snapshot.hasData) {
      currCheckIn = currentDayCheckIn(
          snapshot.data.docs, (task['currStreakDate'] as Timestamp).toDate());
      hasLoaded.value = true;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 10,
            child: InkWell(
              onTap: () {
                Map editParams = {
                  'taskId': task.id,
                  'title': task['title'],
                  'note': task['note'],
                  'startDate': (task['currStreakDate'] as Timestamp).toDate(),
                  'milestones': task['milestones'],
                  'reminder': task['reminder'] != null
                      ? (task['reminder'] as Timestamp).toDate()
                      : null
                };
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddTrackerTask(editParams: editParams),
                    ));
              },
              onLongPress: () {
                StyledPopup(context: context, title: 'Actions', children: [
                  ElevatedButton(
                    onPressed: () {
                      StyledPopup(
                              context: context,
                              title: 'Restart Counter?',
                              children: [
                                Text(
                                    'Are you sure that you want to restart the counter? Your check-in data will be reset and lost.'),
                                TextFormField(
                                  controller: noteController,
                                  style: TextStyle(color: Color(0xff58865C)),
                                  keyboardType: TextInputType.multiline,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: 10,
                                  maxLength: 500,
                                  decoration: InputDecoration(
                                    hintText: "Description",
                                    contentPadding: EdgeInsets.all(10.0),
                                    labelStyle: CustomTheme
                                        .lightTheme.textTheme.bodyText2,
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(10.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                ),
                              ],
                              textButton: TextButton(
                                  onPressed: () async {
                                    await Database(uid).resetTrackerTask(
                                        task.id, noteController.text);
                                    noteController.clear();
                                    Provider.of<TabProvider>(context,
                                            listen: false)
                                        .rebuildPage('tracker');
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Reset',
                                      style:
                                          TextStyle(color: Colors.red[400]))))
                          .showPopup();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restart_alt_outlined),
                        Text('Restart Counter')
                      ],
                    ),
                    style: ElevatedButton.styleFrom(primary: Colors.orange),
                  ),
                  ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.share), Text('Share')],
                      )),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        Navigator.pop(context);
                        StyledPopup(
                            context: context,
                            title: 'Delete Tracker?',
                            children: [
                              Text(
                                  'This tracker and all of its data will be permanently deleted. Are you sure?')
                            ],
                            textButton: TextButton(
                              onPressed: () async {
                                await LoaderWithToast(
                                        context: context,
                                        api: Database(uid)
                                            .deleteTrackerTask(task.id),
                                        msg: 'Tracker deleted',
                                        isSuccess: true)
                                    .show();
                                Provider.of<TabProvider>(context, listen: false)
                                    .rebuildPage('tracker');
                                Provider.of<TabProvider>(context, listen: false)
                                    .rebuildPage('profileTracker');
                                Navigator.pop(context);
                              },
                              child: Text('Delete',
                                  style: TextStyle(color: Colors.red[400])),
                            )).showPopup();
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.delete), Text('Delete Tracker')],
                      ))
                ]).showPopup();
              },
              child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).backgroundColor,
                      boxShadow: CustomTheme.boxShadow),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(task['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .headline4
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withAlpha(200))),
                          Row(
                            children: [
                              Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: task['reminder'] != null
                                      ? Icon(Icons.notifications_active,
                                          color: CustomTheme.activeIcon,
                                          size: 25)
                                      : Icon(Icons.notifications_active,
                                          color: CustomTheme.inactiveIcon,
                                          size: 25)),
                              Text(
                                  '${DateTime.now().difference((task['currStreakDate'] as Timestamp).toDate()).inDays + 1}',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Icon(Icons.park_rounded,
                                  color: Color.fromARGB(255, 147, 182, 117))
                            ],
                          )
                        ],
                      ),
                      Divider(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Next Milestone',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                    task['milestones'].isEmpty
                                        ? '-'
                                        : getNextMilestone(
                                            task['milestones'],
                                            DateTime.now()
                                                    .difference(
                                                        (task['currStreakDate']
                                                                as Timestamp)
                                                            .toDate())
                                                    .inDays +
                                                1),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                StyledPopup(
                                        context: context,
                                        title: 'Milestones',
                                        children: [
                                          StatefulBuilder(
                                              builder: (context, _setState) {
                                            return Column(
                                              children: [
                                                task['milestones'].length > 0
                                                    ? ListView.builder(
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            task['milestones']
                                                                .length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return MilestonePopupTile(
                                                            milestone: task[
                                                                    'milestones']
                                                                [index],
                                                            index: index,
                                                            minDay: DateTime
                                                                        .now()
                                                                    .difference((task['currStreakDate']
                                                                            as Timestamp)
                                                                        .toDate())
                                                                    .inDays +
                                                                1,
                                                          );
                                                        })
                                                    : Text('No milestones.'),
                                              ],
                                            );
                                          }),
                                        ],
                                        cancelText: 'Done')
                                    .showPopup();
                              },
                              child: Icon(Icons.flag_rounded),
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  primary: Color.fromARGB(255, 252, 212, 93)),
                            ),
                          ],
                        ),
                      ),
                      Center(
                          child: ElevatedButton(
                              onPressed: hasLoaded.value
                                  ? currCheckIn != null
                                      ? () {
                                          checkInController.text =
                                              currCheckIn!['note'];
                                          checkInPopup(
                                              context,
                                              checkInController,
                                              snapshot.data.docs,
                                              (task['currStreakDate']
                                                      as Timestamp)
                                                  .toDate());
                                        }
                                      : () {
                                          checkInPopup(
                                              context,
                                              checkInController,
                                              snapshot.data.docs,
                                              (task['currStreakDate']
                                                      as Timestamp)
                                                  .toDate());
                                        }
                                  : () {},
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded),
                                  Text(
                                      hasLoaded.value
                                          ? currCheckIn != null
                                              ? 'Checked-in Today'
                                              : 'Check-in Today'
                                          : 'Check-in Today',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              style: ButtonStyle(
                                  backgroundColor: hasLoaded.value
                                      ? currCheckIn != null
                                          ? MaterialStateProperty.all(
                                              CustomTheme.completeColor)
                                          : MaterialStateProperty.all(
                                              CustomTheme.greyedButton)
                                      : MaterialStateProperty.all(
                                          CustomTheme.greyedButton),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.grey)))))),
                      Center(
                          child: IconButton(
                              icon: Icon(
                                Icons.more_horiz_rounded,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType
                                            .rightToLeftWithFade,
                                        child: TrackerDetailPage(
                                          task: task,
                                        )));
                              })),
                    ],
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class TrackerDetailPage extends HookWidget {
  const TrackerDetailPage({Key? key, required this.task}) : super(key: key);

  final task;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(
        () => Database(uid).getExpandedTrackerData(task.id),
        [Provider.of<TabProvider>(context).tracker]);
    final snapshot = useFuture(future);
    return Scaffold(
      appBar: AppBar(
        title: Text(task['title']),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                        child: Text(
                      task['note'],
                      style: TextStyle(fontSize: 15.sp),
                    )),
                  ),
                  Row(
                    children: [
                      Text(
                          '${DateTime.now().difference((task['currStreakDate'] as Timestamp).toDate()).inDays + 1}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.park_rounded,
                          color: Color.fromARGB(255, 147, 182, 117)),
                    ],
                  ),
                ],
              ),
              Text(
                  'Start Date: ${DateFormat('dd MMM yyyy').format((task['startDate'] as Timestamp).toDate())}'),
              Text(
                  'Current Streak Start Date: ${DateFormat('dd MMM yyyy').format((task['currStreakDate'] as Timestamp).toDate())}'),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              TextDivider('Notification'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(task['reminder'] != null
                      ? 'Everyday @ ${DateFormat('hh:mm a').format((task['reminder'] as Timestamp).toDate())}'
                      : 'No reminder'),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              snapshot.hasData
                  ? Column(
                      children: [
                        TextDivider('Check-ins'),
                        snapshot.data['checkin'].length > 0
                            ? CheckInList(
                                checkinList: snapshot.data['checkin'],
                                task: task)
                            : Text('No checkins'),
                        TextDivider('Resets'),
                        snapshot.data['resets'].length > 0
                            ? ResetList(resetList: snapshot.data['resets'])
                            : Text('No resets')
                      ],
                    )
                  : Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

// class ExpandedTracker extends HookWidget {
//   const ExpandedTracker({
//     Key? key,
//     required this.task,
//   }) : super(key: key);

//   final task;

//   Widget dividerLabel(msg) {
//     return Row(children: <Widget>[
//       Expanded(
//         child: new Container(
//             margin: const EdgeInsets.only(left: 10.0, right: 10.0),
//             child: Divider(
//               height: 4.h,
//               thickness: 3,
//             )),
//       ),
//       Text(
//         msg,
//         style: TextStyle(fontWeight: FontWeight.bold),
//       ),
//       Expanded(
//         child: new Container(
//             margin: const EdgeInsets.only(left: 10.0, right: 10.0),
//             child: Divider(
//               height: 4.h,
//               thickness: 3,
//             )),
//       ),
//     ]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String uid = Provider.of<UserProvider>(context).user.uid;
//     final future = useMemoized(
//         () => Database(uid).getExpandedTrackerData(task.id),
//         [Provider.of<TabProvider>(context).tracker]);
//     final snapshot = useFuture(future);
//     return Container(
//       width: 100.w,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             dividerLabel('PERSONAL NOTE'),
//             Text(
//               task['note'],
//               textAlign: TextAlign.justify,
//             )
//           ]),
//           Divider(color: Colors.transparent, height: 3.h),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               dividerLabel('START DATE'),
//               Text(
//                 '${DateFormat('dd MMM yy\t\t\t\t\t\thh:mm a').format((task['startDate'] as Timestamp).toDate())}',
//               ),
//             ],
//           ),
//           Divider(color: Colors.transparent, height: 3.h),
//           Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
//             dividerLabel('RESETS'),
//             snapshot.hasData
//                 ? snapshot.data['resets'].length > 0
//                     ? ListView.builder(
//                         shrinkWrap: true,
//                         itemCount: snapshot.data['resets'].length,
//                         itemBuilder: (context, index) => Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                     '${DateFormat('dd MMM yy').format((snapshot.data['resets'][index]['resetDate'] as Timestamp).toDate())}'),
//                                 Text(snapshot.data['resets'][index]['note'] !=
//                                         ''
//                                     ? '${snapshot.data['resets'][index]['note']}'
//                                     : '-')
//                               ],
//                             ))
//                     : Text('You have no resets')
//                 : CircularProgressIndicator(),
//           ]),
//           Divider(color: Colors.transparent, height: 3.h),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               dividerLabel('CHECK-IN'),
//               snapshot.hasData
//                   ? CheckInList(
//                       checkinList: snapshot.data['checkin'], task: task)
//                   : CircularProgressIndicator()
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }

class CheckInList extends HookWidget {
  const CheckInList({Key? key, required this.checkinList, required this.task})
      : super(key: key);

  final checkinList;
  final task;

  List generateDays(checkInData) {
    List<Map?> daysList = List.generate(
        (DateTime.now()
                .difference((task['currStreakDate'] as Timestamp).toDate())
                .inDays +
            1),
        (int index) => null);

    for (var i = 0; i < checkInData.length; i++) {
      daysList[(checkInData[i]['day'] as int) - 1] = {
        'note': checkInData[i]['note']
      };
    }
    return daysList.reversed.toList();
  }

  IndicatorStyle indicatorCheckedIn(timeline) {
    return IndicatorStyle(
      width: 30,
      height: 30,
      indicatorXY: 0,
      indicator: Container(
        decoration: BoxDecoration(
          color: timeline != null ? Colors.lightGreen[200] : Colors.grey[400],
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        child: Center(
          child: timeline != null
              ? Icon(
                  Icons.check_circle,
                  color: Colors.lightGreen[700],
                  size: 30,
                )
              : Container(
                  width: 25,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.grey[200]),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timelineData = generateDays(checkinList);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 100.w, maxHeight: 50.h),
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Colors.transparent,
              Colors.transparent,
              Colors.transparent,
              Colors.transparent,
              Colors.transparent,
              Colors.red
            ],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstOut,
        child: ListView.builder(
            physics: BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: timelineData.length,
            itemBuilder: (context, index) {
              final timeline = timelineData[index];
              return GestureDetector(
                onTap: timeline != null ? () {} : () {},
                child: TimelineTile(
                  isFirst: index == 0 ? true : false,
                  isLast: index == timelineData.length - 1 ? true : false,
                  alignment: TimelineAlign.manual,
                  lineXY: 0.2,
                  indicatorStyle: indicatorCheckedIn(timeline),
                  endChild: Container(
                      alignment: Alignment.topLeft,
                      padding:
                          const EdgeInsets.only(top: 3, left: 5, bottom: 10),
                      constraints: BoxConstraints(minHeight: 40),
                      color: Colors.transparent,
                      child: Text(
                          '${timeline != null ? timeline['note'] : 'Not checked-in'}',
                          textAlign: TextAlign.justify)),
                  startChild: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.only(top: 3),
                      constraints: BoxConstraints(minHeight: 40),
                      color: Colors.transparent,
                      child: Text('${timelineData.length - index}')),
                ),
              );
            }),
      ),
    );
  }
}

class ResetList extends StatelessWidget {
  const ResetList({Key? key, required this.resetList}) : super(key: key);

  final resetList;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: resetList.length,
      itemBuilder: (context, index) =>
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            '${DateFormat('dd MMM yy').format((resetList[index]['resetDate'] as Timestamp).toDate())}'),
        Text(resetList[index]['note'] != ''
            ? '${resetList[index]['note']}'
            : '-')
      ]),
    );
  }
}

class MilestonePopupTile extends StatelessWidget {
  const MilestonePopupTile({
    Key? key,
    required this.milestone,
    required this.index,
    required this.minDay,
  }) : super(key: key);

  final milestone;
  final index;
  final minDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  width: 30.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                      color: minDay < milestone['day']
                          ? CustomTheme.milestoneHeader
                          : CustomTheme.milestoneDoneHeader,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Center(
                      child: Text('Day ${milestone['day']}',
                          style: Theme.of(context).textTheme.headline4))),
            ],
          ),
          Container(
              width: 100.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: minDay < milestone['day']
                    ? CustomTheme.milestoneBody
                    : CustomTheme.milestoneDoneBody,
                border: Border.all(
                    color: minDay < milestone['day']
                        ? CustomTheme.milestoneHeader
                        : CustomTheme.milestoneDoneHeader,
                    width: 5),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                    topRight: Radius.circular(5)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(milestone['reward'])),
              )),
        ],
      ),
    );
  }
}
