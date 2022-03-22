import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import './addtodo.dart';
import '../../utils/allUtils.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
            ? SpinKitWanderingCubes(
                color: Colors.blueGrey,
                size: 75.0,
              )
            : snapshot.data.docs.length > 0
                ? Material(
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
                        }))
                : Center(
                    child: Text(
                        'You have no To Do tasks.\n\nYou can create tasks by\nhitting the button below!',
                        textAlign: TextAlign.center)));
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
