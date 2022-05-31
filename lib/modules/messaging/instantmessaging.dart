import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shizen_app/modules/community/addnewpost.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:shizen_app/widgets/todotile.dart';

class InstantMessagingPage extends HookWidget {
  const InstantMessagingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final stream = useMemoized(() => Database(uid).getChats(), []);
    final chatStream = useStream(stream);
    return Scaffold(
        appBar: AppBar(
          title: Text('Chats'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.chat_rounded),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FriendMessageListPage()));
              },
            ),
          ],
        ),
        body: chatStream.hasData
            ? chatStream.data.docs.length > 0
                ? Column(
                    children: [
                      ListView.builder(
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
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: CircleAvatar(
                                        foregroundImage:
                                            friend['user']['image'] != ''
                                                ? CachedNetworkImageProvider(
                                                    friend['user']['image'])
                                                : Images.defaultPic.image,
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
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            child: Text(
                                                friend['unreadCount']
                                                    .toString(),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1),
                                          )
                                        : null,
                                    horizontalTitleGap: 0,
                                    tileColor: Colors.transparent,
                                  ),
                                ],
                              ),
                            );
                          }),
                    ],
                  )
                : Center(
                    child: Text(
                    'No Chats.\n\nYou can start a new chat in the top-right corner!',
                    textAlign: TextAlign.center,
                  ))
            : Center(
                child: SpinKitWanderingCubes(
                    color: Theme.of(context).primaryColor, size: 75),
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
            title: Text('New Chat'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
              child: friendsList.length > 0
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: friendsList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(15),
                          child: ListTile(
                            onTap: () {
                              print(friendsList[index].id);
                              print(friendsList[index]['name']);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                          peerId: friendsList[index].id,
                                          peerName: friendsList[index]
                                              ['name'])));
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
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.sp),
                            ),
                            subtitle: Text(
                              "${friendsList[index]["email"]}",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white, fontSize: 13.sp),
                            ),
                            horizontalTitleGap: 0,
                            tileColor: Theme.of(context).primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      })
                  : Center(
                      child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Text('Please add some friends first.'),
                    ))));
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('New Chat'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitWanderingCubes(
                color: Theme.of(context).primaryColor, size: 75),
          ],
        ));
  }
}

class ChatPage extends HookWidget {
  ChatPage({Key? key, required this.peerId, required this.peerName})
      : super(key: key);

  final peerId;
  final peerName;

