import './addtodo.dart';
import './addtracker.dart';
import 'package:provider/provider.dart';
import '../../models/provider.dart';
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //Text(uid),
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
              ElevatedButton(
                  onPressed: () async => await Database(uid).signOut(context),
                  child: Text("Logout")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _tabController.index == 0
                                ? AddToDoTask()
                                : AddTrackerTask()));
                  },
                  child: Text("Add Task")),
            ]),
      ),
    );
  }

  Widget toDoTask(uid) {
    return StreamBuilder(
        stream: Database(uid).getToDoTasks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");

          return Container(child: Text("Hello"));
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
}
