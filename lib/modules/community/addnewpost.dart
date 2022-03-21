import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:menu_button/menu_button.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:shizen_app/widgets/dropdown.dart';
import 'package:shizen_app/models/communityPost.dart';

class AddNewPost extends HookWidget {
  final List<String> items = [
    'Friends Only',
    'Everyone',
    'Anonymous',
  ];

  @override
  Widget build(BuildContext context) {
    final ValueNotifier visibilityValue = useValueNotifier('Friends Only');
    final ValueNotifier isValid = useValueNotifier(false);
    final TextEditingController postDescController = useTextEditingController();
    final List<TextEditingController> hashtagController = [
      useTextEditingController(),
      useTextEditingController(),
      useTextEditingController(),
    ];
    final String uid = Provider.of<UserProvider>(context).uid;
    final ValueNotifier<File?> attachment = useState(null);
    final ValueNotifier<String?> attachmentType = useState(null);
    return Scaffold(
        appBar: AppBar(
          title: const Text("New Post"),
          centerTitle: true,
        ),
        body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Your story"),
                    Row(
                      children: [
                        const Icon(Icons.visibility_sharp),
                        const Text("Visibility"),
                        ValueListenableBuilder(
                            valueListenable: visibilityValue,
                            builder: (context, data, _) {
                              return Dropdown(
                                  items: items,
                                  value: visibilityValue,
                                  onItemSelected: (String value) =>
                                      visibilityValue.value = value);
                            }),
                      ],
                    ),
                  ],
                ),
                PostDescField(
                    isValid: isValid, postDescController: postDescController),
                Ink(
                  child: InkWell(
                    child: Container(
                      constraints: BoxConstraints(minHeight: 10.h),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border:
                              Border.all(color: Colors.grey[200]!, width: 1),
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
                                  const Text("Attach Image / Task",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Image'),
                                Image(
                                    width: 100.w,
                                    image: FileImage(attachment.value!),
                                    fit: BoxFit.fitWidth),
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
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.tag_rounded),
                          const Text("Hashtag (max 3)"),
                        ],
                      ),
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
                  padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                  child: Row(
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
                                  visibilityValue.value,
                                  attachment.value)
                              .toJson();
                          await Database(uid)
                              .addNewPost(newPost, visibilityValue.value,
                                  attachmentType.value)
                              .then((value) => Navigator.of(context).pop());
                        },
                        isValid: isValid,
                      ),
                      const CancelButton(),
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
            toolbarColor: Colors.deepOrange,
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
                    child: Text('Task'),
                  ),
                  SizedBox(
                    width: 70.w,
                    height: 7.h,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(10)),
                      child: InkWell(
                          child: Center(child: Text("Select Task")),
                          onTap: () {}),
                    ),
                  ),
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
      decoration: InputDecoration(hintText: 'Hashtag'),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]"))
      ],
      onChanged: (value) {},
    );
  }
}
