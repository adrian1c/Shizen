import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shizen_app/modules/messaging/instantmessaging.dart';
import 'package:shizen_app/modules/profile/profile.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:badges/badges.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:shizen_app/utils/allUtils.dart';

class FriendsPage extends HookWidget {
  const FriendsPage({Key? key}) : super(key: key);

  Map typeOfFriend(data) {
    Map result = {'sentRequests': [], 'newRequests': [], 'friendsList': []};
    if (data.length < 1) {
      return result;
    }

    data.forEach((element) {
      switch (element['status']) {
        case 0:
          result['sentRequests'].add(element);
          break;
        case 1:
          result['newRequests'].add(element);
          break;
        case 2:
          result['friendsList'].add(element);
          break;
      }
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    print('Fren page b');
    String uid = Provider.of<UserProvider>(context).user.uid;
    final isExpanded = useState(false);
    final searchController = useTextEditingController();

    final stream = useMemoized(() => Database(uid).getFriendsList(), []);
    final friendsStream = useStream(stream);

    if (friendsStream.hasData) {
      var friendsList = typeOfFriend(friendsStream.data.docs);
      var newRequestData = friendsList["newRequests"];
      var friendsData = friendsList["friendsList"];
      return SafeArea(
        minimum: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FriendsSearchField(
                    uid: uid, searchController: searchController),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InstantMessagingPage()));
                    },
                    icon: StreamBuilder(
                        stream: Database(uid).getUnreadMessageCount(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.docs.length > 0) {
                              return Badge(
                                  badgeContent: Text(
                                      snapshot.data!.docs.length.toString(),
                                      style: TextStyle(color: Colors.white)),
                                  child: Icon(Icons.message_outlined,
                                      color: Theme.of(context).primaryColor));
                            } else {
                              return Icon(Icons.message_outlined,
                                  color: Theme.of(context).primaryColor);
                            }
                          }

                          return Icon(Icons.message_outlined,
                              color: Theme.of(context).primaryColor);
                        }))
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
                physics: ScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    newRequestData.length > 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text("New Requests"),
                                  )
                                ],
                              ),
                              newRequestData.length > 2
                                  ? IconButton(
                                      icon: Icon(isExpanded.value
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded),
                                      onPressed: isExpanded.value
                                          ? () => isExpanded.value = false
                                          : () => isExpanded.value = true)
                                  : Container(),
                            ],
                          )
                        : Container(),
                    newRequestData.length > 0
                        ? ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount:
                                !isExpanded.value && newRequestData.length > 2
                                    ? 2
                                    : newRequestData.length,
                            itemBuilder: (context, index) {
                              return NewRequestTile(
                                  friend: newRequestData[index], uid: uid);
                            })
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Text("You have no new requests")),
                    Divider(),
                    Row(
                      children: [
                        Text(friendsData.length != 1
                            ? "You have ${friendsData.length} friends"
                            : "You have ${friendsData.length} friend"),
                      ],
                    ),
                    ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: friendsData.length,
                        itemBuilder: (context, index) {
                          return FriendsListTile(
                              friend: friendsData[index], uid: uid);
                        }),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FriendsSearchField(uid: uid, searchController: searchController),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InstantMessagingPage()));
                  },
                  icon: Icon(Icons.message_outlined,
                      color: Theme.of(context).primaryColor)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 15),
              physics: ScrollPhysics(),
              child: SpinKitWanderingCubes(
                  color: Theme.of(context).primaryColor, size: 75),
            ),
          ),
        ],
      ),
    );
  }
}

class FriendsSearchField extends StatelessWidget {
  const FriendsSearchField(
      {Key? key, required this.uid, required this.searchController})
      : super(key: key);

  final uid;
  final searchController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: TextFormField(
          decoration: StyledInputField(
                  hintText: 'Enter email address...',
                  controller: searchController)
              .inputDecoration(),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.search,
          inputFormatters: [
            FilteringTextInputFormatter.deny(RegExp(r'\s')),
          ],
          controller: searchController,
          maxLines: 1,
          validator: (value) {
            String valueString = value as String;
            if (valueString.isEmpty) {
              return "Enter email address or name";
            } else {
              return null;
            }
          },
          onFieldSubmitted: (value) {
            StyledPopup(
              context: context,
              children: [
                FutureBuilder<List<QuerySnapshot>>(
                    future: Database(uid).getFriendSearch(value),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Text("Loading...");

                      final results = snapshot.data![0].docs;
                      final currentFriends = snapshot.data![1].docs;
                      if (results.length == 0) {
                        return Text("No results found");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: BouncingScrollPhysics(),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          var status = 3;
                          for (var i = 0; i < currentFriends.length; i++) {
                            if (currentFriends[i]['email'] ==
                                results[index]['email']) {
                              status = currentFriends[i]['status'];
                            }
                          }
                          return SearchListTile(
                              user: results[index], status: status, uid: uid);
                        },
                      );
                    }),
              ],
              title: 'Search Results',
              cancelText: 'Done',
            ).showPopup();
          },
        ),
      ),
    );
  }
}

