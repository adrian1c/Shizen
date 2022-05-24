import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shizen_app/modules/messaging/instantmessaging.dart';
import 'package:shizen_app/modules/profile/profile.dart';
import 'package:shizen_app/widgets/field.dart';
import 'package:badges/badges.dart';

import '../../utils/allUtils.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  ValueNotifier _isExpanded = ValueNotifier(false);
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    return SafeArea(
        minimum: EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              searchField(uid, context),
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
                  FutureBuilder<Map<dynamic, dynamic>>(
                      future: Database(uid).friendsPageData(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text("Loading");

                        var newRequestData = snapshot.data!["newRequests"];
                        var friendsData = snapshot.data!["friendsList"];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            newRequestData.length > 0
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person_add_alt_1_rounded),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Text("New Requests"),
                                          )
                                        ],
                                      ),
                                      newRequestData.length > 2
                                          ? newRequestArrow(newRequestData)
                                          : Container(),
                                    ],
                                  )
                                : Container(),
                            newRequestData.length > 0
                                ? newRequestBuilder(
                                    newRequestData, friendsData, uid)
                                : Text("You have no new requests"),
                            Divider(),
                            Row(
                              children: [
                                Text(friendsData.length != 1
                                    ? "You have ${friendsData.length} friends"
                                    : "You have ${friendsData.length} friend"),
                              ],
                            ),
                            friendsBuilder(friendsData, uid, context),
                          ],
                        );
                      }),
                ],
              ),
            ),
          )
        ]));
  }

  Widget searchField(uid, context) {
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

                      return Material(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            var status = 3;
                            for (var i = 0; i < currentFriends.length; i++) {
                              if (currentFriends[i]['email'] ==
                                  results[index]['email']) {
                                status = currentFriends[i]['status'];
                              }
                            }
                            return searchListTile(results[index], status, uid);
                          },
                        ),
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

  Widget newRequestArrow(itemList) {
    return ValueListenableBuilder(
        valueListenable: _isExpanded,
        builder: (context, data, _) {
          if (data != true) {
            return IconButton(
                onPressed: () {
                  _isExpanded.value = true;
                },
                icon: Icon(Icons.keyboard_arrow_down_rounded));
          }

          return IconButton(
              onPressed: () {
                _isExpanded.value = false;
              },
              icon: Icon(Icons.keyboard_arrow_up_rounded));
        });
  }

  Widget newRequestBuilder(itemList, friendsList, uid) {
    return ValueListenableBuilder(
        valueListenable: _isExpanded,
        builder: (context, data, _) {
          return ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount:
                  data != true && itemList.length > 2 ? 2 : itemList.length,
              itemBuilder: (context, index) {
                return newRequestListTile(itemList, friendsList, index, uid);
              });
        });
  }

  Widget newRequestListTile(itemList, friendsList, index, uid) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Material(
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text("${itemList[index]["name"]}"),
          subtitle: Text(
            "${itemList[index]["email"]}",
            overflow: TextOverflow.ellipsis,
          ),
          trailing: SizedBox(
            width: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () async {
                    await Database(uid)
                        .declineFriendReq(itemList[index].id)
                        .then((value) =>
                            setState(() => itemList.removeAt(index)));
                  },
                  icon: Icon(Icons.cancel_outlined),
                ),
                IconButton(
                  onPressed: () async {
                    await Database(uid).acceptFriendReq(itemList[index].id);
                    setState(() {
                      itemList.removeAt(index);
                      friendsList = friendsList;
                    });
                  },
                  icon: Icon(Icons.check),
                ),
              ],
            ),
          ),
          horizontalTitleGap: 0,
          tileColor: Colors.amberAccent[700],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget friendsBuilder(itemList, uid, context) {
    return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          return friendListTile(itemList, index, uid, context);
        });
  }

  Widget friendListTile(itemList, index, uid, context) {
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
          child: ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Scaffold(
                    appBar: AppBar(
                      title: Text('${itemList[index]['name']}\'s Profile'),
                      centerTitle: true,
                    ),
                    body: ProfilePage(viewId: itemList[index].id));
              }));
            },
            leading: Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: CircleAvatar(
                foregroundImage:
                    CachedNetworkImageProvider(itemList[index]['image']),
                backgroundColor: Colors.grey,
                radius: 3.h,
              ),
            ),
            title: Text(
              "${itemList[index]["name"]}",
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: Theme.of(context).primaryColorDark, fontSize: 20.sp),
            ),
            subtitle: Text(
              "${itemList[index]["email"]}",
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
                                  title: Text(
                                      '${itemList[index]['name']}\'s Profile'),
                                  centerTitle: true,
                                ),
                                body: ProfilePage(viewId: itemList[index].id));
                          }));
                        },
                        child: Text("View Profile")),
                    TextButton(
                        onPressed: () async {
                          await Database(uid)
                              .declineFriendReq(itemList[index].id)
                              .then((value) =>
                                  setState(() => itemList.removeAt(index)));

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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }

  Widget searchListTile(user, status, uid) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Material(
        child: ListTile(
          contentPadding: const EdgeInsets.all(10),
          title: Text(user["name"]),
          subtitle: Text(
            user["email"],
            overflow: TextOverflow.ellipsis,
          ),
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
