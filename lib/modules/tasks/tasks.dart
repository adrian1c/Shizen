import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import './addtodo.dart';
import './addtracker.dart';
import '../../utils/allUtils.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';
import 'package:shizen_app/modules/tasks/edittodo.dart';

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
                ColorfulTabBar(
                  tabs: [
                    TabItem(color: Colors.red, title: Text('To Do')),
                    TabItem(color: Colors.green, title: Text('Habit Tracker')),
                  ],
                  controller: tabController,
                ),
                Expanded(
                  child:
                      TabBarView(controller: tabController, children: <Widget>[
                    ToDoTask(
                      uid: uid,
                      todoChanged: todoChanged,
                    ),
                    TrackerTask(uid: uid, trackerChanged: trackerChanged),
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

class ToDoTask extends HookWidget {
  const ToDoTask({Key? key, required this.uid, required this.todoChanged})
      : super(key: key);

  final String uid;
  final todoChanged;

  static DateTime? convertTimestamp(Timestamp? _stamp) {
    if (_stamp != null) {
      return Timestamp(_stamp.seconds, _stamp.nanoseconds).toDate();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final future =
        useMemoized(() => Database(uid).getToDoTasks(), [todoChanged.value]);
    final snapshot = useFuture(future);
    return Container(
        child: !snapshot.hasData
            ? const Text('Loading')
            : Material(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var taskDoc = snapshot.data.docs[index];

                      return TodoTaskDisplay(
                          todoChanged: todoChanged,
                          taskId: taskDoc.id,
                          title: taskDoc['title'],
                          taskList: taskDoc['desc'],
                          recur: List<bool>.from(taskDoc['recur']),
                          reminder: convertTimestamp(taskDoc['reminder']));
                    })));
  }
}

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
    return Container(
        child: !snapshot.hasData
            ? const Text('Loading')
            : Material(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      return TrackerTile(
                          uid: uid,
                          task: snapshot.data.docs[index],
                          trackerChanged: trackerChanged);
                    })));
  }
}

class TodoTaskDisplay extends HookWidget {
  const TodoTaskDisplay(
      {Key? key,
      required this.todoChanged,
      required this.taskId,
      required this.title,
      required this.taskList,
      required this.recur,
      required this.reminder});

