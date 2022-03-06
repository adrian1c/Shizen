import 'package:provider/provider.dart';
import 'package:shizen_app/modules/community/addnewpost.dart';
import 'package:shizen_app/utils/allUtils.dart';
import './modules/tasks/tasks.dart';
import './modules/friends/friends.dart';
import './modules/community/community.dart';
import './modules/progress/progress.dart';
import './modules/profile/profile.dart';
import './models/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class MainScaffoldStack extends HookWidget {
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
  Widget build(BuildContext context) {
    var pageController = usePageController();
    var selectedIndex = useState(0);
    return Scaffold(
        appBar: AppBar(
          title: Text(title[selectedIndex.value]),
          centerTitle: true,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(20)),
          child: GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 5,
              activeColor: Colors.white,
              iconSize: 20,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              tabMargin: EdgeInsets.fromLTRB(5, 10, 5, 10),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.grey[850]!,
              color: Colors.black,
              tabs: screens,
              selectedIndex: selectedIndex.value,
              onTabChange: (index) {
                selectedIndex.value = index;
                pageController.jumpToPage(selectedIndex.value);
              }),
        ),
        body: PageView(
            controller: pageController,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              TaskPage(),
              FriendsPage(),
              CommunityPage(),
              ProgressPage(),
              ProfilePage(),
            ]));
  }
}
