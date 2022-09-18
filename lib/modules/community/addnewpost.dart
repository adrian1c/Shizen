import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:shizen_app/widgets/dropdown.dart';
import 'package:shizen_app/models/communityPost.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/widgets/field.dart';

class AddNewPost extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final ValueNotifier isValid = useValueNotifier(false);
    final TextEditingController postDescController = useTextEditingController();
    final List<TextEditingController> hashtagController = [
      useTextEditingController(),
      useTextEditingController(),
      useTextEditingController(),
    ];
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final ValueNotifier attachment = useState(null);
    final ValueNotifier<String?> attachmentType = useState(null);
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Post"),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                var postData = {
                  'desc': postDescController.text,
                  'attachment': attachment.value,
                  'attachmentType': attachmentType.value,
                  'hashtags': [
                    hashtagController[0].text,
                    hashtagController[1].text,
                    hashtagController[2].text
                  ]..removeWhere((item) => item == ''),
                  'name': Provider.of<UserProvider>(context, listen: false)
                      .user
                      .name,
                  'email': Provider.of<UserProvider>(context, listen: false)
                      .user
                      .email,
                  'image': Provider.of<UserProvider>(context, listen: false)
                      .user
                      .image
                };
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviewPage(postData: postData),
                    ));
              },
              child: Text(
                'PREVIEW',
                style: TextStyle(color: Theme.of(context).backgroundColor),
              ),
            ),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Creating New Post...'),
                  ],
                ),
                PostDescField(
                    isValid: isValid, postDescController: postDescController),
                Ink(
                  child: InkWell(
                    child: Container(
                      constraints: BoxConstraints(minHeight: 10.h),
                      decoration: BoxDecoration(
                          color: Theme.of(context).backgroundColor,
                          border:
                              Border.all(color: Colors.grey[600]!, width: 1),
                          borderRadius: BorderRadius.circular(5)),
                      child: attachment.value == null
                          ? Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: const Icon(
                                      Icons.attachment_sharp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text("Attach Image / Routine",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : attachmentType.value == 'image'
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Image'),
                                    Image(
                                        width: 100.w,
                                        image: FileImage(attachment.value!),
                                        fit: BoxFit.fitWidth),
                                  ],
                                )
                              : attachmentType.value == 'tracker'
                                  ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 15, 10, 15),
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: Theme.of(context)
                                                .backgroundColor,
                                            boxShadow: CustomTheme.boxShadow),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(attachment.value['title'],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headline4
                                                        ?.copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withAlpha(
                                                                    200))),
                                                Row(
                                                  children: [
                                                    Text(
                                                        '${attachment.value['currStreak']}',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Icon(
                                                        Icons
                                                            .check_circle_rounded,
                                                        color: Color.fromARGB(
                                                            255, 147, 182, 117))
                                                  ],
                                                )
                                              ],
                                            ),
                                            Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 5)),
                                            Divider(),
                                            Text(attachment.value['note'])
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('Routine'),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            color: CustomTheme
                                                .attachmentBackground,
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 15, 15, 15),
                                            child: Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Theme.of(context)
                                                      .backgroundColor,
                                                  boxShadow:
                                                      CustomTheme.boxShadow),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          attachment
                                                              .value['title'],
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headline4
                                                              ?.copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withAlpha(
                                                                          200))),
                                                      Row(
                                                        children: [
                                                          Text(
                                                              '${attachment.value['timesCompleted']}',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Icon(
                                                              Icons
                                                                  .park_rounded,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      147,
                                                                      182,
                                                                      117))
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 5)),
                                                  Divider(),
                                                  ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: attachment
                                                          .value['taskList']
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Container(
                                                          constraints:
                                                              BoxConstraints(
                                                                  minHeight:
                                                                      5.h),
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      15,
                                                                  vertical: 10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: attachment.value[
                                                                            'taskList']
                                                                        [index]
                                                                    ['status']
                                                                ? CustomTheme
                                                                    .completeColor
                                                                : Theme.of(
                                                                        context)
                                                                    .backgroundColor,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              AbsorbPointer(
                                                                child: SizedBox(
                                                                  width: 20,
                                                                  height: 20,
                                                                  child:
                                                                      Checkbox(
                                                                    shape:
                                                                        CircleBorder(),
                                                                    activeColor:
                                                                        Theme.of(context)
                                                                            .backgroundColor,
                                                                    checkColor:
                                                                        Colors.lightGreen[
                                                                            700],
                                                                    value: attachment.value['taskList']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'status'],
                                                                    onChanged:
                                                                        (value) {},
                                                                  ),
                                                                ),
                                                              ),
                                                              Flexible(
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          10.0),
                                                                  child: Text(
                                                                      attachment.value['taskList']
                                                                              [
                                                                              index]
                                                                          [
                                                                          'task'],
                                                                      textAlign:
                                                                          TextAlign
                                                                              .justify,
                                                                      style: TextStyle(
                                                                          decoration: attachment.value['taskList'][index]['status']
                                                                              ? TextDecoration.lineThrough
                                                                              : null)),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                    ),
                    onTap: () {
                      showAttach(context, attachment, attachmentType);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 20, 50, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Hashtag (max 3)"),
                      Container(
                        child: ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: hashtagController.length,
                            itemBuilder: (context, index) {
                              return HashtagField(
                                  hashtagController: hashtagController[index]);
                            }),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CreateButton(
                        onPressed: () async {
                          final List<String> hashtags = [
                            hashtagController[0].text,
                            hashtagController[1].text,
                            hashtagController[2].text,
                          ];
                          hashtags.removeWhere((item) => item == '');
                          Map<String, dynamic> newPost = CommunityPost(
                                  uid,
                                  postDescController.text,
                                  hashtags,
                                  attachment.value,
                                  attachmentType.value)
                              .toJson();
                          await LoaderWithToast(
                                  context: context,
                                  api: Database(uid).addNewPost(
                                      newPost, attachmentType.value),
                                  msg: 'Posted',
                                  isSuccess: true)
                              .show();
                          Provider.of<TabProvider>(context, listen: false)
                              .rebuildPage('profilePosts');
                          Provider.of<TabProvider>(context, listen: false)
                              .rebuildPage('community');
                          Navigator.of(context).pop();
                        },
                        isValid: isValid,
                        buttonLabel: 'Post',
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const CancelButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future pickImage(source) async {
    final ImagePicker picker = ImagePicker();

    XFile? image = await picker.pickImage(
      source: source == 'gallery' ? ImageSource.gallery : ImageSource.camera,
    );
    return image;
  }

  Future<File?> cropImage(imageFile) async {
    final ImageCropper cropper = ImageCropper();

    File? croppedFile = await cropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: CustomTheme.cropImageHeader,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          title: 'Crop Image',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
    }
    return imageFile;
  }

  showAttach(context, attachment, attachmentType) {
    showDialog(
        context: context,
        builder: (context1) {
          return AlertDialog(
            title: Text("Add an attachment"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Image'),
                  ),
                  SizedBox(
                    width: 70.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 30.w,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Icon(Icons.photo_library),
                                  Text('Gallery')
                                ],
                              ),
                            )),
                            onTap: () async {
                              var image = await pickImage('gallery');
                              if (image != null) {
                                Navigator.pop(context1);
                                image = await cropImage(image);
                                if (image == null) return;
                                showDialog(
                                    context: context,
                                    builder: (context2) {
                                      return AlertDialog(
                                        title: Text("Confirm Picture"),
                                        content: Image(image: FileImage(image)),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context2);
                                                attachment.value = image;
                                                attachmentType.value = 'image';
                                              },
                                              child: Text("Yes")),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context2);
                                            },
                                            child: Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                          ),
                        ),
                        Container(
                          width: 30.w,
                          decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(10)),
                          child: InkWell(
                            child: Center(
                                child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Icon(Icons.camera_alt),
                                  Text('Camera')
                                ],
                              ),
                            )),
                            onTap: () async {
                              var image = await pickImage('camera');
                              if (image != null) {
                                Navigator.pop(context1);
                                image = await cropImage(image);
                                if (image == null) return;
                                showDialog(
                                    context: context,
                                    builder: (context2) {
                                      return AlertDialog(
                                        title: Text("Confirm Picture"),
                                        content: Image(image: FileImage(image)),
                                        actions: [
                                          TextButton(
                                              onPressed: () async {
                                                Navigator.pop(context2);
                                                attachment.value = image;
                                                attachmentType.value = 'image';
                                              },
                                              child: Text("Yes")),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context2);
                                            },
                                            child: Text("Cancel"),
                                          ),
                                        ],
                                      );
                                    });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Routine'),
                  ),
                  SizedBox(
                    width: 70.w,
                    height: 7.h,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                          child: Center(child: Text("Attach Routine")),
                          onTap: () async {
                            Navigator.pop(context);
                            var returnValue = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SelectTaskPage(),
                                ));
                            if (returnValue != null) {
                              attachment.value = returnValue;
                              attachmentType.value = 'task';
                            }
                          }),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
                  Divider(),
                  if (attachment.value != null)
                    Center(
                      child: TextButton(
                        child: Text(
                          'Remove Attachment',
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          attachment.value = null;
                          attachmentType.value = null;
                          Navigator.pop(context);
                        },
                      ),
                    )
                ],
              ),
            ),
            actions: [
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
}

