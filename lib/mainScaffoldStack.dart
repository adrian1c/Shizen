import 'package:provider/provider.dart';
import 'package:shizen_app/utils/allUtils.dart';
import './modules/tasks/tasks.dart';
import './modules/friends/friends.dart';
import './modules/community/community.dart';
import './models/provider.dart';

class MainScaffoldStack extends StatefulWidget {
  MainScaffoldStack({Key? key, required this.uid}) : super(key: key);

  final String uid;

  final List<GButton> screens = [
    GButton(
      icon: Icons.home,
      text: 'Home',
    ),
    GButton(
      icon: Icons.people,
      text: 'Friends',
    ),
    GButton(
      icon: Icons.handyman,
      text: 'Community',
    ),
    GButton(
      icon: Icons.insert_chart_outlined_outlined,
      text: 'Progress',
    ),
    GButton(
      icon: Icons.person,
      text: 'Profile',
    ),
  ];

  final List<String> title = [
    "HOME",
    "FRIENDS",
    "COMMUNITY",
    "PROGRESS",
    "PROFILE"
  ];

  @override
  _MainScaffoldStackState createState() => _MainScaffoldStackState();
}

class _MainScaffoldStackState extends State<MainScaffoldStack> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>(
      lazy: false,
      create: (context) => UserProvider(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title[selectedIndex]),
            centerTitle: true,
          ),
          bottomNavigationBar: GNav(
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 5,
            activeColor: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            tabMargin: EdgeInsets.fromLTRB(5, 0, 5, 5),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[850]!,
            color: Colors.black,
            tabs: widget.screens,
            selectedIndex: selectedIndex,
            onTabChange: (index) => setState(() {
              selectedIndex = index;
            }),
          ),
          body: IndexedStack(
              index: selectedIndex,
              children: <Widget>[TaskPage(), FriendsPage(), CommunityPage()])),
    );
  }
}
