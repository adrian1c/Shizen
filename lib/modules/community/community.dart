import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shizen_app/modules/profile/profile.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/dropdown.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/utils/dateTimeAgo.dart';
import 'package:intl/intl.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

import './addnewpost.dart';

class CommunityPage extends HookWidget {
  CommunityPage({Key? key}) : super(key: key);

  final List<String> items = [
    'Friends Only',
    'Everyone',
    'Anonymous',
  ];

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final hashtagController = useTextEditingController();
    final visibilityValue = useState('Everyone');
    final hashtagValue = useState('');
    final isFocus = useFocusNode();
    isFocus.addListener(() {
      if (isFocus.hasFocus != true) {
        hashtagValue.value = hashtagController.text;
      }
    });

    return Stack(
        fit: StackFit.expand,
        alignment: Alignment.topCenter,
        children: [
          CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                pinned: false,
                snap: false,
                floating: true,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Dropdown(
                            items: items,
                            value: visibilityValue,
                            onItemSelected: (String value) {
                              visibilityValue.value = value;
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
              SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                return CommunityPostList(
                  visibilityValue: visibilityValue,
                  hashtag: hashtagValue,
                  hashtagController: hashtagController,
                );
              }, childCount: 1))
            ],
          ),
        ]);
  }
}

class CommunityPostList extends HookWidget {
  CommunityPostList({
    Key? key,
    required this.visibilityValue,
    this.hashtag,
    this.hashtagController,
  }) : super(key: key);

  final visibilityValue;
  final hashtag;
  final hashtagController;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(
        () => Database(uid)
            .getCommunityPost(visibilityValue.value, hashtag.value),
        [visibilityValue.value, hashtag.value]);
    final snapshot = useFuture(future);
    if (snapshot.hasData) {
      return Container(
          child: snapshot.data!.length > 0
              ? ListView.builder(
                  physics: BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return PostListTile(
                      postData: snapshot.data![index],
                      hashtag: hashtag,
                      hashtagController: hashtagController,
                    );
                  })
              : Center(
                  child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'No posts found. \nConsider switching the visibility or using a different hashtag.',
                    textAlign: TextAlign.center,
                  ),
                )));
    }

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
          physics: BouncingScrollPhysics(),
          shrinkWrap: true,
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 80.w,
                height: 30.h,
                color: Colors.white);
          }),
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
  }) : super(key: key);

  final postData;
  final hashtag;
  final hashtagController;
  final isProfile;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final commentController = useTextEditingController();
    final commentCount = useState(postData['commentCount']);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            decoration: BoxDecoration(
                color: Colors.blueGrey[100],
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                        title: Text(
                                            '${postData['name']}\'s Profile'),
                                        centerTitle: true,
                                      ),
                                      body:
                                          ProfilePage(viewId: postData['uid']));
                                }));
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                                width: 5.h,
                                height: 5.h,
                                child: postData['image'] != ''
                                    ? CircleAvatar(
                                        foregroundImage:
                                            CachedNetworkImageProvider(
                                                postData!['image']),
                                        backgroundColor: Colors.grey,
                                        radius: 3.h,
                                      )
                                    : CircleAvatar(
                                        foregroundImage:
                                            Images.defaultPic.image,
                                        backgroundColor: Colors.grey,
                                        radius: 3.h,
                                      )),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(postData['name']),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(postData['desc'],
                          style: Theme.of(context).textTheme.headline4),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                                                    postData['attachment']
                                                        ['title'];

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
                                                            isEdit: false),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                        constraints:
                                            BoxConstraints(minWidth: 25.w),
                                        height: 5.h,
                                        decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(15),
                                                topRight: Radius.circular(15))),
                                        child: Center(
                                            child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 15.0),
                                          child: Text(
                                              postData['attachment']['title']),
                                        ))),
                                    Text(postData['attachment']
                                                ['timeCompleted'] !=
                                            null
                                        ? 'Completed at ${DateFormat("hh:mm a").format((postData['attachment']['timeCompleted'] as Timestamp).toDate())}'
                                        : '')
                                  ],
                                ),
                                ConstrainedBox(
                                    constraints: BoxConstraints(
                                        minHeight: 5.h, minWidth: 100.w),
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.amber[200],
                                          border: Border.all(
                                              color: Colors.amber, width: 5),
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                              topRight: Radius.circular(5)),
                                        ),
                                        child: ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: postData['attachment']
                                                    ['taskList']
                                                .length,
                                            itemBuilder: (context, index) {
                                              return SizedBox(
                                                height: 5.h,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: postData['attachment']
                                                                  ['taskList']
                                                              [index]['status']
                                                          ? Colors
                                                              .lightGreen[400]
                                                          : null),
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        shape: CircleBorder(),
                                                        activeColor: Colors
                                                            .lightGreen[700],
                                                        value: postData[
                                                                    'attachment']
                                                                ['taskList']
                                                            [index]['status'],
                                                        onChanged: (value) {},
                                                      ),
                                                      Text(
                                                          postData['attachment']
                                                                  ['taskList']
                                                              [index]['task'],
                                                          softWrap: false,
                                                          style: TextStyle(
                                                              decoration: postData['attachment']
                                                                              [
                                                                              'taskList']
                                                                          [
                                                                          index]
                                                                      ['status']
                                                                  ? TextDecoration
                                                                      .lineThrough
                                                                  : null)),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            }))),
                              ],
                            ),
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
                                    hashtag.value = postData['hashtags'][index];
                                    hashtagController.text =
                                        postData['hashtags'][index];
                                  },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.blueGrey[200],
                                  borderRadius: BorderRadius.circular(20)),
                              child: Center(
                                child: Text('#${postData['hashtags'][index]}',
                                    style:
                                        Theme.of(context).textTheme.overline),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                CommentList(
                    pid: postData['postId'], commentCount: commentCount),
                Center(
                  child: InkWell(
                      onTap: () {
                        showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
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
                                                if (commentController
                                                        .text.length !=
                                                    0) {
                                                  await Database(uid)
                                                      .postComment(
                                                          postData['postId'],
                                                          commentController
                                                              .text)
                                                      .then((value) {
                                                    commentController.clear();
                                                    commentCount.value += 1;
                                                  });
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
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          width: 50.w,
                          height: 5.h,
                          decoration: new BoxDecoration(
                            border: Border.all(color: Colors.black26, width: 1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                              child: Text(
                            'Add a comment',
                            style: TextStyle(fontSize: 13.sp),
                          )))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Text(
                      (postData['dateCreated'] as Timestamp).toDate().timeAgo(),
                      style:
                          TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                )
              ],
            ),
          ),
          Divider(),
        ],
      ),
    );
  }
}

