import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class InstantMessagingPage extends HookWidget {
  const InstantMessagingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final stream = useMemoized(() => Database(uid).getChats(), []);
    final chatStream = useStream(stream);
    return Scaffold(
        appBar: AppBar(
          title: Text('CHATS'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.accessibility_new_sharp),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FriendMessageListPage()));
              },
            ),
          ],
        ),
        body: Column(
          children: [
            chatStream.hasData
                ? chatStream.data.docs.length > 0
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: chatStream.data.docs.length,
                        itemBuilder: (context, index) {
                          final friend = chatStream.data.docs[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Column(
                              children: [
                                Divider(),
                                ListTile(
                                  onTap: () async {
                                    Database(uid)
                                        .chattingWith(friend['peerId']);
                                    if (friend['unreadCount'] > 0) {
                                      Database(uid)
                                          .resetUnread(friend['peerId']);
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ChatPage(
                                                peerId: friend['peerId'],
                                                peerName: friend['user']
                                                    ['name'])));
                                  },
                                  leading: Padding(
                                    padding: const EdgeInsets.only(right: 10.0),
                                    child: CircleAvatar(
                                      foregroundImage:
                                          CachedNetworkImageProvider(
                                              friend['user']['image']),
                                      backgroundColor: Colors.grey,
                                      radius: 3.h,
                                    ),
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${friend['user']['name']}",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.sp),
                                      ),
                                      Text(
                                        DateFormat("hh:mm a")
                                            .format((friend['lastMsgTime']
                                                    as Timestamp)
                                                .toDate())
                                            .toString(),
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    "${friend['lastMsg']}",
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 13.sp),
                                  ),
                                  trailing: friend['unreadCount'] > 0
                                      ? Container(
                                          alignment: Alignment.center,
                                          width: 7.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blueGrey[
                                                800], // inner circle color
                                          ),
                                          child: Text(
                                              friend['unreadCount'].toString(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1), // inner content
                                        )
                                      : null,
                                  horizontalTitleGap: 0,
                                  tileColor: Colors.transparent,
                                ),
                              ],
                            ),
                          );
                        })
                    : Text('No Chats')
                : Text('Invalid')
          ],
        ));
  }
}

class FriendMessageListPage extends HookWidget {
  const FriendMessageListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(() => Database(uid).friendsPageData(), []);
    final snapshot = useFuture(future);
    if (snapshot.hasData) {
      final friendsList = snapshot.data!['friendsList'];
      print(friendsList);
      return Scaffold(
          appBar: AppBar(
            title: Text('NEW CHAT'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: friendsList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(15),
                      child: ListTile(
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatPage(
                                      peerId: friendsList[index].id,
                                      peerName: friendsList[index]['name'])));
                        },
                        leading: Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: CircleAvatar(
                            foregroundImage: CachedNetworkImageProvider(
                                friendsList[index]['image']),
                            backgroundColor: Colors.grey,
                            radius: 3.h,
                          ),
                        ),
                        title: Text(
                          "${friendsList[index]["name"]}",
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.white, fontSize: 20.sp),
                        ),
                        subtitle: Text(
                          "${friendsList[index]["email"]}",
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: Colors.white, fontSize: 13.sp),
                        ),
                        horizontalTitleGap: 0,
                        tileColor: Colors.blueGrey[600],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  })));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('NEW CHAT'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Text('Invalid'),
          ],
        ));
  }
}

class ChatPage extends HookWidget {
  const ChatPage({Key? key, required this.peerId, required this.peerName})
      : super(key: key);

  final peerId;
  final peerName;
  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final chatId =
        (uid.hashCode <= peerId.hashCode) ? '$uid-$peerId' : '$peerId-$uid';
    final stream = useMemoized(() => Database(uid).getMessages(chatId), []);
    final messageStream = useStream(stream);
    final msgController = useTextEditingController();

