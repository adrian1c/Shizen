import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shizen_app/modules/community/community.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends HookWidget {
  const ProfilePage({Key? key, this.viewId}) : super(key: key);

  final String? viewId;

  @override
  Widget build(BuildContext context) {
    final String uid =
        viewId != null ? viewId! : Provider.of<UserProvider>(context).uid;
    final ValueNotifier<int> isLoading = useState(0);
    final TextEditingController nameController = useTextEditingController();
    final futureUserProfileData = useMemoized(
        () => Database(uid).getCurrentUserData(), [isLoading.value]);
    final snapshotUserProfileData = useFuture(futureUserProfileData);
    final futureUserPosts = useMemoized(
        () => viewId != null
            ? Database(uid).getUserPostsOtherProfile(uid)
            : Database(uid).getUserPostsOwnProfile(uid),
        [isLoading.value]);
    final snapshotUserPosts = useFuture(futureUserPosts);
    return SingleChildScrollView(
      child: Column(
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
                      isLoading: isLoading,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(alignment: Alignment.topLeft, child: Text('Posts')),
          ),
          snapshotUserPosts.hasData
              ? snapshotUserPosts.data!.length > 0
                  ? ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshotUserPosts.data!.length,
                      itemBuilder: (context, index) {
                        return PostListTile(
                            postData: snapshotUserPosts.data![index]);
                      })
                  : Text('You don\'t have any posts.')
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
    required this.isLoading,
    required this.nameController,
    this.viewId,
  }) : super(key: key);

  final data;
  final String uid;
  final isLoading;
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
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1),
                        color: Colors.grey,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(data!['image']),
                        )),
                  ),
                  onTap: viewId != null
                      ? () {}
                      : () async =>
                          await changeProfilePic(context, true, isLoading),
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
                          await changeProfilePic(context, false, isLoading);
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
                                          Navigator.pop(context);
                                          await Database(uid)
                                              .editUserName(newName);
                                          isLoading.value += 1;
                                          print(isLoading.value);
                                          // StyledSnackbar(
                                          //         message:
                                          //             'Your display name has been changed!')
                                          //     .showSuccess();
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
        aspectRatioPresets: [CropAspectRatioPreset.square],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
    }
    return imageFile;
  }

  changeProfilePic(context, bool existingPic, isLoading) async {
    StyledPopup(
      context: context,
      title: existingPic ? 'Change Profile Picture' : 'Upload Profile Picture',
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
                            content: Image(image: FileImage(image)),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await Database(uid).uploadProfilePic(image);
                                    isLoading.value += 1;
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
                                await Database(uid).removeProfilePic();
                                isLoading.value += 1;
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
                                    Navigator.pop(context);
                                    await Database(uid).uploadProfilePic(image);
                                    isLoading.value += 1;
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
