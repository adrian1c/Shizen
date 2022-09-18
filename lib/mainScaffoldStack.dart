import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:double_back_to_close_app/double_back_to_close_app.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shizen_app/models/user.dart';
import 'package:shizen_app/modules/community/addnewpost.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/utils/notifications.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/field.dart';
import './modules/tasks/tasks.dart';
import './modules/friends/friends.dart';
import './modules/community/community.dart';
import './modules/progress/progress.dart';
import './modules/profile/profile.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

class MainScaffoldStack extends HookWidget {
  final List<GButton> screens = [
    GButton(
      icon: Icons.home,
      text: 'Routines',
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
      icon: Icons.person,
      text: 'Profile',
    ),
  ];

  final List<String> title = ['Routines', 'Friends', 'Community', 'Profile'];

  final qrKey = GlobalKey();

  showInvalidQRPopup(context) {
    Navigator.pop(context);
    StyledPopup(
        context: context,
        title: 'Invalid image',
        children: [Text('No/Invalid QR Code found.')]).showPopup();
    return;
  }

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: Theme.of(context).backgroundColor,
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
                  color: Theme.of(context).backgroundColor,
                  fontWeight: FontWeight.bold)),
          actions: Provider.of<TabProvider>(context, listen: false)
                      .selectedIndex ==
                  1
              ? [
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner_rounded),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Scan Profile Code"),
                              contentPadding: const EdgeInsets.all(0),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 50.h,
                                    child: MobileScanner(
                                        allowDuplicates: false,
                                        controller: MobileScannerController(
                                            facing: CameraFacing.back,
                                            torchEnabled: false),
                                        onDetect: (barcode, args) async {
                                          if (barcode.rawValue != null) {
                                            if (barcode.rawValue!
                                                .contains('/')) {
                                              showInvalidQRPopup(context);
                                              return;
                                            }

                                            var friend = await Database(uid)
                                                .getUserProfileData(
                                                    barcode.rawValue);
                                            if (friend.data() == null) {
                                              showInvalidQRPopup(context);
                                              return;
                                            }
                                            Navigator.pop(context);
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return Scaffold(
                                                  appBar: AppBar(
                                                    title: Text(friend
                                                                .data()!['name']
                                                                .length <
                                                            12
                                                        ? '${friend.data()!['name']}\'s Profile'
                                                        : 'Profile'),
                                                    centerTitle: true,
                                                  ),
                                                  body: ProfilePage(
                                                      viewId:
                                                          barcode.rawValue));
                                            }));
                                          }
                                        }),
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: TextButton(
                                        child: Text('Select From Gallery'),
                                        onPressed: () async {
                                          final picker = ImagePicker();
                                          final XFile? result =
                                              await picker.pickImage(
                                                  source: ImageSource.gallery);

                                          if (result == null) {
                                            Navigator.pop(context);
                                            return;
                                          }

                                          MobileScannerController
                                              cameraController =
                                              MobileScannerController();
                                          late StreamSubscription sub;
                                          sub = cameraController
                                              .barcodesController.stream
                                              .listen((barcode) async {
                                            if (barcode.rawValue != null) {
                                              if (barcode.rawValue!
                                                  .contains('/')) {
                                                showInvalidQRPopup(context);
                                                return;
                                              }
                                              var friend = await Database(uid)
                                                  .getUserProfileData(
                                                      barcode.rawValue);
                                              if (friend.data() == null) {
                                                showInvalidQRPopup(context);
                                                return;
                                              }
                                              Navigator.pop(context);
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return Scaffold(
                                                    appBar: AppBar(
                                                      title: Text(friend
                                                                  .data()![
                                                                      'name']
                                                                  .length <
                                                              12
                                                          ? '${friend.data()!['name']}\'s Profile'
                                                          : 'Profile'),
                                                      centerTitle: true,
                                                    ),
                                                    body: ProfilePage(
                                                        viewId:
                                                            barcode.rawValue));
                                              }));
                                            }

                                            sub.cancel();
                                          });

                                          await cameraController
                                              .analyzeImage(result.path)
                                              .then((value) {
                                            if (!value) {
                                              Navigator.pop(context);
                                              StyledPopup(
                                                  context: context,
                                                  title: 'Invalid image',
                                                  children: [
                                                    Text(
                                                        'No QR Code found from the image.')
                                                  ]).showPopup();
                                            }
                                          });
                                        },
                                      )),
                                ],
                              ),
                              alignment: Alignment.center,
                              actions: [
                                TextButton(
                                  child: Text("Ok"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    },
                  )
                ]
              : Provider.of<TabProvider>(context, listen: false)
                          .selectedIndex ==
                      2
                  ? [
                      TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddNewPost())),
                          child: Text('POST',
                              style: TextStyle(
                                  color: Theme.of(context).backgroundColor,
                                  fontWeight: FontWeight.bold)))
                    ]
                  : Provider.of<TabProvider>(context, listen: false)
                              .selectedIndex ==
                          3
                      ? [
                          IconButton(
                            icon: Icon(Icons.qr_code_2),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Profile"),
                                          IconButton(
                                              icon: Icon(Icons.share),
                                              onPressed: () async {
                                                try {
                                                  RenderRepaintBoundary
                                                      boundary = qrKey
                                                              .currentContext!
                                                              .findRenderObject()
                                                          as RenderRepaintBoundary;

                                                  var image =
                                                      await boundary.toImage();
                                                  ByteData? byteData =
                                                      await image.toByteData(
                                                          format:
                                                              ImageByteFormat
                                                                  .png);
                                                  Uint8List pngBytes = byteData!
                                                      .buffer
                                                      .asUint8List();
                                                  final appDir =
                                                      await getApplicationDocumentsDirectory();
                                                  var datetime = DateTime.now();
                                                  var file = await File(
                                                          '${appDir.path}/$datetime.png')
                                                      .create();
                                                  await file
                                                      .writeAsBytes(pngBytes);
                                                  await Share.shareFiles(
                                                      [file.path],
                                                      mimeTypes: ['image/png'],
                                                      text: 'My Profile');
                                                } catch (e) {
                                                  print(e.toString());
                                                }
                                              })
                                        ],
                                      ),
                                      content: RepaintBoundary(
                                          key: qrKey,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            color: Colors.white,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    '${Provider.of<UserProvider>(context).user.name}\'s Profile'),
                                                QrImage(
                                                  data: uid,
                                                  embeddedImage:
                                                      Images.bonsai.image,
                                                ),
                                              ],
                                            ),
                                          )),
                                      alignment: Alignment.center,
                                      actions: [
                                        TextButton(
                                          child: Text("Ok"),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                          )
                        ]
                      : null,
        ),
        drawer: NavDrawer(),
        floatingActionButton:
            Provider.of<TabProvider>(context, listen: false).selectedIndex == 0
                ? FABubble()
                : null,
        bottomNavigationBar: GNav(
            backgroundColor: CustomTheme.dividerBackground,
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 5,
            activeColor: Colors.white,
            iconSize: 20,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            tabMargin: EdgeInsets.all(10),
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
                KeepAlivePage(child: TaskPage()),
                KeepAlivePage(child: FriendsPage()),
                KeepAlivePage(child: CommunityPage()),
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
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddToDoTask()));
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
                    .changeTabPage(3);
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
            leading: new Icon(Icons.notifications_active_rounded,
                color: Colors.black),
            title: Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 2.0,
              ),
            ),
            onTap: () async {
              var notifications =
                  await NotificationService().getPendingNotifications();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationsPage(notifications)),
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
    String uid = Provider.of<UserProvider>(context).user.uid;
    return Scaffold(
        appBar: AppBar(
          title: Text('SETTINGS'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Private Account'),
                  Switch(
                    onChanged: (value) async {
                      await LoaderWithToast(
                              context: context,
                              api: Database(uid).togglePrivateAccount(value),
                              msg: 'Your account privacy has been changed',
                              isSuccess: true)
                          .show();
                      Provider.of<UserProvider>(context, listen: false)
                          .togglePrivate(value);
                    },
                    value: Provider.of<UserProvider>(context).user.private,
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Dark Theme'),
                  Switch(
                    onChanged: (value) async {
                      // await Provider.of<AppTheme>(context, listen: false)
                      //     .toggleTheme();
                      StyledPopup(
                              context: context,
                              title: 'Coming Soon',
                              children: [
                                Text(
                                    'This feature is still in development. Please bear with us :)')
                              ],
                              cancelText: 'OK')
                          .showPopup();
                    },
                    value:
                        Provider.of<AppTheme>(context, listen: false).darkTheme,
                  )
                ],
              ),
            ),
          ],
        ));
  }
}

