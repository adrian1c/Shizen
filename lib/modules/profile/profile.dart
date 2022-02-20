import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static ValueNotifier isLoading = ValueNotifier(false);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;
    return ValueListenableBuilder(
        valueListenable: ProfilePage.isLoading,
        builder: (context, data, _) {
          if (data != false) return Text('Loading');

          return FutureBuilder(
              future: Database(uid).getCurrentUserData(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) return const Text("Loading");
                return UserProfileData(data: snapshot.data, uid: uid);
              });
        });
  }
}

class UserProfileData extends StatelessWidget {
  const UserProfileData({Key? key, required this.data, required this.uid})
      : super(key: key);

  final data;
  final String uid;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.redAccent),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: 25.w,
                      height: 25.w,
                      child: data.data().containsKey('image')
                          ? InkWell(
                              child: Container(
                                  decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 1),
                                color: Colors.grey,
                                image: DecorationImage(
                                    image: Image.network(data!['image']).image),
                              )),
                              onTap: () async =>
                                  await changeProfilePic(context, true),
                            )
                          : InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(width: 1),
                                  color: Colors.grey,
                                ),
                              ),
                              onTap: () async {
                                await changeProfilePic(context, false);
                              },
                            ),
                    ),
                  ),
                  Text(data!['name'], style: TextStyle(fontSize: 25.sp)),
                  Text(data!['email'], style: TextStyle(fontSize: 15.sp)),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(data.data().containsKey('bio')
                    ? "Nice"
                    : "I do not have a bio..."),
              ),
              Logout(uid: uid),
            ],
          ),
        )
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

  changeProfilePic(context, bool existingPic) async {
    await showDialog(
        context: context,
        builder: (BuildContext dialogContext1) {
          return AlertDialog(
            title: Text(existingPic
                ? "Change Profile Picture"
                : 'Upload Profile Picture'),
            content: Text(existingPic
                ? 'Do you want to change your profile picture to a new one?'
                : 'Do you want to upload a profile picture?'),
            actions: [
              TextButton(
                  onPressed: () async {
                    var image = await pickImage();
                    if (image != null) {
                      Navigator.of(dialogContext1).pop();
                      image = await cropImage(image);
                      if (image == null) return;
                      await showDialog(
                          context: context,
                          builder: (BuildContext dialogContext2) {
                            return AlertDialog(
                              title: Text("Upload Profile Picture"),
                              content: Image(image: FileImage(image)),
                              actions: [
                                TextButton(
                                    onPressed: () async {
                                      Navigator.of(dialogContext2).pop();
                                      await Database(uid)
                                          .uploadProfilePic(context, image);
                                      ProfilePage.isLoading.value = true;
                                      ProfilePage.isLoading.value = false;
                                    },
                                    child: Text("Upload")),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext2).pop();
                                  },
                                  child: Text("Cancel"),
                                ),
                              ],
                            );
                          });
                    }
                  },
                  child: Text("Change")),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext1).pop();
                },
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }
}

class Logout extends StatelessWidget {
  const Logout({Key? key, required this.uid}) : super(key: key);

  final String uid;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      child: LogoutButton(
        uid: uid,
        context: context,
        isLoading: ProfilePage.isLoading,
      ),
    );
  }
}
