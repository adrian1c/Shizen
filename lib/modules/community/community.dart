import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shizen_app/modules/profile/profile.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/dropdown.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/utils/dateTimeAgo.dart';
import 'package:intl/intl.dart';

import './addnewpost.dart';

class CommunityPage extends HookWidget {
  final List<String> items = [
    'Friends Only',
    'Everyone',
    'Anonymous',
  ];

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;
    final hashtagController = useTextEditingController();
    final visibilityValue = useState('Friends Only');
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
                pinned: false,
                snap: false,
                floating: true,
                expandedHeight: 11.h,
                collapsedHeight: 11.h,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.visibility),
                                Text("Display",
                                    style: TextStyle(fontSize: 15.sp)),
                              ],
                            ),
                            Dropdown(
                                items: items,
                                value: visibilityValue,
                                onItemSelected: (String value) {
                                  visibilityValue.value = value;
                                }),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.tag_rounded),
                                Text("Hashtag",
                                    style: TextStyle(fontSize: 15.sp)),
                              ],
                            ),
                            HashtagFilter(
                                hashtagController: hashtagController,
                                hashtagValue: hashtagValue,
                                isFocus: isFocus),
                          ],
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
          Positioned(
            bottom: 30,
            child: ElevatedButton(
              child: Text("New Post"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddNewPost()));
              },
            ),
          ),
        ]);
  }
}

class CommunityPostList extends HookWidget {
  CommunityPostList(
      {Key? key,
      required this.visibilityValue,
      this.hashtag,
      this.hashtagController})
      : super(key: key);

  final visibilityValue;
  final hashtag;
  final hashtagController;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).uid;
    final future = useMemoized(
        () => Database(uid)
            .getCommunityPost(visibilityValue.value, hashtag.value),
        [visibilityValue.value, hashtag.value]);
    final snapshot = useFuture(future);
    return Container(
        child: !snapshot.hasData
            ? const Text("Loading")
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return PostListTile(
                    postData: snapshot.data![index],
                    hashtag: hashtag,
                    hashtagController: hashtagController,
                  );
                }));
  }
}

class PostListTile extends HookWidget {
  const PostListTile(
      {Key? key, required this.postData, this.hashtag, this.hashtagController})
      : super(key: key);

  final postData;
  final hashtag;
  final hashtagController;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).uid;
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
                                      foregroundImage: Images.defaultPic.image,
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
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(postData['desc']),
                    ),
                    if (postData['attachmentType'] != null)
                      if (postData['attachmentType'] == 'image')
                        Image(
                            width: 100.w,
                            image: CachedNetworkImageProvider(
                                postData['attachment']),
                            fit: BoxFit.fitWidth),
                    if (postData['attachmentType'] == 'task')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Transform.scale(
                          scale: 0.9,
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
                                      ? 'Completed at ${DateFormat("hh:MM a").format((postData['attachment']['timeCompleted'] as Timestamp).toDate())}'
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
                                                    color:
                                                        postData['attachment']
                                                                    ['taskList']
                                                                [
                                                                index]['status']
                                                            ? Colors
                                                                .lightGreen[400]
                                                            : null),
                                                child: Row(
                                                  children: [
                                                    Checkbox(
                                                      shape: CircleBorder(),
                                                      activeColor: Colors
                                                          .lightGreen[700],
                                                      value:
                                                          postData['attachment']
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
                                                            decoration: postData[
                                                                            'attachment']
                                                                        [
                                                                        'taskList'][index]
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
                            onTap: () {
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
                                    style: TextStyle(
                                        fontSize: 13.sp,
                                        decoration: TextDecoration.underline)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                CommentList(
                    pid: postData['postId'], commentCount: commentCount.value),
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
      onTap: commentCount > 0
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
          child: commentCount > 0
              ? Text('View all $commentCount comments')
              : null),
    );
  }
}

class HashtagFilter extends StatelessWidget {
  const HashtagFilter(
      {Key? key,
      required this.hashtagController,
      required this.hashtagValue,
      required this.isFocus})
      : super(key: key);

  final TextEditingController hashtagController;
  final hashtagValue;
  final isFocus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      child: TextFormField(
        controller: hashtagController,
        focusNode: isFocus,
        inputFormatters: [
          LengthLimitingTextInputFormatter(20),
        ],
        decoration: StyledInputField(
                hintText: 'Search hashtag...', controller: hashtagController)
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
    String uid = Provider.of<UserProvider>(context).uid;
    final future = useMemoized(
      () => Database(uid).getComments(pid),
    );
    final snapshot = useFuture(future);
    final commentController = useTextEditingController();
    if (snapshot.hasData) {
      final commentList = useState(snapshot.data.docs);
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
                        itemCount: commentList.value.length,
                        itemBuilder: (context, index) {
                          var comment = commentList.value[index];
                          return Container(
                            padding: const EdgeInsets.all(10),
                            child: ListTile(
                                title: Text(comment['name']),
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
                                        FocusScopeNode currentFocus =
                                            FocusScope.of(context);

                                        if (!currentFocus.hasPrimaryFocus) {
                                          currentFocus.unfocus();
                                        }
                                        commentController.clear();
                                        var newComment = await Database(uid)
                                            .postComment(
                                                pid, commentController.text)
                                            .then((value) {
                                          commentCount.value += 1;
                                        });
                                        commentList.value =
                                            List.from(commentList.value)
                                              ..add(newComment);
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
