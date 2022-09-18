import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shizen_app/modules/community/community.dart';
import 'package:shizen_app/modules/progress/progress.dart';
import 'package:shizen_app/modules/tasks/tasks.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shizen_app/utils/nestedFix.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shizen_app/widgets/todotile.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProfilePage extends HookWidget {
  const ProfilePage({Key? key, this.viewId}) : super(key: key);

  final String? viewId;

  @override
  Widget build(BuildContext context) {
    final String uid = viewId ?? Provider.of<UserProvider>(context).user.uid;
    final TextEditingController nameController = useTextEditingController();

    final futureUserProfileData = useMemoized(
        () => Database(uid).getCurrentUserData(),
        [Provider.of<TabProvider>(context).profileUser]);
    final snapshotUserProfileData = useFuture(futureUserProfileData);

    final tabController = useTabController(
      initialLength: 3,
      initialIndex: 0,
    );

    final scrollController = useScrollController();
    final scrollController2 = useScrollController();
    final scrollController3 = useScrollController();
    final scrollController4 = useScrollController();

    final tabIndex = useState(0);

    useEffect(() {
      tabController.addListener(() {
        tabIndex.value = tabController.index;
      });

      return () {};
    });

    if (snapshotUserProfileData.hasData) {
      if (uid != Provider.of<UserProvider>(context).user.uid &&
          snapshotUserProfileData.data!.data()!['private'] == true) {
        final checkPrivateFriend = useMemoized(
            () => Database(uid).checkIfFriend(uid),
            [Provider.of<TabProvider>(context).profileUser]);
        final snapshot = useFuture(checkPrivateFriend);

        if (snapshot.hasData) {
          if (snapshot.data != 2) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10.h,
                          height: 10.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 5.0,
                            ),
                          ),
                          child: CircleAvatar(
                            foregroundImage: snapshotUserProfileData.data!
                                        .data()!['image'] !=
                                    ''
                                ? CachedNetworkImageProvider(
                                    snapshotUserProfileData.data!
                                        .data()!['image'])
                                : Images.defaultPic.image,
                            backgroundColor: Colors.grey,
                          ),
                        ),
                        Flexible(
                          flex: 7,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    snapshotUserProfileData.data!
                                        .data()!['name'],
                                    style: TextStyle(fontSize: 20.sp)),
                                Text(
                                    snapshotUserProfileData.data!
                                        .data()!['name'],
                                    style: TextStyle(fontSize: 13.sp)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: const EdgeInsets.all(30)),
                    Text('This account is private.'),
                    Icon(Icons.lock, color: Colors.grey),
                    Padding(padding: const EdgeInsets.all(30)),
                    Text('Click the button below to add them as friend'),
                    ProfileAddFriendButton(targetUID: uid)
                  ],
                ),
              ),
            );
          }
          final tasksCompletedData = useMemoized(
              () => Database(uid).getCompletedTasksCount(uid),
              [Provider.of<TabProvider>(context).profileUser]);
          final snapshotTasksCompletedData = useFuture(tasksCompletedData);
          final checkinData = useMemoized(
              () => Database(uid).getTrackerCheckInCount(uid),
              [Provider.of<TabProvider>(context).profileUser]);
          final snapshotCheckinData = useFuture(checkinData);

          return NestedScrollView(
            key: viewId != null
                ? Keys.nestedScrollViewKeyProfileOtherPage
                : Keys.nestedScrollViewKeyProfilePage,
            controller: scrollController,
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                        context),
                    sliver: MultiSliver(children: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: UserProfileData(
                                data: snapshotUserProfileData.data,
                                uid: uid,
                                nameController: nameController,
                                viewId: viewId,
                                tasksCompleted: snapshotTasksCompletedData.data,
                                checkinData: snapshotCheckinData.data),
                          ),
                        ),
                      ),
                      SliverAppBar(
                        backgroundColor: CustomTheme.dividerBackground,
                        shadowColor: Colors.transparent,
                        automaticallyImplyLeading: false,
                        floating: false,
                        forceElevated: false,
                        centerTitle: true,
                        title: Container(
                          width: 80.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                          ),
                          child: TabBar(
                            controller: tabController,
                            indicator: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                25.0,
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor:
                                Theme.of(context).primaryColor,
                            tabs: [
                              Tab(
                                child: Icon(Icons.insert_chart_rounded),
                              ),
                              Tab(
                                child: Icon(Icons.track_changes),
                              ),
                              Tab(
                                child: Icon(Icons.dynamic_feed),
                              )
                            ],
                          ),
                        ),
                      ),
                      SliverPinnedHeader(
                        child: PreferredSize(
                          preferredSize: Size(100.w, 3.h),
                          child: AnimatedTextDivider(
                              ['STATS', 'ROUTINES', 'POSTS'], tabIndex),
                        ),
                      ),
                    ]))
              ];
            },
            body: TabBarView(
              physics: CustomTabBarViewScrollPhysics(),
              controller: tabController,
              children: [
                KeepAlivePage(
                  child: Builder(builder: (context) {
                    return NestedFix(
                      globalKey: viewId != null
                          ? Keys.nestedScrollViewKeyProfileOtherPage
                          : Keys.nestedScrollViewKeyProfilePage,
                      child: CustomScrollView(
                          controller: scrollController2,
                          slivers: [
                            SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                            RoutinesStats(
                              targetUID: uid,
                            ),
                          ]),
                    );
                  }),
                ),
                KeepAlivePage(
                  child: Builder(builder: (context) {
                    return NestedFix(
                      globalKey: viewId != null
                          ? Keys.nestedScrollViewKeyProfileOtherPage
                          : Keys.nestedScrollViewKeyProfilePage,
                      child: CustomScrollView(
                          controller: scrollController3,
                          slivers: [
                            SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                            ProfileToDo(
                                uid: uid,
                                ownProfile: viewId != null ? false : true)
                          ]),
                    );
                  }),
                ),
                KeepAlivePage(
                  child: Builder(builder: (context) {
                    return NestedFix(
                      globalKey: viewId != null
                          ? Keys.nestedScrollViewKeyProfileOtherPage
                          : Keys.nestedScrollViewKeyProfilePage,
                      child: CustomScrollView(
                          controller: scrollController4,
                          slivers: [
                            SliverOverlapInjector(
                                handle: NestedScrollView
                                    .sliverOverlapAbsorberHandleFor(context)),
                            ProfilePosts(
                                uid: uid,
                                ownProfile: viewId != null ? false : true)
                          ]),
                    );
                  }),
                ),
              ],
            ),
          );
        }
      } else {
        final tasksCompletedData = useMemoized(
            () => Database(uid).getCompletedTasksCount(uid),
            [Provider.of<TabProvider>(context).profileUser]);
        final snapshotTasksCompletedData = useFuture(tasksCompletedData);
        final checkinData = useMemoized(
            () => Database(uid).getTrackerCheckInCount(uid),
            [Provider.of<TabProvider>(context).profileUser]);
        final snapshotCheckinData = useFuture(checkinData);

        return NestedScrollView(
          key: viewId != null
              ? Keys.nestedScrollViewKeyProfileOtherPage
              : Keys.nestedScrollViewKeyProfilePage,
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverOverlapAbsorber(
                  handle:
                      NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: MultiSliver(children: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: UserProfileData(
                              data: snapshotUserProfileData.data,
                              uid: uid,
                              nameController: nameController,
                              viewId: viewId,
                              tasksCompleted: snapshotTasksCompletedData.data,
                              checkinData: snapshotCheckinData.data),
                        ),
                      ),
                    ),
                    SliverAppBar(
                      backgroundColor: CustomTheme.dividerBackground,
                      shadowColor: Colors.transparent,
                      automaticallyImplyLeading: false,
                      floating: false,
                      forceElevated: false,
                      centerTitle: true,
                      title: Container(
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          borderRadius: BorderRadius.circular(
                            25.0,
                          ),
                        ),
                        child: TabBar(
                          controller: tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              25.0,
                            ),
                            color: Theme.of(context).primaryColor,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Theme.of(context).primaryColor,
                          tabs: [
                            Tab(
                              child: Icon(Icons.insert_chart_rounded),
                            ),
                            Tab(
                              child: Icon(Icons.track_changes),
                            ),
                            Tab(
                              child: Icon(Icons.dynamic_feed),
                            )
                          ],
                        ),
                      ),
                    ),
                    SliverPinnedHeader(
                      child: PreferredSize(
                        preferredSize: Size(100.w, 3.h),
                        child: AnimatedTextDivider(
                            ['STATS', 'ROUTINES', 'POSTS'], tabIndex),
                      ),
                    ),
                  ]))
            ];
          },
          body: TabBarView(
            physics: CustomTabBarViewScrollPhysics(),
            controller: tabController,
            children: [
              KeepAlivePage(
                child: Builder(builder: (context) {
                  return NestedFix(
                    globalKey: viewId != null
                        ? Keys.nestedScrollViewKeyProfileOtherPage
                        : Keys.nestedScrollViewKeyProfilePage,
                    child: CustomScrollView(
                        controller: scrollController2,
                        slivers: [
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                          RoutinesStats(
                            targetUID: uid,
                          ),
                        ]),
                  );
                }),
              ),
              KeepAlivePage(
                child: Builder(builder: (context) {
                  return NestedFix(
                    globalKey: viewId != null
                        ? Keys.nestedScrollViewKeyProfileOtherPage
                        : Keys.nestedScrollViewKeyProfilePage,
                    child: CustomScrollView(
                        controller: scrollController3,
                        slivers: [
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                    context),
                          ),
                          ProfileToDo(
                              uid: uid,
                              ownProfile: viewId != null ? false : true)
                        ]),
                  );
                }),
              ),
              KeepAlivePage(
                child: Builder(builder: (context) {
                  return NestedFix(
                    globalKey: viewId != null
                        ? Keys.nestedScrollViewKeyProfileOtherPage
                        : Keys.nestedScrollViewKeyProfilePage,
                    child: CustomScrollView(
                        controller: scrollController4,
                        slivers: [
                          SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context)),
                          ProfilePosts(
                              uid: uid,
                              ownProfile: viewId != null ? false : true)
                        ]),
                  );
                }),
              ),
            ],
          ),
        );
      }
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

