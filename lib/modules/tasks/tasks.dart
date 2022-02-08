import 'package:shizen_app/widgets/button.dart';

import './addtodo.dart';
import './addtracker.dart';
import '../../utils/allUtils.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  late TabController _tabController;
  ValueNotifier _isSwitching = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
    _tabController.addListener(_handleTabSelection);
    _tabController.animation!.addListener(_handleTabAnimation);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  void _handleTabAnimation() {
    _tabController.animation!.value < 0.5
        ? _isSwitching.value = true
        : _isSwitching.value = false;
  }

  void _handleTabSelection() {
    if (_tabController.index == 0) {
      print(_tabController.index);
      _isSwitching.value = true;
    } else {
      _isSwitching.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  controller: _tabController,
                ),
                Expanded(
                  child:
                      TabBarView(controller: _tabController, children: <Widget>[
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
                          builder: (context) => _isSwitching.value
                              ? AddToDoTask()
                              : AddTrackerTask()));
                },
                child: ValueListenableBuilder(
                    valueListenable: _isSwitching,
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
                return toDoListTile(snapshot.data.docs, index, uid);
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

  Widget toDoListTile(task, index, uid) {
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
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Delete"),
                  content: Text("Do you want to delete this task?"),
                  actions: [
                    TextButton(
                      child: Text("Yes"),
                      onPressed: () {
                        Database(uid).deleteToDoTask(task[index].id);
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ],
                );
              });
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
