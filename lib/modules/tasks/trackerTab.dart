import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/modules/tasks/addtracker.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 10,
            child: Container(
                padding: const EdgeInsets.all(20.0),
                height: 35.h,
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
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
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
                    ),
                  ],
                )),
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      StyledPopup(
                              context: context,
                              title: 'Milestones',
                              children: [
                                StatefulBuilder(builder: (context, _setState) {
                                  return Column(
                                    children: [
                                      ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: task['milestones'].length,
                                          itemBuilder: (context, index) {
                                            return MilestonePopupTile(
                                              milestone: task['milestones']
                                                  [index],
                                              index: index,
                                              minDay: DateTime.now()
                                                  .difference((task['startDate']
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
                  ElevatedButton(
                    onPressed: () {
                      StyledPopup(
                        context: context,
                        title: 'Milestones',
                        children: [],
                      ).showPopup();
                    },
                    child: Icon(Icons.restart_alt_outlined),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      StyledPopup(
                        context: context,
                        title: 'Milestones',
                        children: [],
                      ).showPopup();
                    },
                    child: Icon(Icons.share),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: () {
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
                    child: Icon(Icons.edit),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.grey),
                  ),
                  ElevatedButton(
                    onPressed: () {
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
                    child: Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.orange),
                  ),
                ],
              ),
            ),
          )
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
