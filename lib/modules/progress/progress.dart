import 'package:shizen_app/modules/tasks/tasks.dart';

import '../../utils/allUtils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ProgressPage extends HookWidget {
  const ProgressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filterValue = useState(null);
    final searchValue = useState(null);
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: false,
          snap: false,
          floating: true,
          expandedHeight: 11.h,
          collapsedHeight: 11.h,
          flexibleSpace: Container(
            decoration:
                BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_alt),
                          Text("Filter", style: TextStyle(fontSize: 15.sp)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
          return TodoTaskProgressList(
              filterValue: filterValue, searchValue: searchValue);
        }, childCount: 1))
      ],
    );
  }
}

class TodoTaskProgressList extends HookWidget {
  const TodoTaskProgressList(
      {Key? key, required this.filterValue, required this.searchValue})
      : super(key: key);

  final filterValue;
  final searchValue;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).uid;
    final future = useMemoized(
        () =>
            Database(uid).getProgressList(filterValue.value, searchValue.value),
        [filterValue.value, searchValue.value]);
    final snapshot = useFuture(future);
    return Container(
        child: !snapshot.hasData
            ? const Text("Loading")
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  var taskDoc = snapshot.data.docs[index];

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: TodoTaskProgressTile(
                      taskId: taskDoc.id,
                      title: taskDoc['title'],
                      taskList: taskDoc['desc'],
                    ),
                  );
                }));
  }
}

class TodoTaskProgressTile extends StatelessWidget {
  const TodoTaskProgressTile({
    Key? key,
    required this.taskId,
    required this.title,
    required this.taskList,
  }) : super(key: key);

  final String taskId;
  final String title;
  final taskList;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
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
                      shrinkWrap: true,
                      itemCount: taskList.length,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 8.h,
                          child: Container(
                            decoration: BoxDecoration(
                                color: taskList[index]['status']
                                    ? Colors.lightGreen[400]
                                    : null),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: taskList[index]['status'],
                                  onChanged: (value) {},
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
    );
  }
}
