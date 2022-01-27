import '../../utils/allUtils.dart';
import 'package:flutter_colorful_tab/flutter_colorful_tab.dart';

class TaskPageWidget extends StatelessWidget {
  const TaskPageWidget({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  final TabController tabController;

  Widget build(BuildContext context) {
    return ColorfulTabBar(
      tabs: [
        TabItem(color: Colors.red, title: Text('To Do')),
        TabItem(color: Colors.green, title: Text('Habit Tracker')),
      ],
      controller: tabController,
    );
  }
}