class PostDescField extends StatelessWidget {
  const PostDescField(
      {Key? key, required this.isValid, required this.postDescController})
      : super(key: key);

  final ValueNotifier isValid;
  final TextEditingController postDescController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: TextFormField(
          controller: postDescController,
          style: TextStyle(color: Color(0xff58865C)),
          keyboardType: TextInputType.multiline,
          textCapitalization: TextCapitalization.sentences,
          maxLines: 10,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: "Description",
            contentPadding: EdgeInsets.all(10.0),
            labelStyle: CustomTheme.lightTheme.textTheme.bodyText2,
            border: OutlineInputBorder(
              borderRadius: new BorderRadius.circular(10.0),
              borderSide: new BorderSide(),
            ),
          ),
          onChanged: (value) =>
              value != '' ? isValid.value = true : isValid.value = false,
          validator: (value) {
            if (value == null) {
              return "You have not filled anything in";
            } else {
              return null;
            }
          }),
    );
  }
}

class HashtagField extends StatelessWidget {
  const HashtagField({Key? key, required this.hashtagController})
      : super(key: key);

  final TextEditingController hashtagController;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: hashtagController,
      maxLength: 20,
      decoration: InputDecoration(
        labelText: '#',
        hintText: 'Hashtag',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        isDense: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))
      ],
      onChanged: (value) {},
    );
  }
}