class SearchListTile extends StatelessWidget {
  const SearchListTile(
      {Key? key, required this.user, required this.status, required this.uid})
      : super(key: key);

  final user;
  final status;
  final uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Material(
        child: ListTile(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Scaffold(
                  appBar: AppBar(
                    title: Text('${user['name']}\'s Profile'),
                    centerTitle: true,
                  ),
                  body: ProfilePage(viewId: user.id));
            }));
          },
          contentPadding: const EdgeInsets.all(10),
          leading: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: CircleAvatar(
              foregroundImage: user['image'] != ''
                  ? CachedNetworkImageProvider(user['image'])
                  : Images.defaultPic.image,
              backgroundColor: Colors.grey,
              radius: 3.h,
            ),
          ),
          title: Text(user["name"],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 15.sp)),
          subtitle: Text(user["email"],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 12.sp)),
          trailing: user.id == uid
              ? null
              : status == 0
                  ? IconButton(onPressed: () {}, icon: Icon(Icons.pending))
                  : status == 2
                      ? IconButton(onPressed: () {}, icon: Icon(Icons.check))
                      : status == 1
                          ? null
                          : IconButton(
                              onPressed: () {
                                Database(uid).sendFriendReq(user.id);
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.person_add),
                            ),
          horizontalTitleGap: 0,
          tileColor: Colors.amberAccent[700],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class NewRequestTile extends StatelessWidget {
  const NewRequestTile({Key? key, required this.friend, required this.uid})
      : super(key: key);

  final friend;
  final uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        title: Text("${friend["name"]}"),
        subtitle: Text(
          "${friend["email"]}",
          overflow: TextOverflow.ellipsis,
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () async {
                  await Database(uid).declineFriendReq(friend.id);
                },
                icon: Icon(Icons.cancel_outlined),
              ),
              IconButton(
                onPressed: () async {
                  await Database(uid).acceptFriendReq(friend.id);
                },
                icon: Icon(Icons.check),
              ),
            ],
          ),
        ),
        horizontalTitleGap: 0,
        tileColor: Colors.amberAccent[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class FriendsListTile extends StatelessWidget {
  const FriendsListTile({Key? key, required this.friend, required this.uid})
      : super(key: key);

  final friend;
  final uid;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Container(
        width: 100.w,
        height: 10.h,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: CustomTheme.boxShadow,
        ),
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Scaffold(
                      appBar: AppBar(
                        title: Text('${friend['name']}\'s Profile'),
                        centerTitle: true,
                      ),
                      body: ProfilePage(viewId: friend.id));
                }));
              },
              leading: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: CircleAvatar(
                  foregroundImage: friend['image'] != ''
                      ? CachedNetworkImageProvider(friend['image'])
                      : Images.defaultPic.image,
                  backgroundColor: Colors.grey,
                  radius: 3.h,
                ),
              ),
              title: Text(
                "${friend["name"]}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 20.sp),
              ),
              subtitle: Text(
                "${friend["email"]}",
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).primaryColorDark, fontSize: 13.sp),
              ),
              trailing: IconButton(
                color: Theme.of(context).primaryColorDark,
                onPressed: () {
                  StyledPopup(
                    context: context,
                    title: 'Actions',
                    children: [
                      Divider(),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Scaffold(
                                  appBar: AppBar(
                                    title: Text('${friend['name']}\'s Profile'),
                                    centerTitle: true,
                                  ),
                                  body: ProfilePage(viewId: friend.id));
                            }));
                          },
                          child: Text("View Profile")),
                      TextButton(
                          onPressed: () async {
                            await Database(uid).declineFriendReq(friend.id);

                            Navigator.pop(context);
                          },
                          child: Text("Remove Friend")),
                    ],
                    cancelText: 'Done',
                  ).showPopup();
                },
                icon: Icon(Icons.more_horiz),
              ),
              horizontalTitleGap: 0,
              tileColor: Theme.of(context).backgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ),
    );
  }
}
