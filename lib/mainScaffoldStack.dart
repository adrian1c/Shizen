import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:provider/provider.dart';
import 'package:shizen_app/models/user.dart';
import 'package:shizen_app/modules/community/addnewpost.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/addtracker.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import './modules/tasks/tasks.dart';
import './modules/friends/friends.dart';
import './modules/community/community.dart';
import './modules/progress/progress.dart';
import './modules/profile/profile.dart';
import './models/provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';

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
    final ValueNotifier<bool> isSwitching = useState(true);
    return Scaffold(
        appBar: AppBar(
          title: Text(title[
              Provider.of<TabProvider>(context, listen: false).selectedIndex]),
          centerTitle: true,
          actions:
              Provider.of<TabProvider>(context, listen: false).selectedIndex ==
                      2
                  ? [
                      TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNewPost())),
                          child: Text('POST',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                    ]
                  : null,
        ),
        drawer: NavDrawer(),
        floatingActionButton:
            Provider.of<TabProvider>(context, listen: false).selectedIndex == 0
                ? FABubble()
                : null,
        bottomNavigationBar: GNav(
            backgroundColor: Colors.grey[400]!,
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
            selectedIndex: Provider.of<TabProvider>(context).selectedIndex,
            onTabChange: (index) {
              Provider.of<TabProvider>(context, listen: false)
                  .changeTabPage(index);
            }),
        body: DoubleBackToCloseApp(
          snackBar: SnackBar(
            duration: Duration(seconds: 2),
            backgroundColor: Colors.grey,
            width: 60.w,
            elevation: 2,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Back again to leave',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          child: PageView(
              controller: Provider.of<TabProvider>(context, listen: false)
                  .pageController,
              physics: NeverScrollableScrollPhysics(),
              children: <Widget>[
                KeepAlivePage(child: TaskPage(isSwitching: isSwitching)),
                KeepAlivePage(child: FriendsPage()),
                KeepAlivePage(child: CommunityPage()),
                KeepAlivePage(child: ProgressPage()),
                KeepAlivePage(child: ProfilePage()),
              ]),
        ));
  }
}
// child: Icon(Icons.add),
// shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(10.0))),
// backgroundColor: Color(0xff233141),
// onPressed: () {

// },

class FABubble extends StatefulWidget {
  FABubble({Key? key}) : super(key: key);

  @override
  _FABubbleState createState() => _FABubbleState();
}

class _FABubbleState extends State<FABubble>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionBubble(
      // Menu items
      items: <Bubble>[
        // Floating action menu item
        Bubble(
          title: "Add To Do Task",
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
          icon: Icons.people,
          titleStyle: TextStyle(fontSize: 16, color: Colors.white),
          onPress: () async {
            _animationController.reverse();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddToDoTask()));
          },
        ),
        //Floating action menu item
        Bubble(
          title: "Add Daily Tracker",
          iconColor: Colors.white,
          bubbleColor: Colors.blue,
          icon: Icons.home,
          titleStyle: TextStyle(fontSize: 16, color: Colors.white),
          onPress: () {
            _animationController.reverse();
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AddTrackerTask()));
          },
        ),
      ],

      // animation controller
      animation: _animation,

      // On pressed change animation state
      onPress: () => _animationController.isCompleted
          ? _animationController.reverse()
          : _animationController.forward(),

      // Floating Action button Icon color
      iconColor: Colors.blue,

      // Flaoting Action button Icon
      iconData: Icons.add,
      backGroundColor: Colors.white,
    );
  }
}

class NavDrawer extends HookWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserModel user = Provider.of<UserProvider>(context).user;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: Text(user.email,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                    fontSize: 10)),
            accountName: Text(user.name,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.normal,
                    fontSize: 20)),
            currentAccountPicture: InkWell(
              child: CircleAvatar(
                foregroundImage: user.image == ''
                    ? Images.defaultPic.image
                    : CachedNetworkImageProvider(user.image),
                backgroundColor: Colors.grey,
                radius: 3.h,
              ),
              onTap: () {
                Navigator.pop(context);
                Provider.of<TabProvider>(context, listen: false)
                    .changeTabPage(4);
              },
            ),
            decoration: BoxDecoration(
              color: Color(0xff233141),
            ),
          ),
          ListTile(
            leading: new Icon(Icons.settings, color: Colors.black),
            title: Text(
              'Settings',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 2.0,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: new Icon(Icons.info_outline_rounded, color: Colors.black),
            title: Text(
              'About Us',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 2.0,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsPage()),
              );
            },
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20.0),
            child: OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              onPressed: () async {
                await Provider.of<UserProvider>(context, listen: false)
                    .signOut(context);
              },
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.exit_to_app, color: Colors.black87),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SETTINGS'),
          centerTitle: true,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dark Theme'),
            Switch(
              onChanged: (value) {
                Provider.of<AppTheme>(context, listen: false).toggleTheme();
              },
              value: Provider.of<AppTheme>(context, listen: false).darkTheme,
            )
          ],
        ));
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('ABOUT US'),
          centerTitle: true,
        ),
        body: Text('About Us Page yote'));
  }
}
