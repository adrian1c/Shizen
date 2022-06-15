import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shizen_app/modules/profile/profile.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/dropdown.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/utils/dateTimeAgo.dart';
import 'package:intl/intl.dart';

import './addnewpost.dart';

class CommunityPage extends HookWidget {
  CommunityPage({Key? key}) : super(key: key);

  final List<String> items = [
    'Everyone',
    'Friends Only',
    'Anonymous',
  ];

  @override
  Widget build(BuildContext context) {
    final hashtagController = useTextEditingController();
    final visibilityValue = useState('Everyone');
    final hashtagValue = useState('');
    final isFocus = useFocusNode();

    useEffect(() {
      isFocus.addListener(() {
        if (isFocus.hasFocus != true) {
          hashtagValue.value = hashtagController.text;
        }
      });
      return;
    }, []);

    return NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, val) => [
              SliverAppBar(
                automaticallyImplyLeading: false,
                forceElevated: true,
                snap: false,
                floating: true,
                flexibleSpace: Container(
                  decoration:
                      BoxDecoration(color: CustomTheme.dividerBackground),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Dropdown2(
                            items: items,
                            visibilityValue: visibilityValue,
                            callback: (String? value) {
                              if (visibilityValue.value == value) {
                                return;
                              }
                              visibilityValue.value = value!;
                            }),
                        HashtagFilter(
                          hashtagController: hashtagController,
                          hashtagValue: hashtagValue,
                          isFocus: isFocus,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //  SliverPersistentHeader(delegate: Delegate(),pinned: true,)
            ],
        body: visibilityValue.value == 'Everyone'
            ? EveryoneList(
                visibilityValue: visibilityValue,
                hashtagValue: hashtagValue,
                hashtagController: hashtagController,
              )
            : visibilityValue.value == 'Friends Only'
                ? FriendsOnlyList(
                    visibilityValue: visibilityValue,
                    hashtagValue: hashtagValue,
                    hashtagController: hashtagController,
                  )
                : visibilityValue.value == 'Anonymous'
                    ? AnonymousList(
                        visibilityValue: visibilityValue,
                        hashtagValue: hashtagValue,
                        hashtagController: hashtagController,
                      )
                    : Center(child: Text('No posts found')));
  }
}

class EveryoneList extends HookWidget {
  const EveryoneList({
    Key? key,
    required this.visibilityValue,
    required this.hashtagValue,
    required this.hashtagController,
  }) : super(key: key);

  final ValueNotifier<String> visibilityValue;
  final ValueNotifier<String> hashtagValue;
  final TextEditingController hashtagController;

  loadMorePosts(
      uid, visibilityValue, hashtagValue, postsList, loadMore, lastDoc) async {
    var newPosts = await Database(uid)
        .getCommunityPostEveryone(hashtagValue.value, true, lastDoc.value);
    if (newPosts[0].isEmpty) {
      loadMore.value = false;
      lastDoc.value = null;
      return;
    }

    loadMore.value = null;
    postsList.value.addAll(newPosts[0]);
    lastDoc.value = newPosts[1];

    return;
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final posts = useState([]);
    final initialLoad = useState(false);
    final ValueNotifier<bool?> loadMore = useState(null);
    final ValueNotifier<DocumentSnapshot?> lastDoc = useState(null);
    final future = useMemoized(
        () => Database(uid).getCommunityPostEveryone(hashtagValue.value),
        [visibilityValue.value, hashtagValue.value]);
    final snapshot = useFuture(future);

    useEffect(() {
      initialLoad.value = false;
      loadMore.value = null;

      return;
    }, [visibilityValue.value, hashtagValue.value]);

    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
      if (!initialLoad.value) {
        posts.value = snapshot.data![0];
        lastDoc.value = snapshot.data![1];
        initialLoad.value = true;
      }
      return posts.value.length > 0
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scroll) {
                if (scroll is ScrollEndNotification) {
                  if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                      loadMore.value == null) {
                    loadMore.value = true;
                    loadMorePosts(uid, visibilityValue, hashtagValue, posts,
                        loadMore, lastDoc);

                    return true;
                  }
                }
                return true;
              },
              child: ListView.builder(
                itemCount: posts.value.length + 1,
                itemBuilder: (context, index) {
                  if (index == posts.value.length) {
                    if (loadMore.value == null) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 35));
                    }
                    if (loadMore.value == true) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SpinKitWanderingCubes(
                            color: Theme.of(context).primaryColor, size: 75),
                      );
                    }
                    return Center(child: Text('----- NO MORE POSTS -----'));
                  }
                  return PostListTile(
                    postData: posts.value[index],
                    hashtag: hashtagValue,
                    hashtagController: hashtagController,
                    posts: posts,
                    initialLoad: initialLoad,
                    loadMore: loadMore,
                  );
                },
              ),
            )
          : Center(child: Text('No posts found'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: SpinKitWanderingCubes(
        color: Theme.of(context).primaryColor,
        size: 75.0,
      ),
    );
  }
}

