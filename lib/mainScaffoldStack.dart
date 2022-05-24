import 'package:cached_network_image/cached_network_image.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shizen_app/models/user.dart';
import 'package:shizen_app/modules/community/addnewpost.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/addtracker.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/utils/notifications.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/widgets/onboarding.dart';
import './modules/tasks/tasks.dart';
import './modules/friends/friends.dart';
import './modules/community/community.dart';
import './modules/progress/progress.dart';
import './modules/profile/profile.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

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
      icon: Icons.handshake,
      text: 'Community',
    ),
    GButton(
      icon: Icons.insert_chart_rounded,
      text: 'Progress',
    ),
    GButton(
      icon: Icons.person,
      text: 'Profile',
    ),
  ];

  final List<String> title = [
    'Home',
    'Friends',
    'Community',
    'Progress',
    'Profile'
  ];

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isSwitching = useState(true);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
          centerTitle: true,
          title: Text(
              title[Provider.of<TabProvider>(context, listen: false)
                  .selectedIndex],
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold)),
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
                                  color: Theme.of(context).primaryColor,
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
            backgroundColor: Colors.transparent,
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 5,
            activeColor: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            tabMargin: EdgeInsets.fromLTRB(5, 10, 5, 10),
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Color(0xff444444),
            color: Color(0xff444444),
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

class FABubble extends StatelessWidget {
  const FABubble({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Create a Task'),
                  Divider(
                    thickness: 1,
                  ),
                ],
              ),
              contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddToDoTask()));
                    },
                    child: DemoToDoTask(),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 5.0)),
                  TextDivider('OR'),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 5.0)),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddTrackerTask()));
                    },
                    child: DemoTrackerTask(),
                  )
                ],
              )),
        );
      },
      child: Icon(
        Icons.add_rounded,
      ),
    );
  }
}

class DemoToDoTask extends StatelessWidget {
  const DemoToDoTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  constraints: BoxConstraints(minWidth: 25.w),
                  height: 5.h,
                  decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withAlpha(200),
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15))),
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Text('Task',
                        style: Theme.of(context).textTheme.headline4),
                  ))),
            ],
          ),
          ConstrainedBox(
              constraints: BoxConstraints(minHeight: 5.h, minWidth: 100.w),
              child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withAlpha(200),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: CustomTheme.boxShadow,
                  ),
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          height: 5.h,
                          child: Container(
                            decoration: BoxDecoration(
                                color: index == 2
                                    ? CustomTheme.completeColor
                                    : Theme.of(context).backgroundColor,
                                borderRadius: index == 0
                                    ? BorderRadius.only(
                                        topLeft: Radius.circular(15),
                                        topRight: Radius.circular(15),
                                        bottomLeft: Radius.zero,
                                        bottomRight: Radius.zero,
                                      )
                                    : index == 2
                                        ? BorderRadius.only(
                                            bottomLeft: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          )
                                        : null),
                            child: Row(
                              children: [
                                AbsorbPointer(
                                  child: Checkbox(
                                    shape: CircleBorder(),
                                    activeColor:
                                        Theme.of(context).backgroundColor,
                                    checkColor: Colors.lightGreen[700],
                                    value: index == 2 ? true : false,
                                    onChanged: (value) async {},
                                  ),
                                ),
                                Text('To Do Task $index',
                                    softWrap: false,
                                    style: TextStyle(
                                        decoration: index == 2
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

class DemoTrackerTask extends StatelessWidget {
  const DemoTrackerTask({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 10,
            child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Theme.of(context).backgroundColor,
                    boxShadow: CustomTheme.boxShadow),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Daily Tracker',
                            style: Theme.of(context)
                                .textTheme
                                .headline4
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withAlpha(200))),
                        Row(
                          children: [
                            Text('90',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Icon(Icons.park_rounded,
                                color: Color.fromARGB(255, 147, 182, 117))
                          ],
                        )
                      ],
                    ),
                    Divider(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Next Milestone',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('-'),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromARGB(255, 252, 212, 93)),
                            child: Icon(
                              Icons.flag_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Center(
                        child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: CustomTheme.completeColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              color: Theme.of(context).backgroundColor),
                          Text('Checked-in Today',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    )),
                  ],
                )),
          ),
        ],
      ),
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
              'About Shizen',
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
              onChanged: (value) async {
                await Provider.of<AppTheme>(context, listen: false)
                    .toggleTheme();
              },
              value: Provider.of<AppTheme>(context, listen: false).darkTheme,
            )
          ],
        ));
  }
}