class ProfileToDo extends HookWidget {
  const ProfileToDo({
    Key? key,
    required this.uid,
    required this.ownProfile,
  }) : super(key: key);

  final String uid;
  final bool ownProfile;

  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(() => Database(uid).getPublicToDo(uid), []);
    final snapshot = useStream(stream);

    if (snapshot.hasData) {
      var docsLength = snapshot.data.docs.length;
      return docsLength > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              var taskDoc = snapshot.data.docs[index];
              var title = taskDoc['title'];
              var taskList = taskDoc['desc'];
              return ToDoTileShare(
                  ownProfile: ownProfile,
                  taskDoc: taskDoc,
                  taskList: taskList,
                  title: title);
            }, childCount: docsLength))
          : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                  child: Text(
                    'No Routines on display',
                    textAlign: TextAlign.center,
                  ));
            }, childCount: 1));
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: SpinKitWanderingCubes(
          color: Theme.of(context).primaryColor,
          size: 75.0,
        ),
      );
    }, childCount: 1));
  }
}

class ProfilePosts extends HookWidget {
  const ProfilePosts({Key? key, required this.uid, required this.ownProfile})
      : super(key: key);

  final uid;
  final ownProfile;

  @override
  Widget build(BuildContext context) {
    final futureUserPosts = useMemoized(
        () => !ownProfile
            ? Database(uid).getUserPostsOtherProfile(uid)
            : Database(uid).getUserPostsOwnProfile(uid),
        [Provider.of<TabProvider>(context).profilePosts]);
    final snapshotUserPosts = useFuture(futureUserPosts);
    final postScrollController = useScrollController();
    postScrollController.addListener(() {
      if (postScrollController.offset >=
              postScrollController.position.maxScrollExtent &&
          !postScrollController.position.outOfRange) {}
    });

    if (snapshotUserPosts.hasData) {
      var docsLength = snapshotUserPosts.data.length;

      return docsLength > 0
          ? SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              return PostListTile(
                postData: snapshotUserPosts.data![index],
                isProfile: true,
              );
            }, childCount: docsLength))
          : SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
              return Padding(
                  padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
                  child: Text(
                    'No Posts :(',
                    textAlign: TextAlign.center,
                  ));
            }, childCount: 1));
      ;
    }

    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: SpinKitWanderingCubes(
          color: Theme.of(context).primaryColor,
          size: 75.0,
        ),
      );
    }, childCount: 1));
  }
}

