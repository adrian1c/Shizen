import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/todoTab.dart';
import 'package:shizen_app/utils/allUtils.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddToDoTask(
                      editParams: {
                        'id': taskDoc.id,
                        'title': taskDoc['title'],
                        'desc': taskList,
                        'recur': List<bool>.from(taskDoc['recur']),
                        'reminder':
                            ToDoTask.convertTimestamp(taskDoc['reminder']),
                        'isPublic': taskDoc['isPublic'],
                      },
                      isEdit: true,
                    ),
                  ),
                );
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
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    constraints: BoxConstraints(minWidth: 25.w),
                    height: 5.h,
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
                          return SizedBox(
                            height: 5.h,
                            child: Container(
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
                                    child: Checkbox(
                                      shape: CircleBorder(),
                                      activeColor:
                                          Theme.of(context).backgroundColor,
                                      checkColor: Colors.lightGreen[700],
                                      value: taskList[index]['status'],
                                      onChanged: (value) async {},
                                    ),
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