class NotificationsPage extends HookWidget {
  const NotificationsPage(this.notifications, {Key? key}) : super(key: key);

  final List<PendingNotificationRequest> notifications;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final notificationList = useState(notifications);
    return Scaffold(
        appBar: AppBar(
          title: Text('Active Notifications'),
          centerTitle: true,
        ),
        body: notificationList.value.length > 0
            ? Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                    itemCount: notificationList.value.length,
                    itemBuilder: (context, index) {
                      var notif = notificationList.value[index];
                      var info = notif.payload?.split(',');
                      return ListTile(
                        leading: Icon(info![0] == 'todo'
                            ? Icons.task_alt
                            : Icons.track_changes),
                        title: Text(notif.title ?? 'No title'),
                        subtitle: Text(notif.body ?? 'No body'),
                        trailing: IconButton(
                          icon: Icon(Icons.cancel_rounded),
                          onPressed: () async {
                            StyledPopup(
                              context: context,
                              children: [
                                Text(
                                    'Do you want to delete this notification?'),
                              ],
                              title: 'Confirm Delete',
                              textButton: TextButton(
                                  child: Text('Delete',
                                      style: TextStyle(color: Colors.red[400])),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await LoaderWithToast(
                                            api: Database(uid)
                                                .cancelActiveNotification(
                                                    info[0], info[1])
                                                .then((value) =>
                                                    NotificationService()
                                                        .cancelNotification(
                                                            notif.id)
                                                        .then((value) {
                                                      notificationList.value =
                                                          List.from(
                                                              notificationList
                                                                  .value)
                                                            ..removeAt(index);
                                                      Provider.of<TabProvider>(
                                                              context,
                                                              listen: false)
                                                          .rebuildPage(
                                                              info[0] == 'todo'
                                                                  ? 'todo'
                                                                  : 'tracker');
                                                    })),
                                            context: context,
                                            isSuccess: true,
                                            msg: 'Notification cancelled')
                                        .show();
                                  }),
                            ).showPopup();
                          },
                        ),
                        horizontalTitleGap: 0,
                      );
                    }),
              )
            : Center(child: Text('There are no active notifications')));
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
//                     if (_formKey.currentState!.validate()) {
//                       final bodyText =
//                           '''Hello, I am ${Provider.of<UserProvider>(context, listen: false).user.name}.
// This is my feedback:

// ${feedbackController.text}''';
//                       final Email email = Email(
//                         body: bodyText,
//                         subject: 'Feedback for Shizen',
//                         recipients: ['adrianching1@gmail.com'],
//                         cc: [],
//                         bcc: [],
//                         isHTML: false,
//                       );
//                       await LoaderWithToast(
//                               context: context,
//                               api: FlutterEmailSender.send(email),
//                               msg: 'Success',
//                               isSuccess: true)
//                           .show();
//                       feedbackController.clear();
//                     }
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
