import 'package:shizen_app/utils/allUtils.dart';
import './addnewpost.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  var itemList = List.generate(20, (int index) => "Index $index");

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
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(8, 10, 8, 0),
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          ListView.builder(
              physics: BouncingScrollPhysics(),
              itemCount: itemList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(itemList[index]),
                );
              }),
          Positioned(
            bottom: 20,
            child: ElevatedButton(
              child: Text("New Post"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddNewPost()));
              },
            ),
          ),
        ],
      ),
    );
  }

  //Custom Widget of a Post
}
