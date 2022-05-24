import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shizen_app/modules/community/community.dart';
import 'package:shizen_app/modules/tasks/addtodo.dart';
import 'package:shizen_app/modules/tasks/todoTab.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shizen_app/utils/dateTimeAgo.dart';
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/divider.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shizen_app/widgets/todotile.dart';

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
    final tasksCompletedData = useMemoized(
        () => Database(uid).getCompletedTasksCount(uid),
        [Provider.of<TabProvider>(context).profileUser]);
    final snapshotTasksCompletedData = useFuture(tasksCompletedData);
    final checkinData = useMemoized(
        () => Database(uid).getTrackerCheckInCount(uid),
        [Provider.of<TabProvider>(context).profileUser]);
    final snapshotCheckinData = useFuture(checkinData);
    final tabController = useTabController(
      initialLength: 3,
      initialIndex: 0,
    );

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(20),
            color: Color.fromARGB(255, 186, 195, 201),
            child: snapshotUserProfileData.hasData &&
                    snapshotTasksCompletedData.hasData
                ? UserProfileData(
                    data: snapshotUserProfileData.data,
                    uid: uid,
                    nameController: nameController,
                    viewId: viewId,
                    tasksCompleted: snapshotTasksCompletedData.data,
                    checkinData: snapshotCheckinData.data)
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Row(
                      children: [
                        Container(
                          width: 10.h,
                          height: 10.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 1),
                            color: Colors.white,
                          ),
                        ),
                        Flexible(
                          child: Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 14.sp,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6)),
                                    Container(
                                      height: 14.sp,
                                      color: Colors.white,
                                    ),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6)),
                                    Container(
                                      height: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ])),
                        ),
                      ],
                    ),
                  )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
        ),
        Container(
          width: 80.w,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: BorderRadius.circular(
              25.0,
            ),
          ),
          child: TabBar(
            controller: tabController,
            // give the indicator a decoration (color and border radius)
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
                child: Icon(Icons.task_alt),
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
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: <Widget>[
            KeepAlivePage(
                child: ProfileToDo(
                    uid: uid, ownProfile: viewId != null ? false : true)),
            KeepAlivePage(
                child: ProfileTracker(
                    uid: uid, ownProfile: viewId != null ? false : true)),
            KeepAlivePage(
              child: ProfilePosts(
                  uid: uid, ownProfile: viewId != null ? false : true),
            )
          ]),
        ),
      ],
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
    return SingleChildScrollView(
      child: Column(
        children: [
          TextDivider('TO DO TASKS'),
          Container(
              child: !snapshot.hasData
                  ? SpinKitWanderingCubes(
                      color: Theme.of(context).primaryColor,
                      size: 75.0,
                    )
                  : snapshot.data.docs.length > 0
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: ((context, index) {
                            var taskDoc = snapshot.data.docs[index];
                            var title = taskDoc['title'];
                            var taskList = taskDoc['desc'];

                            return ToDoTileShare(
                                ownProfile: ownProfile,
                                taskDoc: taskDoc,
                                taskList: taskList,
                                title: title);
                          }))
                      : Center(
                          child: Text('No To Do tasks to show',
                              textAlign: TextAlign.center))),
        ],
      ),
    );
  }
}

class ProfileTracker extends HookWidget {
  const ProfileTracker({Key? key, required this.uid, required this.ownProfile})
      : super(key: key);

  final uid;
  final ownProfile;

  @override
  Widget build(BuildContext context) {
    // Add a field in user called highlightTracker or something
    // Add button to change the highlightTracker value.
    // Open page to select tracker when button is clicked.
    // If highlightTracker is null, show no tracker.
    // Else, show the tracker data.

    final future = useMemoized(() => Database(uid).getHighlightTracker(uid),
        [Provider.of<TabProvider>(context).profileTracker]);
    final snapshot = useFuture(future);

    if (snapshot.connectionState == ConnectionState.done) {
      var task;
      var taskId;
      if (snapshot.data != null) {
        task = snapshot.data[0];
        taskId = snapshot.data[1];
      }
      return SingleChildScrollView(
        child: Column(
          children: [
            TextDivider('DAILY TRACKER'),
            ownProfile
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileSelectTracker(),
                                ));
                          },
                          child: Row(
                            children: [Icon(Icons.edit), Text('Edit')],
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                CustomTheme.activeButton),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                            ),
                          ),
                        ),
                      ),
                      task != null
                          ? Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            content: Text(
                                                'Do you want to stop displaying this tracker in your profile?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () async {
                                                    await Database(uid)
                                                        .setHighlightTracker(
                                                            null);
                                                    Provider.of<TabProvider>(
                                                            context,
                                                            listen: false)
                                                        .rebuildPage(
                                                            'profileTracker');
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('Remove')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text('Cancel')),
                                            ],
                                          ));
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_circle),
                                    Text('Remove')
                                  ],
                                ),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      CustomTheme.redButton),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container()
                    ],
                  )
                : Container(),
            task != null
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                    child: ProfileSelectTrackerTile(task: task, taskId: taskId),
                  )
                : Center(child: Text('No highlighted tracker'))
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          TextDivider('DAILY TRACKER'),
          SpinKitWanderingCubes(
            color: Theme.of(context).primaryColor,
            size: 75.0,
          ),
        ],
      ),
    );
  }
}

