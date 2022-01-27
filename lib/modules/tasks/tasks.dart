import 'package:shizen_app/modules/tasks/addToDoTask/addToDo.dart';

import '../../utils/allUtils.dart';
import './widgets.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key, required this.uid}) : super(key: key);

  final String uid;
  @override
  _TaskPageState createState() => _TaskPageState(uid: uid);
}

class _TaskPageState extends State<TaskPage> with TickerProviderStateMixin {
  final String uid;
  late TabController _tabController;

  _TaskPageState({required this.uid});

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TASK"),
        centerTitle: true,
      ),
      body: SafeArea(
        minimum: EdgeInsets.fromLTRB(8, 30, 8, 30),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <
              Widget>[
            Text(uid),
            TaskPageWidget(
              tabController: _tabController,
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: <Widget>[
                toDoTask(),
                trackerTask(),
              ]),
            ),
            ElevatedButton(
                onPressed: () async => await Database().signOut(context),
                child: Text("Logout")),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddToDoTask()));
                },
                child: Text("Add Task")),
          ]),
        ),
      ),
    );
  }

  Widget toDoTask() {
    return StreamBuilder(
        stream: Database().getToDoTasks(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");

          return Container(child: Text("Hello"));
        });
  }

  Widget trackerTask() {
    return StreamBuilder(
        stream: Database().getToDoTasks(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Loading...");

          return Container(child: Text("Hello"));
        });
  }
}
