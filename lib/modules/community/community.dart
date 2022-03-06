import 'package:shizen_app/utils/allUtils.dart';
import 'package:shizen_app/widgets/dropdown.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import './addnewpost.dart';

class CommunityPage extends HookWidget {
  List<String> items = [
    'Friends Only',
    'Everyone',
    'Anonymous',
  ];

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;
    final hashtagController = useTextEditingController();
    final visibilityValue = useState('Friends Only');

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
                          Text("Display", style: TextStyle(fontSize: 15.sp)),
                          Dropdown(
                              items: items,
                              value: visibilityValue,
                              onItemSelected: (String value) {
                                visibilityValue.value = value;
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.tag_rounded),
                          Text("Hashtag", style: TextStyle(fontSize: 15.sp)),
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
                    child: CommunityPostList(visibilityValue: visibilityValue),
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

class CommunityPostList extends HookWidget {
  CommunityPostList({Key? key, required this.visibilityValue})
      : super(key: key);

  final visibilityValue;

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).uid;
    final future = useMemoized(
        () => Database(uid).getCommunityPost(visibilityValue.value),
        [visibilityValue.value]);
    final snapshot = useFuture(future);
    return Container(
        child: !snapshot.hasData
            ? const Text("Loading")
            : ListView.builder(
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: PostListTile(postData: snapshot.data![index]),
                  );
                }));
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
            Container(
                width: 5.h,
                height: 5.h,
                child: postData.containsKey('image')
                    ? InkWell(
                        child: Container(
                            decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1),
                          color: Colors.grey,
                          image: DecorationImage(
                              image: Image.network(postData!['image']).image),
                        )),
                        onTap: () => print('Nicer'),
                      )
                    : CircleAvatar(
                        foregroundImage: Images.defaultPic.image,
                        backgroundColor: Colors.grey,
                        radius: 3.h,
                      )),
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
                    return Text('#${postData['hashtags'][index]}   ',
                        style: TextStyle(fontSize: 13.sp));
                  },
                ),
              )
            : Container(),
        Divider(),
      ],
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