class SelectTaskPage extends HookWidget {
  const SelectTaskPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).user.uid;
    final selectedIndex = useState(-1);
    final selectedTaskMap = useState({});
    final future = useMemoized(() => Database(uid).getRoutines());
    final snapshot = useFuture(future);
    return Scaffold(
        appBar: AppBar(
            title: const Text("Select Routine"),
            centerTitle: true,
            actions: [
              TextButton(
                  onPressed: () {
                    if (selectedIndex.value != -1) {
                      Navigator.pop(context, selectedTaskMap.value);
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content:
                                    Text('Please select at least one routine.'),
                                actions: [
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('OK'))
                                ],
                              ));
                    }
                  },
                  child: Text('OK', style: TextStyle(color: Colors.white)))
            ]),
        body: snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  final task = snapshot.data.docs[index];
                  final tid = task.id;
                  final title = task['title'];
                  final taskList = task['desc'];
                  final timesCompleted = task['timesCompleted'];
                  return InkWell(
                    onTap: () {
                      selectedIndex.value = index;
                      selectedTaskMap.value = {
                        'title': title,
                        'taskList': taskList,
                        'timesCompleted': timesCompleted,
                        'tid': tid,
                      };
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
                        child: SelectTaskRoutine(
                            title: title,
                            taskList: taskList,
                            timesCompleted: timesCompleted),
                      ),
                    ),
                  );
                })
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: SpinKitWanderingCubes(
                  color: Theme.of(context).primaryColor,
                  size: 75.0,
                ),
              ));
  }
}

class SelectTaskRoutine extends StatelessWidget {
  const SelectTaskRoutine({
    Key? key,
    required this.title,
    required this.taskList,
    required this.timesCompleted,
  }) : super(key: key);

