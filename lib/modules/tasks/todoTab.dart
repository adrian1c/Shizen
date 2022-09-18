import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shizen_app/modules/progress/routineprogress.dart';
import 'package:shizen_app/widgets/field.dart';
import './addtodo.dart';
import '../../utils/allUtils.dart';

class ToDoTask extends HookWidget {
  ToDoTask({Key? key, required this.uid, required this.controller})
      : super(key: key);

  final String uid;
  final controller;

  static DateTime? convertTimestamp(Timestamp? _stamp) {
    if (_stamp != null) {
      return Timestamp(_stamp.seconds, _stamp.nanoseconds).toDate();
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final future = useMemoized(
        () => Database(uid).getRoutines(),
        [Provider.of<TabProvider>(context).todo]);
    final snapshot = useFuture(future);

    final RefreshController refreshController =
      RefreshController(initialRefresh: false);

    if (snapshot.hasData) {
      var docsLength = snapshot.data.docs.length;

      return docsLength > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              if (index == snapshot.data.docs.length) {
                return Padding(padding: EdgeInsets.only(bottom: 10.h));
              }
              var taskDoc = snapshot.data.docs[index];
              return TodoTaskDisplay(
                  taskId: taskDoc.id,
                  title: taskDoc['title'],
                  taskList: taskDoc['desc'],
                  reminder: convertTimestamp(taskDoc['reminder']),
                  isPublic: taskDoc['isPublic'],
                  timesCompleted: taskDoc['timesCompleted'],
                  note: taskDoc['note']);
            }, childCount: snapshot.data.docs.length + 1))
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

class TodoTaskDisplay extends HookWidget {
  const TodoTaskDisplay({
    Key? key,
    required this.taskId,
    required this.title,
    required this.taskList,
    required this.reminder,
    required this.isPublic,
    required this.timesCompleted,
    required this.note,
  });