class AboutUsPage extends HookWidget {
  AboutUsPage({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final feedbackController = useTextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text('ABOUT US'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Significance')),
                ),
                Divider(),
                Text('''
Defined as nature, natural, spontaneous. This seemingly minimalistic word is integrated as a part of Japanese culture with the influence of Zen Buddhism. The concept of this word symbolizes the idea of human beings intertwined with nature, or the environment around them. The Japanese accept that shizen allows for the interpretation of the human touch with their surroundings, to produce something that is a fusion between human and nature. This is a stark contrast to the Western ideologies of nature, where something is only considered natural when it is pure and untouched by man.

By applying the concept of shizen to human behaviour, the intention is not to replicate nature. It is to eventually become one with nature. The beauty of shizen in human behaviour is appreciated when someone does or performs an action that seems to come with no conscious effort. Their actions have been internalized to be seen as something naturally occurring. It is a sight to behold and is held to a high regard because it takes tremendous amounts of effort and practice, repetition after repetition, before eventually achieving this state.

When incorporating a new habit, or starting our journey on self-improvement, it will feel unnatural and forced. The results will not be pleasant. However, by taking it one step at a time on the inclined hill, going through repetitive motion day after day, eventually you look back and realize that you have arrived at a place where you never imagined possible on the first day of the journey. The best part? Your body and mind have acclimated to said actions. Therefore, the rest of the journey to the peak of the hill will feel natural, or rather, shizen.''',
                    textAlign: TextAlign.justify),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Align(
                      alignment: Alignment.centerLeft, child: Text('Purpose')),
                ),
                Divider(),
                Text(
                    '''Shizen is developed initially as a Final Year Project. It aims to provide a platform for personal productivity where like-minded individuals from all walks of life can gather to discuss and share about their stories.''',
                    textAlign: TextAlign.justify),
                Divider(),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text('We\'d love to hear feedback from you!'),
                ),
                Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                        //   child: TextFormField(
                        //     controller: nameController,
                        //     textCapitalization: TextCapitalization.words,
                        //     decoration: InputDecoration(
                        //       filled: true,
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(5)),
                        //       floatingLabelBehavior:
                        //           FloatingLabelBehavior.always,
                        //       labelText: 'Name',
                        //       hintText: 'Enter your name',
                        //       prefixIcon: Icon(Icons.person),
                        //     ),
                        //     validator: (String? value) {
                        //       String valueString = value as String;
                        //       if (valueString.isEmpty) {
                        //         return "You have not filled anything in";
                        //       } else {
                        //         return null;
                        //       }
                        //     },
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 10.0),
                        //   child: TextFormField(
                        //     controller: emailController,
                        //     keyboardType: TextInputType.emailAddress,
                        //     decoration: InputDecoration(
                        //       filled: true,
                        //       border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(5)),
                        //       floatingLabelBehavior:
                        //           FloatingLabelBehavior.always,
                        //       labelText: 'Email',
                        //       hintText: 'Email that you want us to respond to',
                        //       prefixIcon: Icon(Icons.email),
                        //     ),
                        //     validator: (String? value) {
                        //       String valueString = value as String;
                        //       if (valueString.isEmpty) {
                        //         return "Enter an Email Address";
                        //       } else if (!valueString.contains('@')) {
                        //         return "Please enter a valid email address";
                        //       }
                        //       return null;
                        //     },
                        //   ),
                        // ),
                        TextFormField(
                          controller: feedbackController,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 10,
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5)),
                            floatingLabelBehavior: FloatingLabelBehavior.never,
                            hintText: 'Share your thoughts with us!',
                          ),
                          validator: (String? value) {
                            String valueString = value as String;
                            if (valueString.isEmpty) {
                              return "You have not filled anything in";
                            } else {
                              return null;
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue[400],
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    minimumSize:
                        Size((MediaQuery.of(context).size.width * 0.25), 45),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final bodyText =
                          '''Hello, I am ${Provider.of<UserProvider>(context, listen: false).user.name}. 
This is my feedback:

${feedbackController.text}''';
                      final Email email = Email(
                        body: bodyText,
                        subject: 'Feedback for Shizen',
                        recipients: ['adrianching1@gmail.com'],
                        cc: [],
                        bcc: [],
                        isHTML: false,
                      );
                      await LoaderWithToast(
                              context: context,
                              api: FlutterEmailSender.send(email),
                              msg: 'Success',
                              isSuccess: true)
                          .show();
                      feedbackController.clear();
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.send),
                      ),
                      Text("Send Feedback",
                          style: Theme.of(context).textTheme.bodyText1),
                    ],
                  ),
                ),
                Padding(padding: const EdgeInsets.only(bottom: 30.0))
              ],
            ),
          ),
        ));
  }
}
