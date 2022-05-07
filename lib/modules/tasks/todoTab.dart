import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import './addtodo.dart';
import '../../utils/allUtils.dart';

class ToDoTask extends HookWidget {
  const ToDoTask({Key? key, required this.uid}) : super(key: key);

  final String uid;

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
    return Container(
        child: !snapshot.hasData
            ? SpinKitWanderingCubes(
                color: Colors.blueGrey,
                size: 75.0,
              )
            : snapshot.data.docs.length > 0
                ? ListView.builder(
                    physics: BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data.docs.length,
                    itemBuilder: (context, index) {
                      var taskDoc = snapshot.data.docs[index];
                      return TodoTaskDisplay(
                        taskId: taskDoc.id,
                        title: taskDoc['title'],
                        taskList: taskDoc['desc'],
                        recur: List<bool>.from(taskDoc['recur']),
                        reminder: convertTimestamp(taskDoc['reminder']),
                        isPublic: taskDoc['isPublic'],
                      );
                    })
                : Center(
                    child: Text(
                        'You have no To Do tasks.\n\nYou can create tasks by\nhitting the button below!',
                        textAlign: TextAlign.center)));
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
                    child: Text('Delete')))
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
                      child: Text(title,
                          style: Theme.of(context).textTheme.headline1),
                    ))),
                Row(
                  children: [
                    recur.contains(true)
                        ? Icon(Icons.repeat, color: Colors.blue, size: 25)
                        : Icon(Icons.repeat, color: Colors.black26, size: 25),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: reminder != null
                            ? DateTime.now().isBefore(reminder!)
                                ? ReminderIcon(
                                    reminder: reminder,
                                  )
                                : Icon(Icons.notifications_active,
                                    color: Colors.black26, size: 25)
                            : Icon(Icons.notifications_active,
                                color: Colors.black26, size: 25)),
                    isPublic
                        ? Icon(Icons.visibility, color: Colors.blue, size: 25)
                        : Icon(Icons.visibility,
                            color: Colors.black26, size: 25),
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
                            height: 5.h,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: taskList[index]['status']
                                      ? Colors.lightGreen[400]
                                      : null),
                              child: Row(
                                children: [
                                  Checkbox(
                                    shape: CircleBorder(),
                                    activeColor: Colors.lightGreen[700],
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
                                                  msg:
                                                      'Congratulations! I\'m proud of you',
                                                  isSuccess: true)
                                              .show();
                                      Provider.of<TabProvider>(context,
                                              listen: false)
                                          .rebuildPage('todo');
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
      return null;
    });
    return isBefore.value
        ? Icon(Icons.notifications_active, color: Colors.blue, size: 25)
        : Icon(Icons.notifications_active, color: Colors.black26, size: 25);
  }
}
