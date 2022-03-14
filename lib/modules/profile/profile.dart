import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shizen_app/widgets/field.dart';

class ProfilePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final String uid = Provider.of<UserProvider>(context).uid;
    final ValueNotifier<int> isLoading = useState(0);
    final TextEditingController nameController = useTextEditingController();
    final ValueNotifier isValid = useValueNotifier(true);
    final future = useMemoized(
        () => Database(uid).getCurrentUserData(), [isLoading.value]);
    final snapshot = useFuture(future);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              height: 15.h,
              color: Color(0xff297ca6),
              child: Row(
                children: [Text('Hey', style: TextStyle(color: Colors.white))],
              )),
        ],
      ),
    );
    // return Container(
    //   child: !snapshot.hasData
    //       ? const Text('Loading')
    //       : UserProfileData(
    //           data: snapshot.data,
    //           uid: uid,
    //           isLoading: isLoading,
    //           nameController: nameController,
    //           isValid: isValid,
    //         ),
    // );
  }
}

class UserProfileData extends StatelessWidget {
  const UserProfileData(
      {Key? key,
      required this.data,
      required this.uid,
      required this.isLoading,
      required this.nameController,
      required this.isValid})
      : super(key: key);

  final data;
  final String uid;
  final isLoading;
  final nameController;
  final isValid;

  @override
  Widget build(BuildContext context) {
    final _form = GlobalKey<FormState>();
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
              SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Column(
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
                                      image:
                                          Image.network(data!['image']).image),
                                )),
                                onTap: () async => await changeProfilePic(
                                    context, true, isLoading),
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
                                  await changeProfilePic(
                                      context, false, isLoading);
                                },
                              ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          nameController.text = data!['name'];
                          StyledPopup(
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
                                          OneContext().popDialog();
                                          await Database(uid)
                                              .editUserName(newName);
                                          isLoading.value += 1;
                                          print(isLoading.value);
                                          StyledSnackbar(
                                                  message:
                                                      'Your display name has been changed!')
                                              .showSuccess();
                                        }
                                      },
                                      child: Text('Save')))
                              .showPopup();
                        },
                        child: Text(data!['name'],
                            style: TextStyle(fontSize: 25.sp))),
                    Text(data!['email'], style: TextStyle(fontSize: 15.sp)),
                  ],
                ),
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
              Logout(
                uid: uid,
                isLoading: isLoading,
              ),
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

  changeProfilePic(context, bool existingPic, isLoading) async {
    StyledPopup(
            title: existingPic
                ? 'Change Profile Picture'
                : 'Upload Profile Picture',
            children: [
              Text(existingPic
                  ? 'Do you want to change your profile picture to a new one?'
                  : 'Do you want to upload a profile picture?')
            ],
            textButton: TextButton(
                onPressed: () async {
                  var image = await pickImage();
                  if (image != null) {
                    OneContext().popDialog();
                    image = await cropImage(image);
                    if (image == null) return;
                    OneContext().showDialog(builder: (_) {
                      return AlertDialog(
                        title: Text("Upload Profile Picture"),
                        content: Image(image: FileImage(image)),
                        actions: [
                          TextButton(
                              onPressed: () async {
                                OneContext().popDialog();
                                await Database(uid).uploadProfilePic(image);
                                isLoading.value += 1;
                              },
                              child: Text("Upload")),
                          TextButton(
                            onPressed: () {
                              OneContext().popDialog();
                            },
                            child: Text("Cancel"),
                          ),
                        ],
                      );
                    });
                  }
                },
                child: Text("Change")))
        .showPopup();
  }
}

class Logout extends StatelessWidget {
  const Logout({Key? key, required this.uid, required this.isLoading})
      : super(key: key);

  final String uid;
  final isLoading;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      child: LogoutButton(
        uid: uid,
        context: context,
        isLoading: isLoading,
      ),
    );
  }
}

class PostList extends StatelessWidget {
  const PostList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
