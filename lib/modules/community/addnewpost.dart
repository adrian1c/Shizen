import 'package:flutter_hooks/flutter_hooks.dart';
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.attachment_sharp),
                          const Text("Attach"),
                        ],
                      ),
                    ),
                    onTap: () {
                      showAttach();
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
                          ).toJson();
                          await Database(uid)
                              .addNewPost(newPost, visibilityValue.value)
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

  Future<dynamic> showAttach() {
    return OneContext().showDialog(builder: (_) {
      return AlertDialog(
        title: Text("Search Results"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(),
              SizedBox(
                width: 300,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  child: InkWell(
                    child: Center(child: Text("Image")),
                    onTap: () {},
                  ),
                ),
              ),
              Divider(
                color: Colors.transparent,
              ),
              SizedBox(
                width: 300,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  child:
                      InkWell(child: Center(child: Text("Task")), onTap: () {}),
                ),
              ),
            ],
          ),
        ),
        actions: [
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
      onChanged: (value) {},
    );
  }
}