  Future loadMoreMsgs(
      uid, chatId, currentMsgList, lastMsgDoc, hasMoreData) async {
    var newBatchOfMsgs =
        await Database(uid).loadMoreMsgs(chatId, lastMsgDoc.value);
    var tempMsgList = [];
    if (newBatchOfMsgs.docs.length != 0) {
      tempMsgList = List<Map>.from(
          newBatchOfMsgs.docs.map((doc) => Map.from(doc.data())));
      currentMsgList.value.addAll(tempMsgList);
      lastMsgDoc.value = newBatchOfMsgs.docs.last;
    }

    if (newBatchOfMsgs.docs.length < 15) {
      hasMoreData.value = false;
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<List<Map<dynamic, dynamic>>> msgs = useState([]);
    final ValueNotifier<DocumentSnapshot?> lastMsg = useState(null);
    final initialLoad = useState(false);
    final loadMore = useState(true);
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final chatId =
        (uid.hashCode <= peerId.hashCode) ? '$uid-$peerId' : '$peerId-$uid';
    final stream = useMemoized(() => Database(uid).getMessages(chatId), []);
    final messageStream = useStream(stream);
    final msgController = useTextEditingController();
    final scrollController = useScrollController();
    final focusNode = useFocusNode();
    final focusValue = useState(false);
    final ValueNotifier<Map?> attachment = useState(null);

    useEffect(() {
      final observer = MyObserver(
          detachedCallBack: () async => await Database(uid).chattingWith(null),
          resumeCallBack: () async => await Database(uid).chattingWith(peerId));
      WidgetsBinding.instance!.addObserver(observer);

      scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (loadMore.value) {
            loadMoreMsgs(uid, chatId, msgs, lastMsg, loadMore);
          }
        }
      });

      final sub = stream.listen(
        (event) {
          if (event.docs.length > 0) {
            msgs.value.add(event.docs[0].data());
          }
        },
      );

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          focusValue.value = true;
        } else {
          focusValue.value = false;
        }
      });
      return () {
        WidgetsBinding.instance!.removeObserver(observer);
        sub.cancel();
      };
    }, []);

    if (messageStream.hasData) {
      var msgList = messageStream.data;
      if (!initialLoad.value) {
        if (msgList.docs.length > 0) {
          msgs.value =
              List<Map>.from(msgList.docs.map((doc) => Map.from(doc.data())));
          lastMsg.value = msgList.docs.last;
        }
        initialLoad.value = true;
      }

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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: GroupedListView(
                      shrinkWrap: true,
                      controller: scrollController,
                      elements: msgs.value,
                      groupBy: (Map element) => DateTime(
                          (element['dateCreated'] as Timestamp).toDate().year,
                          (element['dateCreated'] as Timestamp).toDate().month,
                          (element['dateCreated'] as Timestamp).toDate().day),
                      groupHeaderBuilder: (Map element) {
                        var formattedDate = '';
                        final elementDate =
                            (element['dateCreated'] as Timestamp).toDate();
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final yesterday =
                            DateTime(now.year, now.month, now.day - 1);
                        final elementDay = DateTime(elementDate.year,
                            elementDate.month, elementDate.day);
                        if (today == elementDay) {
                          formattedDate = 'Today';
                        } else if (yesterday == elementDay) {
                          formattedDate = 'Yesterday';
                        } else {
                          formattedDate =
                              DateFormat("dd MMM yyyy").format(elementDate);
                        }
                        return Container(
                          height: 5.h,
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color.fromARGB(170, 114, 133, 143),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '$formattedDate',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      itemComparator: (Map item1, Map item2) =>
                          (item1['dateCreated'] as Timestamp)
                              .toDate()
                              .compareTo(
                                  (item2['dateCreated'] as Timestamp).toDate()),
                      indexedItemBuilder: (context, Map element, index) {
                        if (element['idFrom'] == uid) {
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
                                          .format((element['dateCreated']
                                                  as Timestamp)
                                              .toDate())
                                          .toString(),
                                      style: TextStyle(fontSize: 10.sp)),
                                ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: CustomTheme.sentMsg,
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomLeft: Radius.circular(15)),
                                        boxShadow: CustomTheme.boxShadow),
                                    child: element.containsKey('attachment')
                                        ? element['attachment'] != null
                                            ? element['attachment'].containsKey(
                                                    'attachmentType')
                                                ? element['attachment'][
                                                            'attachmentType'] ==
                                                        'task'
                                                    ? Column(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                element[
                                                                    'message'],
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                          Divider(
                                                            color: Theme.of(
                                                                    context)
                                                                .backgroundColor,
                                                          ),
                                                          Transform.scale(
                                                            scale: 0.85,
                                                            child: ToDoTileDisplay(
                                                                data: element[
                                                                    'attachment']),
                                                          )
                                                        ],
                                                      )
                                                    : Column(
                                                        children: [
                                                          Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                                element[
                                                                    'message'],
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white)),
                                                          ),
                                                          Divider(
                                                            color: Theme.of(
                                                                    context)
                                                                .backgroundColor,
                                                          ),
                                                          Transform.scale(
                                                            scale: 0.85,
                                                            child: TrackerTileDisplay(
                                                                data: element[
                                                                    'attachment']),
                                                          )
                                                        ],
                                                      )
                                                : Text(
                                                    element['message'],
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  )
                                            : Text(
                                                element['message'],
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                        : Text(
                                            element['message'],
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                  ),
                                ),
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
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: CustomTheme.receivedMsg,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15),
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15)),
                                      boxShadow: CustomTheme.boxShadow),
                                  child: element.containsKey('attachment')
                                      ? element['attachment'] != null
                                          ? element['attachment']
                                                  .containsKey('attachmentType')
                                              ? element['attachment']
                                                          ['attachmentType'] ==
                                                      'task'
                                                  ? Column(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                              element[
                                                                  'message'],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                        Divider(
                                                          color: Theme.of(
                                                                  context)
                                                              .backgroundColor,
                                                        ),
                                                        Transform.scale(
                                                          scale: 0.85,
                                                          child: ToDoTileDisplay(
                                                              data: element[
                                                                  'attachment']),
                                                        )
                                                      ],
                                                    )
                                                  : Column(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          child: Text(
                                                              element[
                                                                  'message'],
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                        Divider(
                                                          color: Theme.of(
                                                                  context)
                                                              .backgroundColor,
                                                        ),
                                                        Transform.scale(
                                                          scale: 0.85,
                                                          child: TrackerTileDisplay(
                                                              data: element[
                                                                  'attachment']),
                                                        )
                                                      ],
                                                    )
                                              : Text(
                                                  element['message'],
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                          : Text(
                                              element['message'],
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )
                                      : Text(
                                          element['message'],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Text(
                                    DateFormat("hh:mm a")
                                        .format((element['dateCreated']
                                                as Timestamp)
                                            .toDate())
                                        .toString(),
                                    style: TextStyle(fontSize: 10.sp)),
                              ),
                            ],
                          ),
                        );
                      },
                      reverse: true,
                      useStickyGroupSeparators: true,
                      floatingHeader: true,
                      order: GroupedListOrder.DESC,
                    )),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  children: attachment.value != null
                      ? [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: Color.fromARGB(100, 85, 85, 85),
                                    borderRadius: BorderRadius.circular(15)),
                                child: Stack(children: [
                                  Align(
                                      alignment: Alignment.topCenter,
                                      child: Column(
                                        children: [
                                          Text('Attachment'),
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Transform.scale(
                                              scale: 0.9,
                                              child: attachment.value![
                                                          'attachmentType'] ==
                                                      'task'
                                                  ? ToDoTileDisplay(
                                                      data: attachment.value)
                                                  : TrackerTileDisplay(
                                                      data: attachment.value),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                        onPressed: () {
                                          attachment.value = null;
                                        },
                                        icon: Icon(Icons.cancel_rounded,
                                            color: Color.fromARGB(
                                                170, 85, 85, 85))),
                                  ),
                                ])),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              enableInteractiveSelection: true,
                              focusNode: focusNode,
                              showCursor: true,
                              controller: msgController,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .backgroundColor
                                      .withAlpha(230)),
                              decoration: InputDecoration(
                                fillColor: CustomTheme.msgBox,
                                filled: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 5, 10, 5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        style: BorderStyle.none, width: 0)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 2.0),
                                ),
                                hintText: focusValue.value ? '' : 'Message',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .backgroundColor
                                        .withAlpha(100)),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.attach_file_rounded,
                                            color: focusValue.value
                                                ? CustomTheme.msgIcon
                                                : CustomTheme.msgIcon
                                                    .withAlpha(100)),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Attachment'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                          child: Text(
                                                              'To Do Task'),
                                                          onTap: () async {
                                                            Navigator.pop(
                                                                context);
                                                            var returnValue =
                                                                await Navigator
                                                                    .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              SelectTaskPage(),
                                                                        ));
                                                            if (returnValue !=
                                                                null) {
                                                              returnValue[
                                                                      'attachmentType'] =
                                                                  'task';
                                                              if (returnValue[
                                                                      'timeCompleted'] !=
                                                                  null) {
                                                                print(returnValue[
                                                                    'timeCompleted']);
                                                                var time = DateFormat(
                                                                        "d MMM @ h:mm a")
                                                                    .format(returnValue[
                                                                        'timeCompleted']);
                                                                returnValue[
                                                                        'timeCompleted'] =
                                                                    time;
                                                              }
                                                              attachment.value =
                                                                  returnValue;
                                                            }
                                                          }),
                                                      InkWell(
                                                          child: Text(
                                                              'Daily Tracker'),
                                                          onTap: () async {
                                                            Navigator.pop(
                                                                context);
                                                            var returnValue =
                                                                await Navigator
                                                                    .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              SelectTrackerPage(),
                                                                        ));
                                                            if (returnValue !=
                                                                null) {
                                                              returnValue[
                                                                      'attachmentType'] =
                                                                  'tracker';
                                                              attachment.value =
                                                                  returnValue;
                                                            }
                                                          })
                                                    ],
                                                  ),
                                                );
                                              });
                                        }),
                                    IconButton(
                                      onPressed: () async {
                                        if (msgController.text.length != 0 ||
                                            attachment.value != null) {
                                          final msg = msgController.text;
                                          if (mustInitializeDoc) {
                                            await Database(uid)
                                                .newChat(chatId, peerId)
                                                .then((value) =>
                                                    mustInitializeDoc = false);
                                          }
                                          await Database(uid).sendMessage(
                                              chatId,
                                              msg,
                                              uid,
                                              peerId,
                                              attachment.value);
                                          attachment.value = null;
                                          msgController.clear();
                                        }
                                      },
                                      icon: Icon(Icons.send,
                                          color: focusValue.value
                                              ? CustomTheme.msgIcon
                                              : CustomTheme.msgIcon
                                                  .withAlpha(100)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]
                      : [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              enableInteractiveSelection: true,
                              focusNode: focusNode,
                              showCursor: true,
                              controller: msgController,
                              textCapitalization: TextCapitalization.sentences,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .backgroundColor
                                      .withAlpha(230)),
                              decoration: InputDecoration(
                                fillColor: CustomTheme.msgBox,
                                filled: true,
                                contentPadding:
                                    const EdgeInsets.fromLTRB(15, 5, 10, 5),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: BorderSide(
                                        style: BorderStyle.none, width: 0)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 2.0),
                                ),
                                hintText: focusValue.value ? '' : 'Message',
                                hintStyle: TextStyle(
                                    color: Theme.of(context)
                                        .backgroundColor
                                        .withAlpha(100)),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                        icon: Icon(Icons.attach_file_rounded,
                                            color: focusValue.value
                                                ? CustomTheme.msgIcon
                                                : CustomTheme.msgIcon
                                                    .withAlpha(100)),
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: Text('Attachment'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      InkWell(
                                                          child: Text(
                                                              'To Do Task'),
                                                          onTap: () async {
                                                            Navigator.pop(
                                                                context);
                                                            var returnValue =
                                                                await Navigator
                                                                    .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              SelectTaskPage(),
                                                                        ));
                                                            if (returnValue !=
                                                                null) {
                                                              returnValue[
                                                                      'attachmentType'] =
                                                                  'task';
                                                              if (returnValue[
                                                                      'timeCompleted'] !=
                                                                  null) {
                                                                print(returnValue[
                                                                    'timeCompleted']);
                                                                var time = DateFormat(
                                                                        "d MMM @ h:mm a")
                                                                    .format(returnValue[
                                                                        'timeCompleted']);
                                                                returnValue[
                                                                        'timeCompleted'] =
                                                                    time;
                                                              }
                                                              attachment.value =
                                                                  returnValue;
                                                            }
                                                          }),
                                                      InkWell(
                                                          child: Text(
                                                              'Daily Tracker'),
                                                          onTap: () async {
                                                            Navigator.pop(
                                                                context);
                                                            var returnValue =
                                                                await Navigator
                                                                    .push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              SelectTrackerPage(),
                                                                        ));
                                                            if (returnValue !=
                                                                null) {
                                                              returnValue[
                                                                      'attachmentType'] =
                                                                  'tracker';
                                                              attachment.value =
                                                                  returnValue;
                                                            }
                                                          })
                                                    ],
                                                  ),
                                                );
                                              });
                                        }),
                                    IconButton(
                                      onPressed: () async {
                                        if (msgController.text.length != 0 ||
                                            attachment.value != null) {
                                          final msg = msgController.text;

                                          if (mustInitializeDoc) {
                                            await Database(uid)
                                                .newChat(chatId, peerId)
                                                .then((value) =>
                                                    mustInitializeDoc = false);
                                          }
                                          await Database(uid).sendMessage(
                                              chatId,
                                              msg,
                                              uid,
                                              peerId,
                                              attachment.value);
                                          attachment.value = null;
                                          msgController.clear();
                                        }
                                      },
                                      icon: Icon(Icons.send,
                                          color: focusValue.value
                                              ? CustomTheme.msgIcon
                                              : CustomTheme.msgIcon
                                                  .withAlpha(100)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                ),
              )
            ]),
          ));
    }
    return Scaffold(
        appBar: AppBar(),
        body: SpinKitWanderingCubes(
            color: Theme.of(context).primaryColor, size: 75));
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
