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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: 0,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(8, 30, 8, 30),
      child: Center(
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Column(
              children: [
                Text(uid),
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
              bottom: 0,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => _tabController.index == 0
                              ? AddToDoTask()
                              : AddTrackerTask()));
                },
                child: //Using ValueNotifier is better than StatefulBuilder TODO IN FUTURE
                    _tabController.index == 0
                        ? Text("Add To Do Task")
                        : Text("Add Tracker"),
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

          return Container(
            child: ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                return toDoListTile(snapshot.data.docs, index);
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

  Widget toDoListTile(task, index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(child: Text("Test")),
          ListTile(
            title: Text(task[index]["title"]),
            subtitle: Text(task[index]["desc"]),
            leading: Checkbox(
              value: false,
              onChanged: (value) {
                print(value);
              },
            ),
            trailing: Container(
                decoration: BoxDecoration(
                  border: Border(
                      left: BorderSide(color: Colors.grey[600]!, width: 1)),
                ),
                child:
                    IconButton(onPressed: () {}, icon: Icon(Icons.camera_alt))),
            horizontalTitleGap: 0,
            contentPadding: EdgeInsets.only(left: 0),
            tileColor: Colors.amber[400],
          ),
        ],
      ),
    );
  }
}
