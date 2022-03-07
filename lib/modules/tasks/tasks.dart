import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import './addtodo.dart';
import './addtracker.dart';
import '../../utils/allUtils.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';
import 'package:shizen_app/modules/tasks/edittodo.dart';

class TaskPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
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
                    toDoTask(uid),
                    trackerTask(uid),
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
                              ? AddToDoTask()
                              : AddTrackerTask()));
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

  Widget toDoTask(uid) {
    return StreamBuilder(
        stream: Database(uid).getToDoTasks(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");

          return Material(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return toDoListTile(snapshot.data.docs[index], uid, context);
              },
            ),
          );
        });
  }

  Widget trackerTask(uid) {
    return StreamBuilder(
        stream: Database(uid).getTrackerTasks(),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");

          return Material(
            child: ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return TrackerTile(tracker: snapshot.data.docs[index]);
              },
            ),
          );
          ;
        });
  }

  Widget toDoListTile(task, uid, context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(task["title"]),
            Row(
              children: [
                task["settings"]["recur"].contains(true)
                    ? Icon(Icons.repeat, color: Colors.blue, size: 20)
                    : Icon(Icons.repeat, color: Colors.black26, size: 20),
                task["settings"]["reminder"] != null
                    ? Icon(Icons.notifications_active,
                        color: Colors.blue, size: 20)
                    : Icon(Icons.notifications_active,
                        color: Colors.black26, size: 20),
                task["settings"]["deadline"] != null
                    ? Icon(Icons.alarm, color: Colors.blue, size: 20)
                    : Icon(Icons.alarm, color: Colors.black26, size: 20)
              ],
            ),
          ],
        ),
        subtitle: task["desc"] != ""
            ? Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.grey[600]!, width: 1))),
                child: Text(
                  task["desc"],
                  maxLines: 2,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                ),
              )
            : null,
        leading: Checkbox(
          value: false,
          onChanged: (value) {
            print(value);
          },
        ),
        onTap: () {
          print("${task.id}");
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditToDoTask(
                        todoTask: task,
                      )));
        },
        onLongPress: () {
          OneContext().showDialog(
              builder: (_) => AlertDialog(
                    title: Text("Delete"),
                    content: Text("Do you want to delete this task?"),
                    actions: [
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                          Database(uid).deleteToDoTask(task.id);
                          OneContext().popDialog();
                        },
                      ),
                      TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            OneContext().popDialog();
                          })
                    ],
                  ));
        },
        trailing: Container(
            decoration: BoxDecoration(
              border:
                  Border(left: BorderSide(color: Colors.grey[600]!, width: 1)),
            ),
            child: IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt))),
        horizontalTitleGap: 0,
        contentPadding: EdgeInsets.all(0),
        tileColor: Colors.amberAccent[200],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class TrackerTile extends StatelessWidget {
  const TrackerTile({Key? key, required this.tracker}) : super(key: key);

  final tracker;

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
                        Text(tracker['title']),
                        Row(
                          children: [
                            Text(
                                'Day ${DateTime.now().difference((tracker['startDate'] as Timestamp).toDate()).inDays}'),
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
                          Text(
                              'Day ${tracker['milestones'].firstWhere((milestone) => milestone['isComplete'] == false, orElse: () => 'No milestone')['day'].toString()}'),
                          Text(tracker['milestones']
                              .firstWhere(
                                  (milestone) =>
                                      milestone['isComplete'] == false,
                                  orElse: () => 'No milestone')['reward']
                              .toString())
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
                    onPressed: () {},
                    child: Icon(Icons.flag),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.amber),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Icon(Icons.restart_alt_outlined),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Icon(Icons.share),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Icon(Icons.edit),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(), primary: Colors.grey),
                  ),
                  ElevatedButton(
                    onPressed: () {},
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