class ProfileSelectTracker extends HookWidget {
  const ProfileSelectTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final selectedIndex = useState(-1);
    final future = useMemoized(() => Database(uid).getTrackerTasks(),
        [Provider.of<TabProvider>(context).profileTracker]);
    final snapshot = useFuture(future);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Select Tracker'),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () async {
                  if (selectedIndex.value != -1) {
                    await Database(uid).setHighlightTracker(
                        snapshot.data.docs[selectedIndex.value].id);
                    Provider.of<TabProvider>(context, listen: false)
                        .rebuildPage('profileTracker');
                    Navigator.pop(context);
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('Please select at least one task.'),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'))
                              ],
                            ));
                  }
                },
                child: Text('OK', style: TextStyle(color: Colors.white)))
          ],
        ),
        body: snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  final task = snapshot.data.docs[index];
                  return InkWell(
                      onTap: () {
                        selectedIndex.value = index;
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            color: selectedIndex.value == index
                                ? CustomTheme.activeIcon
                                : Colors.transparent,
                          ),
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          child: Transform.scale(
                              scale: selectedIndex.value == index ? 0.9 : 1,
                              child: ProfileSelectTrackerTile(
                                  task: task, taskId: task.id))));
                },
              )
            : SpinKitWanderingCubes(
                color: Theme.of(context).primaryColor, size: 75));
  }
}

class ProfileSelectTrackerTile extends HookWidget {
  const ProfileSelectTrackerTile({
    Key? key,
    required this.task,
    required this.taskId,
  }) : super(key: key);

  final task;
  final taskId;

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(() => Database(uid).getLatestCheckInData(taskId),
        [Provider.of<TabProvider>(context).profileTracker]);
    final snapshot = useFuture(future);
    return Container(
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
                Text(task['title'],
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                        color: Theme.of(context).primaryColor.withAlpha(200))),
                Row(
                  children: [
                    Text(
                        '${DateTime.now().difference((task['currStreakDate'] as Timestamp).toDate()).inDays + 1}',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Next Milestone',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(task['milestones'].isEmpty
                          ? '-'
                          : 'Day ${task['milestones'][0]['day']} - ${task['milestones'][0]['reward']}'),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      StyledPopup(
                              context: context,
                              title: 'Milestones',
                              children: [
                                StatefulBuilder(builder: (context, _setState) {
                                  return Column(
                                    children: [
                                      task['milestones'].length > 0
                                          ? ListView.builder(
                                              physics:
                                                  NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount:
                                                  task['milestones'].length,
                                              itemBuilder: (context, index) {
                                                var milestone =
                                                    task['milestones'][index];
                                                var minDay = DateTime.now()
                                                        .difference((task[
                                                                    'startDate']
                                                                as Timestamp)
                                                            .toDate())
                                                        .inDays +
                                                    1;
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 20, 0, 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Container(
                                                              width: 30.w,
                                                              height: 5.h,
                                                              decoration: BoxDecoration(
                                                                  color: minDay <
                                                                          milestone[
                                                                              'day']
                                                                      ? Colors
                                                                          .amber
                                                                      : Colors
                                                                          .lightGreen,
                                                                  borderRadius: BorderRadius.only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15))),
                                                              child: Center(
                                                                  child: Text(
                                                                      'Day ${milestone['day']}'))),
                                                        ],
                                                      ),
                                                      Container(
                                                          width: 100.w,
                                                          height: 7.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: minDay <
                                                                    milestone[
                                                                        'day']
                                                                ? Colors
                                                                    .amber[200]
                                                                : Colors.lightGreen[
                                                                    200],
                                                            border: Border.all(
                                                                color: minDay <
                                                                        milestone[
                                                                            'day']
                                                                    ? Colors
                                                                        .amber
                                                                    : Colors
                                                                        .lightGreen,
                                                                width: 5),
                                                            borderRadius: BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        5),
                                                                bottomRight:
                                                                    Radius
                                                                        .circular(
                                                                            5),
                                                                topRight: Radius
                                                                    .circular(
                                                                        5)),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    20,
                                                                    0,
                                                                    20,
                                                                    0),
                                                            child: Align(
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                    milestone[
                                                                        'reward'])),
                                                          )),
                                                    ],
                                                  ),
                                                );
                                              })
                                          : Text('-'),
                                    ],
                                  );
                                }),
                              ],
                              cancelText: 'Done')
                          .showPopup();
                    },
                    child: Icon(Icons.flag_rounded),
                    style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        primary: Color.fromARGB(255, 252, 212, 93)),
                  ),
                ],
              ),
            ),
            Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last checked-in',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  snapshot.hasData
                      ? snapshot.data.docs.length != 0
                          ? Text((snapshot.data.docs[0]['dateCreated']
                                  as Timestamp)
                              .toDate()
                              .timeAgo())
                          : Text('-')
                      : Text('-')
                ],
              ),
            ),
          ],
        ));
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
          !postScrollController.position.outOfRange) {
        print("at the end of list");
      }
    });
    return SingleChildScrollView(
      child: Column(
        children: [
          TextDivider('POSTS'),
          snapshotUserPosts.hasData
              ? snapshotUserPosts.data!.length > 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      controller: postScrollController,
                      shrinkWrap: true,
                      itemCount: snapshotUserPosts.data!.length,
                      itemBuilder: (context, index) {
                        return PostListTile(
                          postData: snapshotUserPosts.data![index],
                          isProfile: true,
                        );
                      })
                  : Text('No Posts :(')
              : Shimmer.fromColors(
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
                ),
        ],
      ),
    );
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
                                                    api: Database(uid)
                                                        .editUserName(newName),
                                                    msg: 'New name who dis',
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
                      'Tasks Completed: \t',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$tasksCompleted',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Check-ins: \t',
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$checkinData',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
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
