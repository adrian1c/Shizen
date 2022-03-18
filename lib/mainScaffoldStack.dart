import 'package:provider/provider.dart';
import 'package:shizen_app/modules/community/addnewpost.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
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
        drawer: NavDrawer(),
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
              KeepAlivePage(child: TaskPage()),
              KeepAlivePage(child: FriendsPage()),
              KeepAlivePage(child: CommunityPage()),
              KeepAlivePage(child: ProgressPage()),
              KeepAlivePage(child: ProfilePage()),
            ]));
  }
}

class NavDrawer extends HookWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).uid;
    final future = useMemoized(() => Database(uid).getCurrentUserData(), []);
    final snapshot = useFuture(future);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountEmail: !snapshot.hasData
                ? CircularProgressIndicator()
                : Text(snapshot.data!['email'],
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 10)),
            accountName: !snapshot.hasData
                ? CircularProgressIndicator()
                : Text(snapshot.data!['name'],
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 20)),
            decoration: BoxDecoration(
              color: Color(0xff233141),
            ),
          ),
          ListTile(
            leading: new IconButton(
              icon: new Icon(Icons.face, color: Colors.black),
              onPressed: () => null,
            ),
            title: Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 2.0,
              ),
            ),
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //       builder: (context) => ProfilePage(uid: widget.uid)),
              // );
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