  final ValueNotifier<int> todoChanged;
  final String taskId;
  final String title;
  final taskList;
  final List<bool> recur;
  final DateTime? reminder;

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      AddToDoTask(todoChanged: todoChanged, editParams: {
                        'id': taskId,
                        'title': title,
                        'desc': taskList,
                        'recur': recur,
                        'reminder': reminder
                      })));
        },
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
                        color: Colors.amber,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15))),
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(title),
                    ))),
                Row(
                  children: [
                    recur.contains(true)
                        ? Icon(Icons.repeat, color: Colors.blue, size: 25)
                        : Icon(Icons.repeat, color: Colors.black26, size: 25),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: reminder != null
                          ? Icon(Icons.notifications_active,
                              color: Colors.blue, size: 25)
                          : Icon(Icons.notifications_active,
                              color: Colors.black26, size: 25),
                    )
                  ],
                ),
              ],
            ),
            ConstrainedBox(
                constraints: BoxConstraints(minHeight: 5.h, minWidth: 100.w),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber[200],
                      border: Border.all(color: Colors.amber, width: 5),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5),
                          topRight: Radius.circular(5)),
                    ),
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: taskList.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 8.h,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: taskList[index]['status']
                                      ? Colors.lightGreen[400]
                                      : null),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: taskList[index]['status'],
                                    onChanged: (value) async {
                                      taskList[index]['status'] = true;
                                      var allComplete = true;
                                      for (var i = 0;
                                          i < taskList.length;
                                          i++) {
                                        if (taskList[i]['status'] == false) {
                                          allComplete = false;
                                          break;
                                        }
                                      }
                                      allComplete
                                          ? await Database(uid)
                                              .completeTaskAll(taskId, taskList)
                                          : await Database(uid)
                                              .completeTask(taskId, taskList);

                                      todoChanged.value += 1;
                                      // StyledSnackbar(
                                      //         message:
                                      //             'Congratulations! I\'m proud of you')
                                      //     .showSuccess();
                                    },
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
    final dayController = useTextEditingController();
    final rewardController = useTextEditingController();
    final ValueNotifier<List<Map<String, dynamic>>> milestones = useState(
        (task['milestones'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList());
    final ValueNotifier<Map<String, dynamic>> nextMilestone = useState(
        milestones.value.firstWhere(
            (milestone) => milestone['isComplete'] == false,
            orElse: () => {}));
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
                          Text(nextMilestone.value.isEmpty
                              ? 'No milestone'
                              : 'Day ${nextMilestone.value['day'].toString()}'),
                          Text(nextMilestone.value.isEmpty
                              ? ''
                              : nextMilestone.value['reward'].toString())
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
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: milestones.value.length,
                                      itemBuilder: (context, index) {
                                        return MilestonePopupTile(
                                          milestone: milestones.value[index],
                                          milestonesList: milestones,
                                          index: index,
                                          minDay: DateTime.now()
                                              .difference((task['startDate']
                                                      as Timestamp)
                                                  .toDate())
                                              .inDays,
                                          dayController: dayController,
                                          rewardController: rewardController,
                                          callback: _setState,
                                        );
                                      }),
                                  IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (context) {
                                              final _formKey2 =
                                                  GlobalKey<FormState>();
                                              return AlertDialog(
                                                title:
                                                    Text('Add New Milestone'),
                                                content: Form(
                                                  key: _formKey2,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text('Day'),
                                                      TextFormField(
                                                        controller:
                                                            dayController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                          FilteringTextInputFormatter
                                                              .deny(RegExp(
                                                                  r'^0+')),
                                                        ],
                                                        validator: (value) {
                                                          String valueString =
                                                              value as String;
                                                          if (valueString
                                                              .isEmpty) {
                                                            return "Enter a day";
                                                          } else if (int.parse(
                                                                      valueString) <=
                                                                  DateTime.now()
                                                                      .difference((task['startDate']
                                                                              as Timestamp)
                                                                          .toDate())
                                                                      .inDays ||
                                                              !MilestoneList
                                                                  .checkDuplicate(
                                                                      task[
                                                                          'milestones'],
                                                                      valueString)) {
                                                            return "The milestone must be higher than the current streak or must contain no duplicates";
                                                          }
                                                        },
                                                      ),
                                                      Text('Text'),
                                                      TextFormField(
                                                        controller:
                                                            rewardController,
                                                        maxLength: 100,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                      child: Text('Add'),
                                                      onPressed: () {
                                                        if (_formKey2
                                                            .currentState!
                                                            .validate()) {
                                                          _setState(() {
                                                            milestones.value
                                                                .add({
                                                              'day': int.parse(
                                                                  dayController
                                                                      .text),
                                                              'reward':
                                                                  rewardController
                                                                      .text,
                                                              'isComplete':
                                                                  false,
                                                            });
                                                            milestones
                                                                .value = List<
                                                                    Map<String,
                                                                        dynamic>>.from(
                                                                milestones
                                                                    .value);
                                                            List<
                                                                    Map<String,
                                                                        dynamic>>
                                                                tempList =
                                                                milestones.value
                                                                    .toList();
                                                            tempList.sort((a,
                                                                    b) =>
                                                                a['day']
                                                                    .compareTo(b[
                                                                        'day']));
                                                            milestones.value =
                                                                tempList
                                                                    .toList();
                                                          });
                                                          dayController.clear();
                                                          rewardController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      }),
                                                  TextButton(
                                                      child: Text('Cancel'),
                                                      onPressed: () {
                                                        dayController.clear();
                                                        rewardController
                                                            .clear();
                                                        Navigator.pop(context);
                                                      }),
                                                ],
                                              );
                                            });
                                      },
                                      icon: Icon(Icons.add))
                                ],
                              );
                            }),
                          ],
                          textButton: TextButton(
                              onPressed: () {
                                nextMilestone.value = milestones.value
                                    .firstWhere(
                                        (milestone) =>
                                            milestone['isComplete'] == false,
                                        orElse: () => {});
                                trackerChanged.value += 1;
                                Database(uid)
                                    .editMilestones(task.id, milestones.value);
                                Navigator.pop(context);
                              },
                              child: Text('Save')),
                          cancelFunction: () {
                            StyledPopup(
                                    context: context,
                                    title: 'Are you sure?',
                                    children: [
                                      Text(
                                          'The changes that you have made will not be saved')
                                    ],
                                    textButton: TextButton(
                                        onPressed: () {
                                          milestones.value =
                                              (task['milestones'] as List)
                                                  .map((e) =>
                                                      e as Map<String, dynamic>)
                                                  .toList();
                                          Navigator.pop(context);
                                        },
                                        child: Text('Yes')))
                                .showPopup();
                          }).showPopup();
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
                      StyledPopup(
                        context: context,
                        title: 'Milestones',
                        children: [],
                      ).showPopup();
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
                              // StyledSnackbar(
                              //         message: 'The task has been deleted.')
                              //     .showSuccess();
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
  const MilestonePopupTile(
      {Key? key,
      required this.milestone,
      required this.milestonesList,
      required this.index,
      required this.minDay,
      required this.dayController,
      required this.rewardController,
      required this.callback})
      : super(key: key);

  final milestone;
  final milestonesList;
  final index;
  final minDay;
  final dayController;
  final rewardController;
  final callback;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: InkWell(
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
                InkWell(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Icon(Icons.delete),
                  ),
                  onTap: () {
                    StyledPopup(
                      context: context,
                      title: 'Delete Milestone?',
                      children: [],
                      textButton: TextButton(
                          child: Text('Delete'),
                          onPressed: () {
                            callback(() {
                              milestonesList.value.removeAt(index);
                              milestonesList.value =
                                  List<Map<String, dynamic>>.from(
                                      milestonesList.value);
                            });
                            Navigator.pop(context);
                          }),
                    ).showPopup();
                  },
                ),
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
        onTap: () {
          dayController.text = milestone['day'].toString();
          rewardController.text = milestone['reward'];
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                final _formKey3 = GlobalKey<FormState>();
                return AlertDialog(
                  title: Text('Edit Milestone'),
                  content: Form(
                    key: _formKey3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Day'),
                        TextFormField(
                          controller: dayController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            FilteringTextInputFormatter.deny(RegExp(r'^0+')),
                          ],
                          validator: (value) {
                            String valueString = value as String;
                            if (valueString.isEmpty) {
                              return "Enter a day";
                            } else if (int.parse(valueString) <= minDay ||
                                !MilestoneList.checkDuplicate(
                                    milestonesList.value, valueString)) {
                              return "The milestone must be higher than the current streak";
                            }
                          },
                        ),
                        Text('Text'),
                        TextFormField(
                          controller: rewardController,
                          maxLength: 100,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        child: Text('Save'),
                        onPressed: () {
                          if (_formKey3.currentState!.validate()) {
                            callback(() {
                              milestonesList.value[index]['day'] =
                                  int.parse(dayController.text);
                              milestonesList.value[index]['reward'] =
                                  rewardController.text;
                              milestonesList.value =
                                  List<Map<String, dynamic>>.from(
                                      milestonesList.value);
                              List<Map<String, dynamic>> tempList =
                                  milestonesList.value.toList();
                              tempList
                                  .sort((a, b) => a['day'].compareTo(b['day']));
                              milestonesList.value = tempList.toList();
                            });
                            dayController.clear();
                            rewardController.clear();
                            Navigator.pop(context);
                          }
                        }),
                    TextButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          dayController.clear();
                          rewardController.clear();
                          Navigator.pop(context);
                        }),
                  ],
                );
              });
        },
      ),
    );
  }
}
