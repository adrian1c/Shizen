import 'package:shizen_app/utils/allUtils.dart';
import 'package:menu_button/menu_button.dart';
import './addnewpost.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  static String visibilityValue = 'Friends Only';
  static ValueNotifier changedVisibility = ValueNotifier(true);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<String> items = [
    'Friends Only',
    'Everyone',
    'Anonymous',
  ];

  final TextEditingController hashtagController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    hashtagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;

    return SafeArea(
      minimum: EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.visibility),
                          Text("Display"),
                          DropdownVisibility(
                            items: items,
                            visibilityValue: CommunityPage.visibilityValue,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.tag_rounded),
                          Text("Hashtag"),
                          HashtagFilter(hashtagController: hashtagController),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 9,
                  child: SingleChildScrollView(
                    physics: ScrollPhysics(),
                    child: ValueListenableBuilder(
                        valueListenable: CommunityPage.changedVisibility,
                        builder: (context, data, _) {
                          if (data == true) {
                            return CommunityPostList();
                          } else {
                            return Text("Changed");
                          }
                        }),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 30,
              child: ElevatedButton(
                child: Text("New Post"),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AddNewPost()));
                },
              ),
            ),
          ]),
    );
  }
}

class CommunityPostList extends StatefulWidget {
  const CommunityPostList({Key? key}) : super(key: key);

  @override
  _CommunityPostListState createState() => _CommunityPostListState();
}

class _CommunityPostListState extends State<CommunityPostList> {
  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;
    return FutureBuilder(
        future: Database(uid).getCommunityPost(CommunityPage.visibilityValue),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) return const Text("Loading");
          return ListView.builder(
              physics: BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: PostListTile(postData: snapshot.data[index]),
                );
              });
        });
  }
}

class PostListTile extends StatelessWidget {
  const PostListTile({Key? key, required this.postData}) : super(key: key);

  final postData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Placeholder(
              fallbackWidth: 5.h,
              fallbackHeight: 5.h,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(postData['name']),
                  Text(postData['email']),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Text(postData['desc']),
        ),
        postData['hashtags'].length > 0
            ? Container(
                width: 100.w,
                height: 30,
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: postData['hashtags'].length,
                  itemBuilder: (context, index) {
                    return Text('#${postData['hashtags'][index]}   ');
                  },
                ),
              )
            : Container(),
        Divider(),
      ],
    );
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
      child: VisibilityItem(visibilityValue: CommunityPage.visibilityValue),
      items: widget.items,
      itemBuilder: (String value) => Container(
        // height: 40,
        width: 25.w,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: Text(value),
      ),
      toggledChild: Container(
        child: VisibilityItem(visibilityValue: widget.visibilityValue),
      ),
      onItemSelected: (String value) {
        CommunityPage.changedVisibility.value = false;
        setState(() {
          CommunityPage.visibilityValue = value;
        });
        CommunityPage.changedVisibility.value = true;
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
      width: 25.w,
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
                child: Text(CommunityPage.visibilityValue,
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

class HashtagFilter extends StatefulWidget {
  HashtagFilter({Key? key, required this.hashtagController}) : super(key: key);

  final TextEditingController hashtagController;

  @override
  _HashtagFilterState createState() => _HashtagFilterState();
}

class _HashtagFilterState extends State<HashtagFilter> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25.w,
      child: TextField(
        controller: widget.hashtagController,
        maxLength: 20,
        decoration: InputDecoration(
          hintText: 'Hashtag',
          contentPadding: EdgeInsets.all(5),
          border: OutlineInputBorder(
            borderRadius: new BorderRadius.circular(5.0),
            borderSide: new BorderSide(),
          ),
        ),
        onEditingComplete: () {
          // Database(uid).getCommunityPost(filter, );
        },
      ),
    );
  }
}
