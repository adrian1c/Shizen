import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shizen_app/modules/progress/routineprogress.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/todoTab.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/widgets/field.dart';

class ToDoTileShare extends StatelessWidget {
  const ToDoTileShare({
    Key? key,
    required this.ownProfile,
    required this.taskDoc,
    required this.taskList,
    required this.title,
  }) : super(key: key);

  final bool ownProfile;
  final taskDoc;
  final taskList;
  final title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: InkWell(
        onTap: ownProfile
            ? () async {
                StyledPopup(
                  context: context,
                  title: 'Choose an action',
                  children: [
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          List task = [];
                          var tempTaskList = taskList;

                          for (var i = 0; i < tempTaskList.length; i++) {
                            var tempMap = {
                              'task': tempTaskList[i]['task'],
                              'status': false
                            };
                            task.add(tempMap);
                          }
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddToDoTask(
                                  editParams: {
                                    'title': title,
                                    'desc': task,
                                    'reminder': null,
                                    'isPublic': false,
                                    'timesCompleted': 0,
                                    'note': ''
                                  },
                                  isEdit: false,
                                ),
                              ));
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.track_changes),
                            Text('Create Similar Routine'),
                          ],
                        ),
                        style: ButtonStyle(
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 15.0)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromARGB(255, 138, 151, 175)),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: Color.fromARGB(
                                            255, 180, 188, 202)))))),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
                    ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      title: Text(title),
                                      centerTitle: true,
                                    ),
                                    body: RoutineProgressPage(
                                      tid: taskDoc.id,
                                      title: title,
                                      timesCompleted: taskDoc['timesCompleted'],
                                    )),
                              ));
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
                            backgroundColor: MaterialStateProperty.all(
                                CustomTheme.completeColor),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: Color.fromARGB(
                                            255, 188, 204, 181)))))),
                  ],
                ).showPopup();
              }
            : () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                          title: Text('Create Similar Task?'),
                          actions: [
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
                                          'reminder': null,
                                          'isPublic': false,
                                          'timesCompleted':
                                              taskDoc['timesCompleted'],
                                          'note': taskDoc['note']
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
                  Text(title,
                      style: Theme.of(context).textTheme.headline4?.copyWith(
                          color:
                              Theme.of(context).primaryColor.withAlpha(200))),
                  Row(
                    children: [
                      Text('${taskDoc['timesCompleted']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Icon(Icons.check_circle_rounded,
                          color: Color.fromARGB(255, 147, 182, 117))
                    ],
                  )
                ],
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 5)),
              Divider(),
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
                      ),
                      child: Row(
                        children: [
                          AbsorbPointer(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                shape: CircleBorder(),
                                activeColor: Theme.of(context).backgroundColor,
                                checkColor: Colors.lightGreen[700],
                                value: taskList[index]['status'],
                                onChanged: (value) {},
                              ),
                            ),
                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(taskList[index]['task'],
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                      decoration: taskList[index]['status']
                                          ? TextDecoration.lineThrough
                                          : null)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class ToDoTileDisplay extends StatelessWidget {
  const ToDoTileDisplay({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    var title = data['title'];
    var timeCompleted = data['timeCompleted'];
    var taskList = data['taskList'];

    return InkWell(
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(title: Text('Create Similar Task?'), actions: [
                TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      List task = [];
                      var taskList = data['taskList'];
                      var title = data['title'];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  constraints: BoxConstraints(
                      minWidth: 20.w, maxWidth: 40.w, minHeight: 5.h),
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
              Text('$timeCompleted',
                  style: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontSize: 10.sp)),
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
                              AbsorbPointer(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
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
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(taskList[index]['task'],
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(
                                          decoration: taskList[index]['status']
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
    );
  }
}

class TrackerTileDisplay extends StatelessWidget {
  const TrackerTileDisplay({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Text(data['title'],
                  style: Theme.of(context).textTheme.headline4?.copyWith(
                      color: Theme.of(context).primaryColor.withAlpha(200))),
              Row(
                children: [
                  Text('${data['currStreak']}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(Icons.check_circle_rounded,
                      color: Color.fromARGB(255, 147, 182, 117))
                ],
              )
            ],
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
          Divider(),
          Text(data['note'])
        ],
      ),
    );
  }
}