class FriendsOnlyList extends HookWidget {
  const FriendsOnlyList({
    Key? key,
    required this.visibilityValue,
    required this.hashtagValue,
    required this.hashtagController,
  }) : super(key: key);

  final ValueNotifier<String> visibilityValue;
  final ValueNotifier<String> hashtagValue;
  final TextEditingController hashtagController;

  loadMorePosts(
      uid, postIds, hashtagValue, lastIndex, postsList, loadMore) async {
    var newPosts = await Database(uid).getCommunityPostFriendsOnly(
        postIds.value, hashtagValue.value, lastIndex.value);
    if (newPosts[0].isEmpty) {
      loadMore.value = false;
      lastIndex.value = 0;
      return;
    }

    loadMore.value = null;
    postsList.value.addAll(newPosts[0]);
    lastIndex.value = newPosts[1];

    return;
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final postIds = useState([]);
    final posts = useState([]);
    final initialLoad = useState(false);
    final ValueNotifier<bool?> loadMore = useState(null);
    final lastIndex = useState(0);
    final future = useMemoized(
        () => Database(uid)
            .getCommunityPostFriendsOnlyFirstLoad(hashtagValue.value),
        [visibilityValue.value, hashtagValue.value]);
    final snapshot = useFuture(future);
    final scrollController = useScrollController();

    useEffect(() {
      initialLoad.value = false;
      loadMore.value = null;

      return;
    }, [visibilityValue.value, hashtagValue.value]);

    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
      if (!initialLoad.value) {
        postIds.value = snapshot.data[0];
        posts.value = snapshot.data[1];
        lastIndex.value = snapshot.data[2];
        initialLoad.value = true;
      }
      return posts.value.length > 0
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scroll) {
                if (scroll is ScrollEndNotification) {
                  if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                      loadMore.value == null) {
                    loadMore.value = true;
                    loadMorePosts(
                        uid, postIds, hashtagValue, lastIndex, posts, loadMore);

                    return true;
                  }
                }
                return true;
              },
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: posts.value.length + 1,
                itemBuilder: (context, index) {
                  if (index == posts.value.length) {
                    if (loadMore.value == null) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 35));
                    }
                    if (loadMore.value == true) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SpinKitWanderingCubes(
                            color: Theme.of(context).primaryColor, size: 75),
                      );
                    }
                    return Center(child: Text('----- NO MORE POSTS -----'));
                  }
                  return PostListTile(
                    postData: posts.value[index],
                    hashtag: hashtagValue,
                    hashtagController: hashtagController,
                    posts: posts,
                    initialLoad: initialLoad,
                    loadMore: loadMore,
                  );
                },
              ),
            )
          : Center(child: Text('No posts found'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: SpinKitWanderingCubes(
        color: Theme.of(context).primaryColor,
        size: 75.0,
      ),
    );
  }
}

class AnonymousList extends HookWidget {
  const AnonymousList({
    Key? key,
    required this.visibilityValue,
    required this.hashtagValue,
    required this.hashtagController,
  }) : super(key: key);