class UserProfileData extends StatelessWidget {
  const UserProfileData({
    Key? key,
    required this.data,
    required this.uid,
    required this.nameController,
    this.viewId,
    required this.tasksCompleted,
    required this.checkinData,
  }) : super(key: key);

  final data;
  final String uid;
  final nameController;
  final String? viewId;
  final tasksCompleted;
  final checkinData;

  @override
  Widget build(BuildContext context) {
    final _form = GlobalKey<FormState>();
    return Row(
      children: [
        InkWell(
          child: Container(
            width: 10.h,
            height: 10.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 5.0,
              ),
            ),
            child: CircleAvatar(
              foregroundImage: data.data()['image'] != ''
                  ? CachedNetworkImageProvider(data!['image'])
                  : Images.defaultPic.image,
              backgroundColor: Colors.grey,
            ),
          ),
          onTap: viewId != null
              ? () {}
              : data.data()['image'] != ''
                  ? () async =>
                      await changeProfilePic(context, true, data['image'])
                  : () async => await changeProfilePic(context, false),
        ),
        Flexible(
          flex: 7,
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                    onTap: viewId != null
                        ? () {}
                        : () {
                            nameController.text = data!['name'];
                            StyledPopup(
                                    context: context,
                                    title: 'Change Name?',
                                    children: [
                                      Form(
                                        key: _form,
                                        child: TextFormField(
                                          controller: nameController,
                                          decoration: InputDecoration(
                                            labelText: 'Enter the Value',
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.deny(
                                                RegExp('[ ]')),
                                          ],
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Name cannot be empty';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                    textButton: TextButton(
                                        onPressed: () async {
                                          if (_form.currentState!.validate()) {
                                            var newName = nameController.text;
                                            await LoaderWithToast(
                                                    context: context,
                                                    api: Database(uid).editUserName(
                                                        newName,
                                                        Provider.of<UserProvider>(
                                                                context,
                                                                listen: false)
                                                            .user
                                                            .email),
                                                    msg:
                                                        'Name changed successfully',
                                                    isSuccess: true)
                                                .show();
                                            Provider.of<TabProvider>(context,
                                                    listen: false)
                                                .rebuildPage('profileUser');
                                            Provider.of<TabProvider>(context,
                                                    listen: false)
                                                .rebuildPage('profilePosts');
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: Text('Save')))
                                .showPopup();
                          },
                    child:
                        Text(data!['name'], style: TextStyle(fontSize: 20.sp))),
                Text(data!['email'], style: TextStyle(fontSize: 13.sp)),
                Row(
                  children: [
                    Text(
                      'Routines Completed: \t',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$tasksCompleted',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                // Row(
                //   children: [
                //     Text(
                //       'Streak: \t',
                //       textAlign: TextAlign.center,
                //     ),
                //     Text(
                //       '$checkinData',
                //       style: TextStyle(fontWeight: FontWeight.bold),
                //     )
                //   ],
                // )
              ],
            ),
          ),
        ),
        Flexible(flex: 1, child: ProfileAddFriendButton(targetUID: uid))
      ],
    );
  }

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();

    XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);
    return image;
  }

  Future<File?> cropImage(imageFile) async {
    final ImageCropper cropper = ImageCropper();

    File? croppedFile = await cropper.cropImage(
        sourcePath: imageFile.path,
        cropStyle: CropStyle.circle,
        aspectRatioPresets: [CropAspectRatioPreset.square],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ),
        compressQuality: 100);
    if (croppedFile != null) {
      imageFile = croppedFile;
    }
    return imageFile;
  }

  changeProfilePic(context, bool existingPic, [currPicUrl]) async {
    StyledPopup(
      context: context,
      title: existingPic ? 'Change Profile Picture?' : 'Upload Profile Picture',
      children: existingPic
          ? [
              Text('Do you want to change your profile picture to a new one?'),
              ElevatedButton(
                child: Text('Change Profile Picture'),
                onPressed: () async {
                  var image = await pickImage();
                  if (image != null) {
                    Navigator.pop(context);
                    image = await cropImage(image);
                    if (image == null) return;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Upload Profile Picture"),
                            content: CircleAvatar(
                              foregroundImage: FileImage(image),
                              backgroundColor: Colors.grey,
                              radius: 50.w,
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    await LoaderWithToast(
                                            context: context,
                                            api: Database(uid).uploadProfilePic(
                                                image,
                                                hasPic: true,
                                                currPicUrl: currPicUrl),
                                            msg: 'What a glowup',
                                            isSuccess: true)
                                        .show();
                                    Provider.of<TabProvider>(context,
                                            listen: false)
                                        .rebuildPage('profileUser');
                                    Provider.of<TabProvider>(context,
                                            listen: false)
                                        .rebuildPage('profilePosts');
                                    Navigator.pop(context);
                                  },
                                  child: Text("Upload")),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                            ],
                          );
                        });
                  }
                },
              ),
              TextButton(
                child: Text('Remove Profile Picture'),
                onPressed: () {
                  StyledPopup(
                          context: context,
                          title: 'Are you sure?',
                          children: [
                            Text('Your profile picture will be removed.')
                          ],
                          textButton: TextButton(
                              onPressed: () async {
                                await LoaderWithToast(
                                        context: context,
                                        api: Database(uid).removeProfilePic(),
                                        msg: 'The world is less beautiful now',
                                        isSuccess: true)
                                    .show();
                                Provider.of<TabProvider>(context, listen: false)
                                    .rebuildPage('profileUser');
                                Provider.of<TabProvider>(context, listen: false)
                                    .rebuildPage('profilePosts');
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Text('Yes')))
                      .showPopup();
                },
              )
            ]
          : [
              Text('Do you want to upload a profile picture?'),
              ElevatedButton(
                child: Text('Upload Profile Picture'),
                onPressed: () async {
                  var image = await pickImage();
                  if (image != null) {
                    Navigator.pop(context);
                    image = await cropImage(image);
                    if (image == null) return;
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Upload Profile Picture"),
                            content: Image(image: FileImage(image)),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    await LoaderWithToast(
                                            context: context,
                                            api: Database(uid)
                                                .uploadProfilePic(image),
                                            msg: '*Inserts cheesy pickup line*',
                                            isSuccess: true)
                                        .show();
                                    Provider.of<TabProvider>(context,
                                            listen: false)
                                        .rebuildPage('profileUser');
                                    Provider.of<TabProvider>(context,
                                            listen: false)
                                        .rebuildPage('profilePosts');
                                    Navigator.pop(context);
                                  },
                                  child: Text("Upload")),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("Cancel"),
                              ),
                            ],
                          );
                        });
                  }
                },
              ),
            ],
    ).showPopup();
  }
}

