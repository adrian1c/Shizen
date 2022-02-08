import 'package:menu_button/menu_button.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/button.dart';

class AddNewPost extends StatefulWidget {
  AddNewPost({Key? key}) : super(key: key);

  String selectedValue = 'Friends only';

  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  List<String> items = [
    'Friends only',
    'Everyone',
    'Anonymous',
  ];

  final ValueNotifier isValid = ValueNotifier(false);

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
    print("Built AddNewPost");
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
                            items: items, selectedValue: widget.selectedValue),
                      ],
                    ),
                  ],
                ),
                PostDescField(isValid: isValid),
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
                  padding: const EdgeInsets.fromLTRB(50, 20, 50, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CreateButton(
                        onPressed: isValid.value
                            ? () async {
                                // var newPost = CommunityPost(
                                //     titleController.text, descController.text, {
                                //   "recur": recurListValue,
                                //   "reminder": reminderTime,
                                //   "deadline": deadlineDate,
                                // });
                                // await Database(uid).addToDoTask(newTask);
                                // Navigator.of(context).pop();
                                print("Nice ${widget.selectedValue}");
                              }
                            : () {},
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
    print("Built popup");
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

// ignore: must_be_immutable
class DropdownVisibility extends StatefulWidget {
  DropdownVisibility(
      {Key? key, required this.items, required this.selectedValue})
      : super(key: key);

  final List<String> items;
  late String selectedValue;

  @override
  _DropdownVisibilityState createState() => _DropdownVisibilityState();
}

class _DropdownVisibilityState extends State<DropdownVisibility> {
  @override
  Widget build(BuildContext context) {
    print("Built dropdownVisibilty");
    return MenuButton<String>(
      child: VisibilityItem(selectedValue: widget.selectedValue),
      items: widget.items,
      itemBuilder: (String value) => Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16),
        child: Text(value),
      ),
      toggledChild: Container(
        child: VisibilityItem(selectedValue: widget.selectedValue),
      ),
      onItemSelected: (String value) {
        setState(() {
          widget.selectedValue = value;
        });
      },
      onMenuButtonToggle: (bool isToggle) {
        print(isToggle);
      },
      // showSelectedItemOnList: false,
    );
  }
}

class VisibilityItem extends StatefulWidget {
  const VisibilityItem({Key? key, required this.selectedValue})
      : super(key: key);

  final String selectedValue;

  @override
  VisibilityItemState createState() => VisibilityItemState();
}

class VisibilityItemState extends State<VisibilityItem> {
  @override
  Widget build(BuildContext context) {
    print("Built normalChildButton");
    return SizedBox(
      width: 125,
      height: 40,
      child: Padding(
        padding: const EdgeInsets.only(left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Text(widget.selectedValue,
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
  const PostDescField({Key? key, required this.isValid}) : super(key: key);

  final ValueNotifier isValid;

  @override
  _PostDescFieldState createState() => _PostDescFieldState();
}

class _PostDescFieldState extends State<PostDescField> {
  TextEditingController postDescController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    postDescController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Built PostDescField");
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
          // The validator receives the text that the user has entered.
          onChanged: (value) {
            print(value);
            if (value != '') {
              setState(() {
                widget.isValid.value = true;
              });
            } else {
              setState(() {
                widget.isValid.value = false;
              });
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
