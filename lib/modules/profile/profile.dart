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
import 'package:shizen_app/utils/useAutomaticKeepAliveClientMixin.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shimmer/shimmer.dart';

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

    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            width: double.infinity,
            height: 15.h,
            color: Color(0xff80ceff),
            child: snapshotUserProfileData.hasData
                ? UserProfileData(
                    data: snapshotUserProfileData.data,
                    uid: uid,
                    nameController: nameController,
                    viewId: viewId,
                  )
                : Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Row(
                      children: [
                        Container(
                          width: 25.w,
                          height: 25.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 1),
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 50.w,
                                    height: 14.sp,
                                    color: Colors.white,
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 50.w,
                                    height: 14.sp,
                                    color: Colors.white,
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 50.w,
                                    height: 14.sp,
                                    color: Colors.white,
                                  ),
                                ])),
                      ],
                    ),
                  )),
        Container(
          width: 80.w,
          child: TabBar(
            controller: tabController,
            // give the indicator a decoration (color and border radius)
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(
                25.0,
              ),
              color: Colors.blueGrey[700],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.blueGrey[700],
            tabs: [
              Tab(
                child: Icon(Icons.list),
              ),
              Tab(
                child: Icon(Icons.repeat),
              ),
              Tab(
                child: Icon(Icons.feed),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
        ),
        Expanded(
          child: TabBarView(controller: tabController, children: <Widget>[
            KeepAlivePage(child: ProfileToDo(uid: uid)),
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
  }) : super(key: key);

  final String uid;

  @override
  Widget build(BuildContext context) {
    final stream = useMemoized(() => Database(uid).getPublicToDo(uid), []);
    final snapshot = useStream(stream);
    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Row(children: <Widget>[
              Expanded(
                child: new Container(
                    margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                    child: Divider(
                      color: Colors.black,
                      height: 5.h,
                    )),
              ),
              Text(
                "TO DO TASKS",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: new Container(
                    margin: const EdgeInsets.only(left: 10.0, right: 0.0),
                    child: Divider(
                      color: Colors.black,
                      height: 5.h,
                    )),
              ),
            ]),
          ),
          Container(
              child: !snapshot.hasData
                  ? SpinKitWanderingCubes(
                      color: Colors.blueGrey,
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

                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 15, 10, 15),
                              child: InkWell(
                                onTap: () {
                                  List task = [];

                                  for (var i = 0; i < taskList.length; i++) {
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
                                          AddToDoTask(editParams: {
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
                                      }, isEdit: true),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          child: Text(title,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline1),
                                        ))),
                                    ConstrainedBox(
                                        constraints: BoxConstraints(
                                            minHeight: 5.h, minWidth: 100.w),
                                        child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.amber[200],
                                              border: Border.all(
                                                  color: Colors.amber,
                                                  width: 5),
                                              borderRadius: BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(5),
                                                  bottomRight:
                                                      Radius.circular(5),
                                                  topRight: Radius.circular(5)),
                                            ),
                                            child: ListView.builder(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                shrinkWrap: true,
                                                itemCount: taskList.length,
                                                itemBuilder: (context, index) {
                                                  return SizedBox(
                                                    height: 5.h,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color: taskList[index]
                                                                  ['status']
                                                              ? Colors
                                                                  .lightGreen[400]
                                                              : null),
                                                      child: Row(
                                                        children: [
                                                          Checkbox(
                                                            shape:
                                                                CircleBorder(),
                                                            activeColor: Colors
                                                                    .lightGreen[
                                                                700],
                                                            value:
                                                                taskList[index]
                                                                    ['status'],
                                                            onChanged:
                                                                (value) async {},
                                                          ),
                                                          Text(
                                                              taskList[index]
                                                                  ['task'],
                                                              softWrap: false,
                                                              style: TextStyle(
                                                                  decoration: taskList[
                                                                              index]
                                                                          [
                                                                          'status']
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
                            );
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

    final future =
        useMemoized(() => Database(uid).getHighlightTracker(uid), []);
    final snapshot = useFuture(future);

    if (snapshot.connectionState == ConnectionState.done) {
      var task;
      if (snapshot.data != null) {
        task = snapshot.data;
      }
      return SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Row(children: <Widget>[
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                      child: Divider(
                        color: Colors.black,
                        height: 5.h,
                      )),
                ),
                Text(
                  "DAILY TRACKER",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: new Container(
                      margin: const EdgeInsets.only(left: 10.0, right: 0.0),
                      child: Divider(
                        color: Colors.black,
                        height: 5.h,
                      )),
                ),
              ]),
            ),
            ownProfile
                ? IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileSelectTracker(),
                          ));
                    },
                    icon: Icon(Icons.edit),
                  )
                : Container(),
            task != null
                ? Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueGrey, width: 5),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.lightBlue[50]),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(task['title'],
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text(
                                    '${DateTime.now().difference((task['currStreakDate'] as Timestamp).toDate()).inDays + 1}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Icon(Icons.park, color: Colors.lightGreen[700])
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Next Milestone',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(task['milestones'].isEmpty
                                      ? 'No milestone'
                                      : 'Day ${task['milestones'][0]['day']} - ${task['milestones'][0]['reward']}'),
                                ],
                              ),
                              // ElevatedButton(
                              //   onPressed: () {
                              //     StyledPopup(
                              //             context: context,
                              //             title: 'Milestones',
                              //             children: [
                              //               StatefulBuilder(
                              //                   builder: (context, _setState) {
                              //                 return Column(
                              //                   children: [
                              //                     task['milestones'].length > 0
                              //                         ? ListView.builder(
                              //                             physics:
                              //                                 NeverScrollableScrollPhysics(),
                              //                             shrinkWrap: true,
                              //                             itemCount:
                              //                                 task['milestones']
                              //                                     .length,
                              //                             itemBuilder:
                              //                                 (context, index) {
                              //                               return MilestonePopupTile(
                              //                                 milestone: task[
                              //                                         'milestones']
                              //                                     [index],
                              //                                 index: index,
                              //                                 minDay: DateTime
                              //                                             .now()
                              //                                         .difference((task['startDate']
                              //                                                 as Timestamp)
                              //                                             .toDate())
                              //                                         .inDays +
                              //                                     1,
                              //                               );
                              //                             })
                              //                         : Text(
                              //                             'You dont have any milestones.'),
                              //                   ],
                              //                 );
                              //               }),
                              //             ],
                              //             cancelText: 'Done')
                              //         .showPopup();
                              //   },
                              //   child: Icon(Icons.flag),
                              //   style: ElevatedButton.styleFrom(
                              //       shape: CircleBorder(),
                              //       primary: Colors.amber),
                              // ),
                            ],
                          ),
                        ),
                      ],
                    ))
                : Center(child: Text('No highlighted tracker'))
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Row(children: <Widget>[
              Expanded(
                child: new Container(
                    margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                    child: Divider(
                      color: Colors.black,
                      height: 5.h,
                    )),
              ),
              Text(
                "DAILY TRACKER",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: new Container(
                    margin: const EdgeInsets.only(left: 10.0, right: 0.0),
                    child: Divider(
                      color: Colors.black,
                      height: 5.h,
                    )),
              ),
            ]),
          ),
          SpinKitWanderingCubes(
            color: Colors.blueGrey,
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
    final future = useMemoized(() => Database(uid).getTrackerTasks());
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
                    Navigator.pop(context);
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('Please select at least one task.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
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
                            borderRadius: BorderRadius.circular(10),
                            color: selectedIndex.value == index
                                ? Colors.lightBlueAccent[100]
                                : Colors.transparent,
                          ),
                          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                          child: Transform.scale(
                              scale: selectedIndex.value == index ? 0.9 : 1,
                              child: Text('${task.id}'))));
                },
              )
            : SpinKitWanderingCubes(color: Colors.blueGrey, size: 75));
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
          Align(
            alignment: Alignment.topCenter,
            child: Row(children: <Widget>[
              Expanded(
                child: new Container(
                    margin: const EdgeInsets.only(left: 0.0, right: 10.0),
                    child: Divider(
                      color: Colors.black,
                      height: 5.h,
                    )),
              ),
              Text(
                "POSTS",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: new Container(
                    margin: const EdgeInsets.only(left: 10.0, right: 0.0),
                    child: Divider(
                      color: Colors.black,
                      height: 5.h,
                    )),
              ),
            ]),
          ),
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
  }) : super(key: key);

  final data;
  final String uid;
  final nameController;
  final String? viewId;

  @override
  Widget build(BuildContext context) {
    final _form = GlobalKey<FormState>();
    return Row(
      children: [
        Container(
          width: 25.w,
          height: 25.w,
          child: data.data()['image'] != ''
              ? InkWell(
                  child: CircleAvatar(
                    foregroundImage: CachedNetworkImageProvider(data!['image']),
                    backgroundColor: Colors.grey,
                    radius: 3.h,
                  ),
                  onTap: viewId != null
                      ? () {}
                      : () async =>
                          await changeProfilePic(context, true, data['image']),
                )
              : InkWell(
                  child: CircleAvatar(
                    foregroundImage: Images.defaultPic.image,
                    backgroundColor: Colors.grey,
                    radius: 3.h,
                  ),
                  onTap: viewId != null
                      ? () {}
                      : () async {
                          await changeProfilePic(context, false);
                        },
                ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Column(
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
                      Text(data!['name'], style: TextStyle(fontSize: 25.sp))),
              Text(data!['email'], style: TextStyle(fontSize: 15.sp)),
              Text(data.data().containsKey('bio')
                  ? "Nice"
                  : "I do not have a bio..."),
            ],
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