class ProfileAddFriendButton extends HookWidget {
  const ProfileAddFriendButton({
    Key? key,
    required this.targetUID,
  }) : super(key: key);

  final String targetUID;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    if (targetUID == uid) {
      return Container();
    }
    final future = useMemoized(() => Database(uid).checkIfFriend(targetUID),
        [Provider.of<TabProvider>(context).friendButton]);
    final snapshot = useFuture(future);
    if (snapshot.hasData) {
      print(snapshot.data);
      if (snapshot.data == 4) {
        return IconButton(
          onPressed: () async {
            await LoaderWithToast(
                    context: context,
                    api: Database(uid).sendFriendReq(targetUID).then((value) {
                      Provider.of<TabProvider>(context, listen: false)
                          .rebuildPage('friendButton');
                    }),
                    msg: 'Sent',
                    isSuccess: true)
                .show();
          },
          icon: Icon(Icons.person_add),
        );
      }
      if (snapshot.data == 0) {
        return IconButton(
            onPressed: () {},
            icon: Icon(Icons.pending, color: CustomTheme.inactiveIcon));
      } else if (snapshot.data == 2) {
        return IconButton(
            onPressed: () {},
            icon: Icon(Icons.handshake, color: CustomTheme.activeIcon));
      } else if (snapshot.data == 1) {
        return Column(
          children: [
            IconButton(
                onPressed: () async {
                  await LoaderWithToast(
                          context: context,
                          api: Database(uid)
                              .acceptFriendReq(targetUID)
                              .then((value) {
                            Provider.of<TabProvider>(context, listen: false)
                                .rebuildPage('friendButton');
                            Provider.of<TabProvider>(context, listen: false)
                                .rebuildPage('friendPage');
                          }),
                          msg: 'You are now friends',
                          isSuccess: true)
                      .show();
                },
                icon: Icon(
                  Icons.check_circle_outline_rounded,
                  color: CustomTheme.activeButton,
                )),
            IconButton(
                onPressed: () async {
                  await Database(uid).declineFriendReq(targetUID).then((value) {
                    Provider.of<TabProvider>(context, listen: false)
                        .rebuildPage('friendButton');
                    Provider.of<TabProvider>(context, listen: false)
                        .rebuildPage('friendPage');
                  });
                },
                icon:
                    Icon(Icons.cancel_outlined, color: CustomTheme.redButton)),
          ],
        );
      }
    }
    return Container();
  }
}