  final ValueNotifier<String> visibilityValue;
  final ValueNotifier<String> hashtagValue;
  final TextEditingController hashtagController;

  loadMorePosts(
      uid, visibilityValue, hashtagValue, postsList, loadMore, lastDoc) async {
    var newPosts = await Database(uid)
        .getCommunityPostAnonymous(hashtagValue.value, true, lastDoc.value);
    if (newPosts[0].isEmpty) {
      loadMore.value = false;
      lastDoc.value = null;
      return;
    }

    loadMore.value = null;
    postsList.value.addAll(newPosts[0]);
    lastDoc.value = newPosts[1];

    return;
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final posts = useState([]);
    final initialLoad = useState(false);
    final ValueNotifier<bool?> loadMore = useState(null);
    final ValueNotifier<DocumentSnapshot?> lastDoc = useState(null);
    final future = useMemoized(
        () => Database(uid).getCommunityPostAnonymous(hashtagValue.value),
        [visibilityValue.value, hashtagValue.value]);
    final snapshot = useFuture(future);
    final scrollController = useScrollController();

    useEffect(() {
      initialLoad.value = false;
      loadMore.value = null;

      return;
    }, [visibilityValue.value, hashtagValue.value]);

    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
      if (!initialLoad.value) {
        posts.value = snapshot.data![0];
        lastDoc.value = snapshot.data![1];
        initialLoad.value = true;
      }
      return posts.value.length > 0
          ? NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scroll) {
                if (scroll is ScrollEndNotification) {
                  if (scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                      loadMore.value == null) {
                    loadMore.value = true;
                    loadMorePosts(uid, visibilityValue, hashtagValue, posts,
                        loadMore, lastDoc);

                    return true;
                  }
                }
                return true;
              },
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: posts.value.length + 1,
                itemBuilder: (context, index) {
                  if (index == posts.value.length) {
                    if (loadMore.value == null) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 35));
                    }
                    if (loadMore.value == true) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SpinKitWanderingCubes(
                            color: Theme.of(context).primaryColor, size: 75),
                      );
                    }
                    return Center(child: Text('----- NO MORE POSTS -----'));
                  }
                  return PostListTile(
                    postData: posts.value[index],
                    hashtag: hashtagValue,
                    hashtagController: hashtagController,
                    posts: posts,
                    initialLoad: initialLoad,
                    loadMore: loadMore,
                  );
                },
              ),
            )
          : Center(child: Text('No posts found'));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: SpinKitWanderingCubes(
        color: Theme.of(context).primaryColor,
        size: 75.0,
      ),
    );
  }
}

class PostListTile extends HookWidget {
  const PostListTile({
    Key? key,
    required this.postData,
    this.hashtag,
    this.hashtagController,
    this.isProfile = false,
    this.posts,
    this.initialLoad,
    this.loadMore,
  }) : super(key: key);

