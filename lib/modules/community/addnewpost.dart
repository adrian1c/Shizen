import 'package:menu_button/menu_button.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';
import 'package:shizen_app/models/communityPost.dart';

class AddNewPost extends StatefulWidget {
  AddNewPost({Key? key}) : super(key: key);

  static String visibilityValue = 'Friends Only';

  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  List<String> items = [
    'Friends Only',
    'Everyone',
    'Anonymous',
  ];

  final TextEditingController postDescController = TextEditingController();

  final List<TextEditingController> hashtagController = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final ValueNotifier isValid = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    AddNewPost.visibilityValue = 'Friends only';
  }

  @override
  void dispose() {
    super.dispose();
    postDescController.dispose();
    hashtagController[0].dispose();
    hashtagController[1].dispose();
    hashtagController[2].dispose();
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;

    return Scaffold(
        appBar: AppBar(
          title: const Text("New Post"),
          centerTitle: true,
        ),
        body: SafeArea(
          minimum: const EdgeInsets.all(20),
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
                        DropdownVisibility(
                            items: items,
                            visibilityValue: AddNewPost.visibilityValue),
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
                            AddNewPost.visibilityValue,
                          ).toJson();
                          await Database(uid)
                              .addNewPost(newPost, AddNewPost.visibilityValue)
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
    return showDialog(
        context: context,
        builder: (BuildContext context) {
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
                      child: InkWell(
                          child: Center(child: Text("Task")), onTap: () {}),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
            ],
          );
        });
  }
}

class DropdownVisibility extends StatefulWidget {
  DropdownVisibility(
      {Key? key, required this.items, required this.visibilityValue})
      : super(key: key);

  final List<String> items;
  final String visibilityValue;

  @override
  _DropdownVisibilityState createState() => _DropdownVisibilityState();
}

class _DropdownVisibilityState extends State<DropdownVisibility> {
  @override
  Widget build(BuildContext context) {
    return MenuButton<String>(
      child: VisibilityItem(visibilityValue: AddNewPost.visibilityValue),
      items: widget.items,
      itemBuilder: (String value) => Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
        child: Text(value),
      ),
      toggledChild: Container(
        child: VisibilityItem(visibilityValue: widget.visibilityValue),
      ),
      onItemSelected: (String value) {
        setState(() {
          AddNewPost.visibilityValue = value;
        });
      },
      onMenuButtonToggle: (bool isToggle) {},
      // showSelectedItemOnList: false,
    );
  }
}

class VisibilityItem extends StatefulWidget {
  const VisibilityItem({Key? key, required this.visibilityValue})
      : super(key: key);

  final String visibilityValue;

  @override
  VisibilityItemState createState() => VisibilityItemState();
}

class VisibilityItemState extends State<VisibilityItem> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      height: 40,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Text(AddNewPost.visibilityValue,
                    overflow: TextOverflow.ellipsis)),
            const SizedBox(
              width: 12,
              height: 17,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostDescField extends StatefulWidget {
  PostDescField(
      {Key? key, required this.isValid, required this.postDescController})
      : super(key: key);

  final ValueNotifier isValid;
  final TextEditingController postDescController;

  @override
  _PostDescFieldState createState() => _PostDescFieldState();
}

class _PostDescFieldState extends State<PostDescField> {
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
      child: TextFormField(
          controller: widget.postDescController,
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
          // The validator receives the text that the user has entered.
          onChanged: (value) {
            if (value != '') {
              print("Not empty");
              widget.isValid.value = true;
            } else {
              print("Empty");
              widget.isValid.value = false;
            }
          },
          validator: (value) {
            String valueString = value as String;
            if (valueString.isEmpty) {
              return "You have not filled anything in";
            } else {
              return null;
            }
          }),
    );
  }
}

class HashtagField extends StatefulWidget {
  HashtagField({Key? key, required this.hashtagController}) : super(key: key);

  final TextEditingController hashtagController;

  @override
  _HashtagFieldState createState() => _HashtagFieldState();
}

class _HashtagFieldState extends State<HashtagField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.hashtagController,
      decoration: InputDecoration(hintText: 'Hashtag'),
      onChanged: (value) {},
    );
  }
}
