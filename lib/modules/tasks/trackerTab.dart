import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/modules/tasks/addtracker.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TrackerTask extends HookWidget {
  const TrackerTask({Key? key, required this.uid, required this.trackerChanged})
      : super(key: key);

  final String uid;
  final trackerChanged;

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(
        () => Database(uid).getTrackerTasks(), [trackerChanged.value]);
    final snapshot = useFuture(future);
    if (!snapshot.hasData) {
      return Container(
          child: SpinKitWanderingCubes(color: Colors.blueGrey, size: 75));
    }

    return Container(
        child: snapshot.data.docs.length > 0
            ? Material(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return TrackerTile(
                          uid: uid,
                          task: snapshot.data.docs[index],
                          trackerChanged: trackerChanged);
                    }))
            : Center(
                child: Text(
                    'You have no Daily Trackers.\n\nYou can create tasks by\nhitting the button below!',
                    textAlign: TextAlign.center)));
  }
}

class TrackerTile extends HookWidget {
  const TrackerTile({
    Key? key,
    required this.task,
    required this.uid,
    required this.trackerChanged,
  }) : super(key: key);

  final task;
  final String uid;
  final trackerChanged;

  List generateDays(checkInData) {
    List<Map?> daysList = List.generate(
        (DateTime.now()
                .difference((task['startDate'] as Timestamp).toDate())
                .inDays +
            2),
        (int index) => null);

    for (var i = 0; i < checkInData.length; i++) {
      daysList[(checkInData[i]['day'] as int) - 1] = {
        'note': checkInData[i]['note']
      };
    }

    return daysList;
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

  checkInPopup(
    context,
    controller,
  ) {
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
                          await Database(uid).checkInTracker(
                              task.id,
                              DateTime.now()
                                  .difference(
                                      (task['startDate'] as Timestamp).toDate())
                                  .inDays,
                              controller.text,
                              null);
                          controller.clear();
                          trackerChanged.value += 1;
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

  @override
  Widget build(BuildContext context) {
    final checkInController = useTextEditingController();
    final timelineData = generateDays(task['checkin']);
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
                  'startDate': (task['startDate'] as Timestamp).toDate(),
                  'milestones': task['milestones']
                };
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddTrackerTask(
                          trackerChanged: trackerChanged,
                          editParams: editParams),
                    ));
              },
              onLongPress: () {
                StyledPopup(context: context, title: 'Actions', children: [
                  ElevatedButton(
                    onPressed: () {
                      StyledPopup(
                        context: context,
                        title: 'Milestones',
                        children: [],
                      ).showPopup();
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
                                await Database(uid).deleteTrackerTask(task.id);
                                Navigator.pop(context);
                                StyledToast(msg: 'Tracker deleted')
                                    .showDeletedToast();
                                trackerChanged.value += 1;
                              },
                              child: Text('Delete'),
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
                      border: Border.all(color: Colors.blueGrey, width: 5),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(task['title']),
                          Row(
                            children: [
                              Text(
                                  'Day ${DateTime.now().difference((task['startDate'] as Timestamp).toDate()).inDays}'),
                              Icon(Icons.brush)
                            ],
                          )
                        ],
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: 100.w, minHeight: 10.h, maxHeight: 30.h),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Colors.red,
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
                              reverse: true,
                              itemCount: timelineData.length,
                              itemBuilder: (context, index) {
                                final timeline = timelineData[index];
                                return GestureDetector(
                                  onTap: timeline != null ? () {} : () {},
                                  child: TimelineTile(
                                    alignment: TimelineAlign.manual,
                                    lineXY: 0.25,
                                    indicatorStyle:
                                        indicatorCheckedIn(timeline),
                                    endChild: Container(
                                        alignment: Alignment.topLeft,
                                        padding: const EdgeInsets.only(
                                            top: 3, left: 5, bottom: 10),
                                        constraints:
                                            BoxConstraints(minHeight: 40),
                                        color: Colors.transparent,
                                        child: Text(
                                            '${timeline != null ? timeline['note'] : ''}',
                                            textAlign: TextAlign.justify)),
                                    startChild: Container(
                                        alignment: Alignment.topCenter,
                                        padding: const EdgeInsets.only(top: 3),
                                        constraints:
                                            BoxConstraints(minHeight: 40),
                                        color: Colors.transparent,
                                        child: Text('${index + 1}')),
                                  ),
                                );
                              }),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Next Milestone'),
                                Text(task['milestones'].isEmpty
                                    ? 'No milestone'
                                    : 'Day ${task['milestones'][0]['day']}'),
                                Text(task['milestones'].isEmpty
                                    ? ''
                                    : task['milestones'][0]['reward'])
                              ],
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
                                                ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    itemCount:
                                                        task['milestones']
                                                            .length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return MilestonePopupTile(
                                                        milestone:
                                                            task['milestones']
                                                                [index],
                                                        index: index,
                                                        minDay: DateTime.now()
                                                            .difference((task[
                                                                        'startDate']
                                                                    as Timestamp)
                                                                .toDate())
                                                            .inDays,
                                                      );
                                                    }),
                                              ],
                                            );
                                          }),
                                        ],
                                        cancelText: 'Done')
                                    .showPopup();
                              },
                              child: Icon(Icons.flag),
                              style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(), primary: Colors.amber),
                            ),
                          ],
                        ),
                      ),
                      Center(
                          child: ElevatedButton(
                              onPressed: timelineData[timelineData.length - 1] !=
                                      null
                                  ? () {
                                      checkInController.text =
                                          timelineData[timelineData.length - 1]
                                              ['note'];
                                      checkInPopup(context, checkInController);
                                    }
                                  : () {
                                      checkInPopup(context, checkInController);
                                    },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle_outline_rounded),
                                  Text(
                                      timelineData[timelineData.length - 1] !=
                                              null
                                          ? 'Checked-in Today'
                                          : 'Check-in Today',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              style: ButtonStyle(
                                  backgroundColor:
                                      timelineData[timelineData.length - 1] !=
                                              null
                                          ? MaterialStateProperty.all(
                                              Colors.lightGreen[400])
                                          : MaterialStateProperty.all(
                                              Colors.grey[400]),
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color: Colors.grey))))))
                    ],
                  )),
            ),
          ),
        ],
      ),
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
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Center(child: Text('Day ${milestone['day']}'))),
            ],
          ),
          Container(
              width: 100.w,
              height: 7.h,
              decoration: BoxDecoration(
                color: Colors.amber[200],
                border: Border.all(color: Colors.amber, width: 5),
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