class CommentList extends HookWidget {
  const CommentList({Key? key, required this.pid, required this.commentCount})
      : super(key: key);

  final pid;
  final commentCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: commentCount.value > 0
          ? () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CommentPage(pid: pid, commentCount: commentCount),
                  ));
            }
          : () {},
      child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
          child: commentCount.value > 0
              ? Text('View all ${commentCount.value} comments')
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
                hintText: '# Search...', controller: hashtagController)
            .inputDecoration(),
        onFieldSubmitted: (value) {
          hashtagValue.value = value;
        },
      ),
    );
  }
}

class CommentPage extends HookWidget {
  const CommentPage({Key? key, required this.pid, required this.commentCount})
      : super(key: key);

  final pid;
  final commentCount;

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(() => Database(uid).getComments(pid),
        [Provider.of<TabProvider>(context).comment]);
    final snapshot = useFuture(future);
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
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
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
                                            title: Text(
                                                '${comment['name']}\'s Profile'),
                                            centerTitle: true,
                                          ),
                                          body: ProfilePage(
                                              viewId: comment['userId']));
                                    }));
                                  },
                                )),
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
                                        commentController.clear();
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);
                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        await Database(uid)
                                            .postComment(pid, comment)
                                            .then((value) {
                                          commentCount.value += 1;
                                        });
                                        Provider.of<TabProvider>(context,
                                                listen: false)
                                            .rebuildPage('comment');
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
        body: SpinKitWanderingCubes(color: Colors.blueGrey, size: 75));
  }
}