    useEffect(() {
      final observer = MyObserver(
          detachedCallBack: () async => await Database(uid).chattingWith(null),
          resumeCallBack: () async => await Database(uid).chattingWith(peerId));
      WidgetsBinding.instance!.addObserver(observer);
      return () => WidgetsBinding.instance!.removeObserver(observer);
    }, const []);
    if (messageStream.hasData) {
      var msgList = messageStream.data;
      var mustInitializeDoc = false;
      if (msgList.docs.length == 0) {
        mustInitializeDoc = true;
      }
      return Scaffold(
          appBar: AppBar(
            title: Text(peerName),
            centerTitle: true,
          ),
          body: WillPopScope(
            onWillPop: () {
              Database(uid).chattingWith(null);
              Navigator.pop(context);
              return Future.value(false);
            },
            child: Column(mainAxisSize: MainAxisSize.max, children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: msgList.docs.length,
                        itemBuilder: (context, index) {
                          var msg = msgList.docs[index];
                          if (msg['idFrom'] == uid) {
                            return Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Text(
                                        DateFormat("hh:mm a")
                                            .format((msg['dateCreated']
                                                    as Timestamp)
                                                .toDate())
                                            .toString(),
                                        style: TextStyle(fontSize: 12.sp)),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(10),
                                      constraints:
                                          BoxConstraints(maxWidth: 70.w),
                                      decoration: BoxDecoration(
                                          color: Colors.blue[200],
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15),
                                              bottomLeft: Radius.circular(15))),
                                      child: Text(msg['message'],
                                          style:
                                              TextStyle(color: Colors.white))),
                                ],
                              ),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    constraints: BoxConstraints(maxWidth: 75.w),
                                    decoration: BoxDecoration(
                                        color: Colors.blueGrey[700],
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15))),
                                    child: Text(msg['message'],
                                        style: TextStyle(color: Colors.white))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Text(
                                      DateFormat("hh:mm a")
                                          .format(
                                              (msg['dateCreated'] as Timestamp)
                                                  .toDate())
                                          .toString(),
                                      style: TextStyle(fontSize: 12.sp)),
                                ),
                              ],
                            ),
                          );
                        })),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 10.h,
                  width: 100.w,
                  color: Colors.grey[200],
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            controller: msgController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Message',
                              suffixIcon: IconButton(
                                onPressed: () async {
                                  if (msgController.text.length != 0) {
                                    final msg = msgController.text;
                                    msgController.clear();
                                    if (mustInitializeDoc) {
                                      await Database(uid)
                                          .newChat(chatId, peerId)
                                          .then((value) =>
                                              mustInitializeDoc = false);
                                    }
                                    await Database(uid)
                                        .sendMessage(chatId, msg, uid, peerId);
                                  }
                                },
                                icon: Icon(Icons.send),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text(peerId),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Text('Invalid'),
          ],
        ));
  }
}

class MyObserver implements WidgetsBindingObserver {
  MyObserver({required this.detachedCallBack, required this.resumeCallBack});

  final resumeCallBack;
  final detachedCallBack;

  @override
  void didChangeAccessibilityFeatures() {
    // TODO: implement didChangeAccessibilityFeatures
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await detachedCallBack();
        break;
      case AppLifecycleState.resumed:
        await resumeCallBack();
        break;
    }
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    // TODO: implement didChangeLocales
  }

  @override
  void didChangeMetrics() {
    // TODO: implement didChangeMetrics
  }

  @override
  void didChangePlatformBrightness() {
    // TODO: implement didChangePlatformBrightness
  }

  @override
  void didChangeTextScaleFactor() {
    // TODO: implement didChangeTextScaleFactor
  }

  @override
  void didHaveMemoryPressure() {
    // TODO: implement didHaveMemoryPressure
  }

  @override
  Future<bool> didPopRoute() {
    // TODO: implement didPopRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRoute(String route) {
    // TODO: implement didPushRoute
    throw UnimplementedError();
  }

  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    // TODO: implement didPushRouteInformation
    throw UnimplementedError();
  }
}