  final title;
  final taskList;
  final timesCompleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
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
                Text(title,
                    style: Theme.of(context).textTheme.headline4?.copyWith(
                        color: Theme.of(context).primaryColor.withAlpha(200))),
                Row(
                  children: [
                    Text('$timesCompleted',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Icon(Icons.check_circle_rounded,
                        color: Color.fromARGB(255, 147, 182, 117))
                  ],
                )
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 5)),
            Divider(),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: taskList.length,
                itemBuilder: (context, index) {
                  return Container(
                    constraints: BoxConstraints(minHeight: 5.h),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      color: taskList[index]['status']
                          ? CustomTheme.completeColor
                          : Theme.of(context).backgroundColor,
                    ),
                    child: Row(
                      children: [
                        AbsorbPointer(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: Checkbox(
                              shape: CircleBorder(),
                              activeColor: Theme.of(context).backgroundColor,
                              checkColor: Colors.lightGreen[700],
                              value: taskList[index]['status'],
                              onChanged: (value) {},
                            ),
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Text(taskList[index]['task'],
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    decoration: taskList[index]['status']
                                        ? TextDecoration.lineThrough
                                        : null)),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}

// class SelectTrackerPage extends HookWidget {
//   const SelectTrackerPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final String uid = Provider.of<UserProvider>(context).user.uid;
//     final selectedIndex = useState(-1);
//     final selectedTaskMap = useState({});
//     final future = useMemoized(() => Database(uid).getAllTrackers());
//     final snapshot = useFuture(future);
//     return Scaffold(
//         appBar: AppBar(
//             title: const Text("SELECT TASK"),
//             centerTitle: true,
//             actions: [
//               TextButton(
//                   onPressed: () {
//                     if (selectedIndex.value != -1) {
//                       Navigator.pop(context, selectedTaskMap.value);
//                     } else {
//                       showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                                 content:
//                                     Text('Please select at least one tracker.'),
//                                 actions: [
//                                   TextButton(
//                                       onPressed: () => Navigator.pop(context),
//                                       child: Text('OK'))
//                                 ],
//                               ));
//                     }
//                   },
//                   child: Text('OK', style: TextStyle(color: Colors.white)))
//             ]),
//         body: snapshot.hasData
//             ? ListView.builder(
//                 itemCount: snapshot.data.docs.length,
//                 itemBuilder: (context, index) {
//                   final tracker = snapshot.data.docs[index];
//                   return InkWell(
//                       onTap: () {
//                         selectedIndex.value = index;
//                         selectedTaskMap.value = {
//                           'title': tracker['title'],
//                           'note': tracker['note'],
//                           'currStreak': DateTime.now()
//                                   .difference(
//                                       (tracker['currStreakDate'] as Timestamp)
//                                           .toDate())
//                                   .inDays +
//                               1
//                         };
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: selectedIndex.value == index
//                               ? CustomTheme.activeIcon
//                               : Colors.transparent,
//                         ),
//                         padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
//                         child: Transform.scale(
//                           scale: selectedIndex.value == index ? 0.9 : 1,
//                           child: Padding(
//                             padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
//                             child: Container(
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(20),
//                                   color: Theme.of(context).backgroundColor,
//                                   boxShadow: CustomTheme.boxShadow),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(tracker['title'],
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .headline4
//                                               ?.copyWith(
//                                                   color: Theme.of(context)
//                                                       .primaryColor
//                                                       .withAlpha(200))),
//                                       Row(
//                                         children: [
//                                           Text(
//                                               '${DateTime.now().difference((tracker['currStreakDate'] as Timestamp).toDate()).inDays + 1}',
//                                               style: TextStyle(
//                                                   fontWeight: FontWeight.bold)),
//                                           Icon(Icons.park_rounded,
//                                               color: Color.fromARGB(
//                                                   255, 147, 182, 117))
//                                         ],
//                                       )
//                                     ],
//                                   ),
//                                   Padding(
//                                       padding:
//                                           EdgeInsets.symmetric(vertical: 5)),
//                                   Divider(),
//                                   Text(tracker['note'])
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ));
//                 })
//             : Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 50.0),
//                 child: SpinKitWanderingCubes(
//                   color: Theme.of(context).primaryColor,
//                   size: 75.0,
//                 ),
//               ));
//   }
// }

class PreviewPage extends StatelessWidget {
  const PreviewPage({Key? key, required this.postData}) : super(key: key);

  final postData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Post Preview')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: Text(
                    'This is how your post will look like to other people.'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 15.0),
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
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              Image(
                                  width: 100.w,
                                  image: FileImage(postData['attachment']),
                                  fit: BoxFit.fitWidth),
                          if (postData['attachmentType'] == 'task')
                            Container(
                              color: CustomTheme.attachmentBackground,
                              padding:
                                  const EdgeInsets.fromLTRB(15, 15, 15, 15),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                '${postData['attachment']['timesCompleted']}',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Icon(Icons.check_circle_rounded,
                                                color: Color.fromARGB(
                                                    255, 147, 182, 117))
                                          ],
                                        )
                                      ],
                                    ),
                                    Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 5)),
                                    Divider(),
                                    ListView.builder(
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
                                            ),
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
                                        }),
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withAlpha(150),
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Center(
                                    child: Text(
                                        '#${postData['hashtags'][index]}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .overline),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      Divider(thickness: 2, height: 0),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 0, 10),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 10, 20, 10),
                                decoration: new BoxDecoration(
                                  border: Border.all(
                                      color: Colors.black26, width: 1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                    child: Text(
                                  'Add a comment',
                                  style: TextStyle(fontSize: 13.sp),
                                ))),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 15, 15, 0),
                        child: Text('5 minutes ago',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12.sp)),
                      )
                    ],
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Okay.',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold))),
            ],
          ),
        ));
  }
}