  final postData;
  final hashtag;
  final hashtagController;
  final isProfile;
  final posts;
  final initialLoad;
  final loadMore;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final commentController = useTextEditingController();
    final commentCount = useState(postData['commentCount']);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
      child: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: CustomTheme.boxShadow),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                  child: InkWell(
                    onTap: isProfile
                        ? () {}
                        : () {
                            if (postData['visibility'] == 'Anonymous') {
                              return;
                            }
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Scaffold(
                                  appBar: AppBar(
                                    title: Text(postData['name'].length < 12
                                        ? '${postData['name']}\'s Profile'
                                        : 'Profile'),
                                    centerTitle: true,
                                  ),
                                  body: ProfilePage(viewId: postData['uid']));
                            }));
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: 5.h,
                            height: 5.h,
                            child: CircleAvatar(
                              foregroundImage: postData['image'] != ''
                                  ? CachedNetworkImageProvider(
                                      postData!['image'])
                                  : Images.defaultPic.image,
                              backgroundColor: Colors.grey,
                              radius: 3.h,
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                postData['name'],
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              Text(postData['email']),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 2,
                  height: 0,
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(postData['desc'],
                      style: Theme.of(context).textTheme.headline5),
                ),
                if (postData['attachmentType'] != null)
                  if (postData['attachmentType'] == 'image')
                    CachedNetworkImage(
                        width: 100.w,
                        imageUrl: postData['attachment'],
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) => SizedBox(
                                  width: 100.w,
                                  height: 100.w,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                    ),
                                  ),
                                ),
                        fit: BoxFit.fitWidth),
                if (postData['attachmentType'] == 'task')
                  Container(
                    color: CustomTheme.attachmentBackground,
                    padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
                    child: Transform.scale(
                      scale: 0.9,
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    title: Text('Create Similar Task?'),
                                    actions: [
                                      TextButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                            List task = [];
                                            var taskList =
                                                postData['attachment']
                                                    ['taskList'];
                                            var title =
                                                postData['attachment']['title'];

                                            for (var i = 0;
                                                i < taskList.length;
                                                i++) {
                                              var tempMap = {
                                                'task': taskList[i]['task'],
                                                'status': false
                                              };
                                              task.add(tempMap);
                                            }
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddToDoTask(
                                                  editParams: {
                                                    'id': null,
                                                    'title': title,
                                                    'desc': task,
                                                    'recur': [
                                                      false,
                                                      false,
                                                      false,
                                                      false,
                                                      false,
                                                      false,
                                                      false
                                                    ],
                                                    'reminder': null,
                                                    'isPublic': false,
                                                  },
                                                  isEdit: false,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Text("Yes")),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Cancel"),
                                      ),
                                    ]);
                              });
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    constraints: BoxConstraints(
                                        minWidth: 25.w, minHeight: 5.h),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withAlpha(200),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15))),
                                    child: Center(
                                        child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Text(
                                          postData['attachment']['title'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .headline4),
                                    ))),
                                Text(postData['attachment']['timeCompleted'] !=
                                        null
                                    ? '${DateFormat("d MMM @ h:mm a").format((postData['attachment']['timeCompleted'] as Timestamp).toDate())}'
                                    : '')
                              ],
                            ),
                            ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: 5.h, minWidth: 100.w),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withAlpha(200),
                                      borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                          topRight: Radius.circular(15)),
                                      boxShadow: CustomTheme.boxShadow,
                                    ),
                                    child: ListView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: postData['attachment']
                                                ['taskList']
                                            .length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            constraints:
                                                BoxConstraints(minHeight: 5.h),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15, vertical: 10),
                                            decoration: BoxDecoration(
                                                color: postData['attachment']
                                                            ['taskList'][index]
                                                        ['status']
                                                    ? CustomTheme.completeColor
                                                    : Theme.of(context)
                                                        .backgroundColor,
                                                borderRadius: index == 0
                                                    ? BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(15),
                                                        bottomLeft:
                                                            postData['attachment']
                                                                            [
                                                                            'taskList']
                                                                        .length ==
                                                                    1
                                                                ? Radius
                                                                    .circular(
                                                                        15)
                                                                : Radius.zero,
                                                        bottomRight:
                                                            postData['attachment']
                                                                            [
                                                                            'taskList']
                                                                        .length ==
                                                                    1
                                                                ? Radius
                                                                    .circular(
                                                                        15)
                                                                : Radius.zero,
                                                      )
                                                    : index ==
                                                            postData['attachment']
                                                                        [
                                                                        'taskList']
                                                                    .length -
                                                                1
                                                        ? BorderRadius.only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    15),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    15),
                                                          )
                                                        : null),
                                            child: Row(
                                              children: [
                                                AbsorbPointer(
                                                  child: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: Checkbox(
                                                      shape: CircleBorder(),
                                                      activeColor:
                                                          Theme.of(context)
                                                              .backgroundColor,
                                                      checkColor: Colors
                                                          .lightGreen[700],
                                                      value:
                                                          postData['attachment']
                                                                  ['taskList']
                                                              [index]['status'],
                                                      onChanged: (value) {},
                                                    ),
                                                  ),
                                                ),
                                                Flexible(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Text(
                                                        postData['attachment']
                                                                ['taskList']
                                                            [index]['task'],
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                            decoration: postData[
                                                                            'attachment']
                                                                        [
                                                                        'taskList'][index]
                                                                    ['status']
                                                                ? TextDecoration
                                                                    .lineThrough
                                                                : null)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }))),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (postData['attachmentType'] == 'tracker')
                  Container(
                    color: CustomTheme.attachmentBackground,
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).backgroundColor,
                          boxShadow: CustomTheme.boxShadow),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(postData['attachment']['title'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withAlpha(200))),
                              Row(
                                children: [
                                  Text(
                                      '${postData['attachment']['currStreak']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Icon(Icons.park_rounded,
                                      color: Color.fromARGB(255, 147, 182, 117))
                                ],
                              )
                            ],
                          ),
                          Padding(padding: EdgeInsets.symmetric(vertical: 5)),
                          Divider(),
                          Text(postData['attachment']['note'])
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (postData['hashtags'].length > 0)
              Container(
                padding: const EdgeInsets.all(10),
                width: 100.w,
                height: 50,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: postData['hashtags'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: InkWell(
                        onTap: isProfile
                            ? () {}
                            : () {
                                posts.value = [];
                                initialLoad.value = false;
                                loadMore.value = true;
                                hashtag.value = postData['hashtags'][index];
                                hashtagController.text =
                                    postData['hashtags'][index];
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).primaryColor.withAlpha(150),
                              borderRadius: BorderRadius.circular(20)),
                          child: Center(
                            child: Text('#${postData['hashtags'][index]}',
                                style: Theme.of(context).textTheme.overline),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            Divider(thickness: 2, height: 0),
            CommentList(
                pid: postData['postId'],
                puid: postData['uid'],
                commentCount: commentCount),
            Center(
              child: InkWell(
                  onTap: () {
                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Container(
                            height: 10.h,
                            color: Colors.grey[200],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      controller: commentController,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        hintText: 'Post a comment',
                                        suffixIcon: IconButton(
                                          onPressed: () async {
                                            if (commentController.text.length !=
                                                0) {
                                              await LoaderWithToast(
                                                      context: context,
                                                      api: Database(uid)
                                                          .postComment(
                                                              postData[
                                                                  'postId'],
                                                              postData['uid'],
                                                              commentController
                                                                  .text)
                                                          .then((value) {
                                                        commentController
                                                            .clear();
                                                        commentCount.value += 1;
                                                      }),
                                                      msg: 'Comment Posted',
                                                      isSuccess: true)
                                                  .show();
                                              Navigator.pop(context);
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
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                          decoration: new BoxDecoration(
                            border: Border.all(color: Colors.black26, width: 1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                              child: Text(
                            'Add a comment',
                            style: TextStyle(fontSize: 13.sp),
                          ))),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 0),
              child: Text(
                  (postData['dateCreated'] as Timestamp).toDate().timeAgo(),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
            )
          ],
        ),
      ),
    );
  }
}

class CommentList extends HookWidget {
  const CommentList(
      {Key? key,
      required this.pid,
      required this.puid,
      required this.commentCount})
      : super(key: key);

  final pid;
  final puid;
  final commentCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: commentCount.value > 0
          ? () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CommentPage(
                        pid: pid, puid: puid, commentCount: commentCount),
                  ));
            }
          : () {},
      child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
          child: commentCount.value > 0
              ? Text(
                  'View all ${commentCount.value} comments',
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              : null),
    );
  }
}

