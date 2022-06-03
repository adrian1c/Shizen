import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import './addtodo.dart';
import '../../utils/allUtils.dart';

class ToDoTask extends HookWidget {
  const ToDoTask({Key? key, required this.uid, required this.controller})
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
    final future = useMemoized(() => Database(uid).getToDoTasks(),
        [Provider.of<TabProvider>(context).todo]);
    final snapshot = useFuture(future);

    if (snapshot.hasData) {
      var docsLength = snapshot.data.docs.length;

      return docsLength > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              var taskDoc = snapshot.data.docs[index];
              return TodoTaskDisplay(
                taskId: taskDoc.id,
                title: taskDoc['title'],
                taskList: taskDoc['desc'],
                recur: List<bool>.from(taskDoc['recur']),
                reminder: convertTimestamp(taskDoc['reminder']),
                isPublic: taskDoc['isPublic'],
              );
            }, childCount: snapshot.data.docs.length))
          : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                  child: Text(
                    'You have no to do tasks.\n You can create tasks by clicking on the button below!',
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

class TodoTaskDisplay extends StatelessWidget {
  const TodoTaskDisplay({
    Key? key,
    required this.taskId,
    required this.title,
    required this.taskList,
    required this.recur,
    required this.reminder,
    required this.isPublic,
  });

  final String taskId;
  final String title;
  final taskList;
  final List<bool> recur;
  final DateTime? reminder;
  final bool isPublic;

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
                  builder: (context) => AddToDoTask(
                        editParams: {
                          'id': taskId,
                          'title': title,
                          'desc': taskList,
                          'recur': recur,
                          'reminder': reminder,
                          'isPublic': isPublic,
                        },
                        isEdit: true,
                      )));
        },
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
                Row(
                  children: [
                    // recur.contains(true)
                    //     ? Icon(Icons.repeat_rounded,
                    //         color: CustomTheme.activeIcon, size: 25)
                    //     : Icon(Icons.repeat_rounded,
                    //         color: CustomTheme.inactiveIcon, size: 25),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: reminder != null
                            ? DateTime.now().isBefore(reminder!)
                                ? ReminderIcon(
                                    reminder: reminder,
                                  )
                                : Icon(Icons.notifications_active_rounded,
                                    color: CustomTheme.inactiveIcon, size: 25)
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
                                        if (taskList[i]['status'] == false) {
                                          allComplete = false;
                                          break;
                                        }
                                      }
                                      allComplete
                                          ? await LoaderWithToast(
                                                  context: context,
                                                  api: Database(uid)
                                                      .completeTaskAll(
                                                          taskId, taskList),
                                                  msg:
                                                      'Congratulations! I\'m proud of you',
                                                  isSuccess: true)
                                              .show()
                                          : await LoaderWithToast(
                                                  context: context,
                                                  api: Database(uid)
                                                      .completeTask(
                                                          taskId, taskList),
                                                  msg: value!
                                                      ? 'Congratulations! Almost there!'
                                                      : 'Undo-ed',
                                                  isSuccess: true)
                                              .show();
                                      Provider.of<TabProvider>(context,
                                              listen: false)
                                          .rebuildPage('todo');
                                      Provider.of<TabProvider>(context,
                                              listen: false)
                                          .rebuildPage('progress');
                                    },
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