  final String taskId;
  final String title;
  final taskList;
  final DateTime? reminder;
  final bool isPublic;
  final int timesCompleted;
  final note;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final noteController = useTextEditingController();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: InkWell(
        onTap: () {
          StyledPopup(context: context, title: 'Choose an action', children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddToDoTask(
                                editParams: {
                                  'id': taskId,
                                  'title': title,
                                  'desc': taskList,
                                  'reminder': reminder,
                                  'isPublic': isPublic,
                                  'timesCompleted': timesCompleted,
                                  'note': note
                                },
                                isEdit: true,
                              )));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit),
                    Text('Edit Routine Details'),
                  ],
                ),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 15.0)),
                    backgroundColor: MaterialStateProperty.all(
                        Color.fromARGB(255, 138, 151, 175)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                                color: Color.fromARGB(255, 180, 188, 202)))))),
            Padding(padding: const EdgeInsets.only(top: 15)),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded),
                    Text('View Activity'),
                  ],
                ),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(vertical: 15.0)),
                    backgroundColor:
                        MaterialStateProperty.all(CustomTheme.completeColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(
                                color: Color.fromARGB(255, 188, 204, 181)))))),
            Padding(padding: const EdgeInsets.only(top: 50)),
            TextButton(
                onPressed: () {
                  StyledPopup(
                          context: context,
                          title: 'Delete Routine',
                          children: [
                            Text(
                                'Are you sure you want to delete this routine?\n\nAll of the activities and data will be removed forever!')
                          ],
                          textButton: TextButton(
                              onPressed: () async {
                                await LoaderWithToast(
                                        context: context,
                                        api: Database(uid)
                                            .deleteToDoTask(taskId),
                                        msg: 'Task Deleted',
                                        isSuccess: false)
                                    .show();
                                Provider.of<TabProvider>(context, listen: false)
                                    .rebuildPage('todo');
                                Navigator.pop(context);
                              },
                              child: Text('Delete',
                                  style: TextStyle(color: Colors.red[400]))))
                      .showPopup();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete),
                    Text('Delete Routine'),
                  ],
                ),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.all(
                      Color.fromARGB(255, 180, 103, 103)),
                )),
          ]).showPopup();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                        constraints:
                            BoxConstraints(minWidth: 25.w, minHeight: 5.h),
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withAlpha(200),
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Text(title,
                              style: Theme.of(context).textTheme.headline4),
                        ))),
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: reminder != null
                                ? DateTime.now().isBefore(reminder!)
                                    ? ReminderIcon(
                                        reminder: reminder,
                                      )
                                    : Icon(Icons.notifications_active_rounded,
                                        color: CustomTheme.inactiveIcon,
                                        size: 25)
                                : Icon(Icons.notifications_active_rounded,
                                    color: CustomTheme.inactiveIcon, size: 25)),
                        isPublic
                            ? Icon(Icons.visibility_rounded,
                                color: CustomTheme.activeIcon, size: 25)
                            : Icon(Icons.visibility_rounded,
                                color: CustomTheme.inactiveIcon, size: 25),
                      ],
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Text('$timesCompleted',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Icon(Icons.check_circle_rounded,
                            color: Color.fromARGB(255, 147, 182, 117))
                      ],
                    ))
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
                                      child: Checkbox(
                                        shape: CircleBorder(),
                                        activeColor:
                                            Theme.of(context).backgroundColor,
                                        checkColor: Colors.lightGreen[700],
                                        value: taskList[index]['status'],
                                        onChanged: (value) async {
                                          taskList[index]['status'] =
                                              taskList[index]['status']
                                                  ? false
                                                  : true;
                                          var allComplete = true;
                                          for (var i = 0;
                                              i < taskList.length;
                                              i++) {
                                            if (taskList[i]['status'] ==
                                                false) {
                                              allComplete = false;
                                              break;
                                            }
                                          }
                                          if (allComplete) {
                                            await LoaderWithToast(
                                                    context: context,
                                                    api: Database(uid)
                                                        .completeTaskAll(taskId,
                                                            taskList, note),
                                                    msg:
                                                        'Congratulations! I\'m proud of you',
                                                    isSuccess: true)
                                                .show();
                                            StyledPopup(
                                                context: context,
                                                title: 'Congratulations!',
                                                children: [
                                                  Text(
                                                      'Would you like to edit the details of this routine for the next completion?'),
                                                  ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        AddToDoTask(
                                                                          editParams: {
                                                                            'id':
                                                                                taskId,
                                                                            'title':
                                                                                title,
                                                                            'desc':
                                                                                taskList,
                                                                            'reminder':
                                                                                reminder,
                                                                            'isPublic':
                                                                                isPublic,
                                                                            'timesCompleted':
                                                                                timesCompleted,
                                                                            'note':
                                                                                note
                                                                          },
                                                                          isEdit:
                                                                              true,
                                                                        )));
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(Icons.edit),
                                                          Text(
                                                              'Edit Routine Details'),
                                                        ],
                                                      ),
                                                      style: ButtonStyle(
                                                          padding: MaterialStateProperty.all(
                                                              const EdgeInsets.symmetric(
                                                                  vertical:
                                                                      15.0)),
                                                          backgroundColor:
                                                              MaterialStateProperty.all(
                                                                  Color.fromARGB(
                                                                      255,
                                                                      138,
                                                                      151,
                                                                      175)),
                                                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                              RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(18.0),
                                                                  side: BorderSide(color: Color.fromARGB(255, 180, 188, 202)))))),
                                                ]).showPopup();
                                          } else {
                                            await LoaderWithToast(
                                                    context: context,
                                                    api: Database(uid)
                                                        .completeTask(
                                                            taskId, taskList),
                                                    msg: value!
                                                        ? 'Congratulations! Almost there!'
                                                        : 'Undo-ed',
                                                    isSuccess: true)
                                                .show();
                                          }
                                          Provider.of<TabProvider>(context,
                                                  listen: false)
                                              .rebuildPage('todo');
                                        },
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
                            vertical: 10.0,
                          ),
                          child: SizedBox(
                            height: 5.h,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: Icon(Icons.checklist_rounded,
                                        color: Colors.white),
                                    onPressed: () {
                                      StyledPopup(
                                          context: context,
                                          title: 'Mark All Complete',
                                          children: [
                                            Text(
                                                'Do you want to mark all tasks as complete? The routine will be considered as completed.')
                                          ],
                                          textButton: TextButton(
                                            child: Text('Yes'),
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await LoaderWithToast(
                                                      context: context,
                                                      api: Database(uid)
                                                          .completeTaskAll(
                                                              taskId,
                                                              taskList,
                                                              note),
                                                      msg:
                                                          'Congratulations! I\'m proud of you',
                                                      isSuccess: true)
                                                  .show();
                                              StyledPopup(
                                                  context: context,
                                                  title: 'Congratulations!',
                                                  children: [
                                                    Text(
                                                        'Would you like to edit the details of this routine for the next completion?'),
                                                    ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          AddToDoTask(
                                                                            editParams: {
                                                                              'id': taskId,
                                                                              'title': title,
                                                                              'desc': taskList,
                                                                              'reminder': reminder,
                                                                              'isPublic': isPublic,
                                                                              'timesCompleted': timesCompleted,
                                                                              'note': note
                                                                            },
                                                                            isEdit:
                                                                                true,
                                                                          )));
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(Icons.edit),
                                                            Text(
                                                                'Edit Routine Details'),
                                                          ],
                                                        ),
                                                        style: ButtonStyle(
                                                            padding: MaterialStateProperty.all(
                                                                const EdgeInsets.symmetric(
                                                                    vertical:
                                                                        15.0)),
                                                            backgroundColor:
                                                                MaterialStateProperty.all(
                                                                    Color.fromARGB(
                                                                        255,
                                                                        138,
                                                                        151,
                                                                        175)),
                                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                                                RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(18.0),
                                                                    side: BorderSide(color: Color.fromARGB(255, 180, 188, 202)))))),
                                                  ]).showPopup();
                                              Provider.of<TabProvider>(context,
                                                      listen: false)
                                                  .rebuildPage('todo');
                                            },
                                          )).showPopup();
                                    },
                                  ),
                                ),
                                VerticalDivider(
                                    width: 5,
                                    thickness: 2,
                                    indent: 0,
                                    endIndent: 0,
                                    color: Colors.white),
                                Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            noteController.text = note;
                                            showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                        title: Text(
                                                            'Routine Note'),
                                                        content: TextFormField(
                                                          controller:
                                                              noteController,
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff58865C)),
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .sentences,
                                                          maxLines: 10,
                                                          maxLength: 500,
                                                          decoration:
                                                              InputDecoration(
                                                            hintText:
                                                                "Description",
                                                            contentPadding:
                                                                EdgeInsets.all(
                                                                    10.0),
                                                            labelStyle:
                                                                CustomTheme
                                                                    .lightTheme
                                                                    .textTheme
                                                                    .bodyText2,
                                                            border:
                                                                OutlineInputBorder(
                                                              borderSide:
                                                                  new BorderSide(),
                                                            ),
                                                          ),
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Content cannot be empty';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                              onPressed:
                                                                  () async {
                                                                if (noteController
                                                                        .text !=
                                                                    '') {
                                                                  await LoaderWithToast(
                                                                          context:
                                                                              context,
                                                                          api: Database(uid).addRoutineNote(
                                                                              taskId,
                                                                              noteController
                                                                                  .text),
                                                                          msg:
                                                                              'Note added',
                                                                          isSuccess:
                                                                              true)
                                                                      .show();
                                                                  Provider.of<TabProvider>(
                                                                          context,
                                                                          listen:
                                                                              false)
                                                                      .rebuildPage(
                                                                          'todo');
                                                                  noteController
                                                                      .clear();
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                              child:
                                                                  Text("Save")),
                                                          TextButton(
                                                            onPressed: () {
                                                              noteController
                                                                  .clear();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child:
                                                                Text("Cancel"),
                                                          ),
                                                        ]));
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: note != ''
                                                ? [
                                                    Icon(Icons
                                                        .check_circle_outline_rounded),
                                                    Text(' Note',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ]
                                                : [
                                                    Text('Add Note',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white))
                                                  ],
                                          ),
                                          style: ButtonStyle(
                                              backgroundColor: note != ''
                                                  ? MaterialStateProperty.all(
                                                      CustomTheme.completeColor)
                                                  : MaterialStateProperty.all(
                                                      CustomTheme.greyedButton),
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              18.0),
                                                      side: BorderSide(
                                                          color:
                                                              Colors.grey))))),
                                    )),
                                VerticalDivider(
                                    width: 5,
                                    thickness: 2,
                                    indent: 0,
                                    endIndent: 0,
                                    color: Colors.white),
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: Icon(Icons.camera_alt_rounded),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                                  title: Text('Coming Soon!'),
                                                  content: Text(
                                                      'Feature is currently being developed. Please bear with us'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("OK"),
                                                    ),
                                                  ]));
                                    },
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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

class ReminderIcon extends HookWidget {
  const ReminderIcon({Key? key, required this.reminder}) : super(key: key);

  final reminder;

  @override
  Widget build(BuildContext context) {
    final isBefore = useState(true);
    useEffect(() {
      Timer.periodic(Duration(seconds: 1), (time) {
        if (DateTime.now().isAfter(reminder)) {
          isBefore.value = false;
        }
      });
      return () {
        Timer.periodic(Duration(seconds: 1), (time) {
          if (DateTime.now().isAfter(reminder)) {
            isBefore.value = false;
          }
        });
      };
    });
    return isBefore.value
        ? Icon(Icons.notifications_active,
            color: CustomTheme.activeIcon, size: 25)
        : Icon(Icons.notifications_active,
            color: CustomTheme.inactiveIcon, size: 25);
  }
}