class HashtagFilter extends StatelessWidget {
  const HashtagFilter({
    Key? key,
    required this.hashtagController,
    required this.hashtagValue,
    required this.isFocus,
  }) : super(key: key);

  final TextEditingController hashtagController;
  final hashtagValue;
  final isFocus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45.w,
      child: TextFormField(
        controller: hashtagController,
        focusNode: isFocus,
        inputFormatters: [
          LengthLimitingTextInputFormatter(20),
        ],
        decoration: StyledInputField(
            hintText: '# Search...',
            controller: hashtagController,
            inputValue: hashtagValue,
            callback: () {
              hashtagValue.value = '';
              hashtagController.clear();
            }).inputDecoration(),
        onFieldSubmitted: (value) {
          hashtagValue.value = value;
        },
      ),
    );
  }
}

class CommentPage extends HookWidget {
  const CommentPage(
      {Key? key,
      required this.pid,
      required this.puid,
      required this.commentCount})
      : super(key: key);

  final pid;
  final puid;
  final commentCount;

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final stream = useMemoized(() => Database(uid).getComments(pid), []);
    final snapshot = useStream(stream);
    final commentController = useTextEditingController();
    if (snapshot.hasData) {
      final commentList = snapshot.data.docs;
      return Scaffold(
        appBar: AppBar(
          title: const Text("ALL COMMENTS"),
          centerTitle: true,
        ),
        body: snapshot.hasData
            ? Stack(fit: StackFit.expand, children: [
                Container(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: commentList.length,
                        itemBuilder: (context, index) {
                          var comment = commentList[index];
                          return Column(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: ListTile(
                                  onLongPress: comment['userId'] == uid
                                      ? () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                    title: Text('Options'),
                                                    content: TextButton(
                                                      child: Text(
                                                          'Delete comment'),
                                                      onPressed: () async {
                                                        await LoaderWithToast(
                                                                context:
                                                                    context,
                                                                api: Database(
                                                                        uid)
                                                                    .removeComment(
                                                                        pid,
                                                                        commentList[index]
                                                                            .id)
                                                                    .then(
                                                                        (value) {
                                                                  Navigator.pop(
                                                                      context);
                                                                  commentCount
                                                                      .value--;
                                                                }),
                                                                msg:
                                                                    'Comment Deleted',
                                                                isSuccess: true)
                                                            .show();
                                                      },
                                                    ),
                                                  ));
                                        }
                                      : null,
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(comment['name']),
                                      Text(
                                          (comment['dateCreated'] as Timestamp)
                                              .toDate()
                                              .timeAgo(),
                                          style: TextStyle(fontSize: 10.sp)),
                                    ],
                                  ),
                                  subtitle: Text(comment['comment'],
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis),
                                  leading: InkWell(
                                    child: CircleAvatar(
                                      foregroundImage: comment['image'] != ''
                                          ? CachedNetworkImageProvider(
                                              comment['image'])
                                          : Images.defaultPic.image,
                                      backgroundColor: Colors.grey,
                                      radius: 3.h,
                                    ),
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return Scaffold(
                                            appBar: AppBar(
                                              title: Text(comment['name']
                                                          .length <
                                                      12
                                                  ? '${comment['name']}\'s Profile'
                                                  : 'Profile'),
                                              centerTitle: true,
                                            ),
                                            body: ProfilePage(
                                                viewId: comment['userId']));
                                      }));
                                    },
                                  ),
                                ),
                              ),
                              Divider(),
                            ],
                          );
                        })),
                Positioned(
                  bottom: 0,
                  child: Align(
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
                                controller: commentController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  hintText: 'Post a comment',
                                  suffixIcon: IconButton(
                                    onPressed: () async {
                                      if (commentController.text.length != 0) {
                                        final comment = commentController.text;

                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        await LoaderWithToast(
                                                context: context,
                                                api: Database(uid)
                                                    .postComment(
                                                        pid, puid, comment)
                                                    .then((value) {
                                                  commentCount.value += 1;
                                                  commentController.clear();
                                                }),
                                                msg: 'Comment Posted',
                                                isSuccess: true)
                                            .show();
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
                  ),
                )
              ])
            : Container(child: Text('Loading')),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text("ALL COMMENTS"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50.0),
          child: SpinKitWanderingCubes(
            color: Theme.of(context).primaryColor,
            size: 75.0,
          ),
        ));
  }
}
