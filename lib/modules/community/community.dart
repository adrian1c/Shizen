import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/dropdown.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/utils/dateTimeAgo.dart';

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

class PostListTile extends StatelessWidget {
  const PostListTile(
      {Key? key, required this.postData, this.hashtag, this.hashtagController})
      : super(key: key);

  final postData;
  final hashtag;
  final hashtagController;

  @override
  Widget build(BuildContext context) {
    return Column(
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
                                    foregroundImage: CachedNetworkImageProvider(
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
                  if (postData['attachment'] != null)
                    Image(
                        width: 100.w,
                        image:
                            CachedNetworkImageProvider(postData['attachment']),
                        fit: BoxFit.fitWidth),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Text(
                    (postData['dateCreated'] as Timestamp).toDate().timeAgo(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
              )
            ],
          ),
        ),
        Divider(),
      ],
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
