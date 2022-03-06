import 'package:flutter_hooks/flutter_hooks.dart';
import './addtodo.dart';
import './addtracker.dart';
import '../../utils/allUtils.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';

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
                return toDoListTile(snapshot.data.docs, index, uid, context);
              },
            ),
          );
        });
  }

  Widget trackerTask(uid) {
    return StreamBuilder(
        stream: Database(uid).getToDoTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");

          return Container(
              child:
                  Text(Provider.of<UserProvider>(context, listen: false).uid));
        });
  }

  Widget toDoListTile(task, index, uid, context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(task[index]["title"]),
            Row(
              children: [
                task[index]["settings"]["recur"].contains(true)
                    ? Icon(Icons.repeat, color: Colors.blue, size: 20)
                    : Icon(Icons.repeat, color: Colors.black26, size: 20),
                task[index]["settings"]["reminder"] != null
                    ? Icon(Icons.notifications_active,
                        color: Colors.blue, size: 20)
                    : Icon(Icons.notifications_active,
                        color: Colors.black26, size: 20),
                task[index]["settings"]["deadline"] != null
                    ? Icon(Icons.alarm, color: Colors.blue, size: 20)
                    : Icon(Icons.alarm, color: Colors.black26, size: 20)
              ],
            ),
          ],
        ),
        subtitle: task[index]["desc"] != ""
            ? Container(
                decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(color: Colors.grey[600]!, width: 1))),
                child: Text(
                  task[index]["desc"],
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
          print("${task[index].id}");
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
                          Database(uid).deleteToDoTask(task[index].id);
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
