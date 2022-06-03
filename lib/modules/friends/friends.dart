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
    String uid = Provider.of<UserProvider>(context).user.uid;
    final searchController = useTextEditingController();

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
          Divider(),
          NewRequestList(),
          Divider(),
          Expanded(child: FriendsList()),
        ],
      ),
    );
  }
}

class NewRequestList extends HookWidget {
  const NewRequestList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final stream = useMemoized(() => Database(uid).getNewFriendRequestsList(),
        [Provider.of<TabProvider>(context).friendPage]);
    final friendsRequestStream = useStream(stream);

    if (friendsRequestStream.connectionState == ConnectionState.active &&
        friendsRequestStream.hasData) {
      var data = friendsRequestStream.data;
      return Column(
        children: [
          friendsRequestStream.data.length > 0
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(data.length != 1
                      ? 'You have ${data.length} new friend requests'
                      : 'You have ${data.length} new friend request'),
                )
              : Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'You have no new friend requests',
                  ),
                ),
          ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length > 2 ? 3 : data.length,
              itemBuilder: (context, index) {
                if (index == data.length) {
                  return InkWell(
                      child: Text('See More'),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return NewRequestsPage();
                        }));
                      });
                }
                return NewRequestTile(friend: data[index]);
              })
        ],
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'You have no new friend requests',
      ),
    );
  }
}

class FriendsList extends HookWidget {
  const FriendsList({
    Key? key,
    // required this.refreshValue
  }) : super(key: key);

  // final refreshValue;

  loadMorePosts(uid, friendsList, loadMore, lastDoc) async {
    var newPosts = await Database(uid).getFriendsList(true, lastDoc.value);
    if (newPosts[0].isEmpty) {
      loadMore.value = false;
      lastDoc.value = null;
      return;
    }

    friendsList.value.addAll(newPosts[0]);
    lastDoc.value = newPosts[2];

    return;
  }

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
    final future = useMemoized(() => Database(uid).getFriendsList(),
        [Provider.of<TabProvider>(context).friendPage]);
    final friendsFuture = useFuture(future);
    final initialLoad = useState(false);
    final friendsList = useState([]);
    final ValueNotifier<int?> friendsCount = useState(null);
    final ValueNotifier<DocumentSnapshot?> lastDoc = useState(null);
    final scrollController = useScrollController();
    final loadMore = useState(true);

    useEffect(() {
      initialLoad.value = false;
      loadMore.value = true;

      scrollController.addListener(() {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          if (loadMore.value) {
            loadMorePosts(uid, friendsList, loadMore, lastDoc);
          }
        }
      });

      return;
    }, [Provider.of<TabProvider>(context).friendPage]);

    if (friendsFuture.connectionState == ConnectionState.done &&
        friendsFuture.hasData) {
      if (!initialLoad.value) {
        friendsList.value = friendsFuture.data[0];
        friendsCount.value = friendsFuture.data[1];
        lastDoc.value = friendsFuture.data[2];
        initialLoad.value = true;
      }

      return Column(
        children: [
          friendsList.value.length > 0
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: Text(friendsList.value.length != 1
                      ? 'You have ${friendsCount.value} friends'
                      : 'You have ${friendsCount.value} friend'),
                )
              : Align(
                  alignment: Alignment.center,
                  child: Text(
                    'You have no friends.\nYou can add friends by searching above.',
                  ),
                ),
          Flexible(
            child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                controller: scrollController,
                itemCount: friendsList.value.length,
                itemBuilder: (context, index) {
                  if (index == friendsList.value.length && loadMore.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: SpinKitWanderingCubes(
                        color: Theme.of(context).primaryColor,
                        size: 75.0,
                      ),
                    );
                  }
                  return FriendsListTile(friend: friendsList.value[index]);
                }),
          )
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50.0),
      child: SpinKitWanderingCubes(
        color: Theme.of(context).primaryColor,
        size: 75.0,
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
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: Scaffold(
                        appBar: AppBar(
                          title: Text(user['name'].length > 12
                              ? '${user['name']}\'s Profile'
                              : 'Profile'),
                          centerTitle: true,
                        ),
                        body: ProfilePage(viewId: user.id))));
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
                              onPressed: () async {
                                await LoaderWithToast(
                                        context: context,
                                        api: Database(uid)
                                            .sendFriendReq(user.id)
                                            .then((value) {
                                          Navigator.pop(context);
                                        }),
                                        msg: 'Sent',
                                        isSuccess: true)
                                    .show();
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
  const NewRequestTile({Key? key, required this.friend}) : super(key: key);

  final friend;

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;
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
                  Provider.of<TabProvider>(context, listen: false)
                      .rebuildPage('friendPage');
                  await Database(uid).declineFriendReq(friend.id);
                },
                icon: Icon(Icons.cancel_outlined),
              ),
              IconButton(
                onPressed: () async {
                  Provider.of<TabProvider>(context, listen: false)
                      .rebuildPage('friendPage');
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
  const FriendsListTile({Key? key, required this.friend}) : super(key: key);

  final friend;

  @override
  Widget build(BuildContext context) {
    String uid = Provider.of<UserProvider>(context).user.uid;

    return Padding(
      padding: const EdgeInsets.fromLTRB(5, 15, 5, 15),
      child: Container(
        width: 100.w,
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
                      body: ProfilePage(viewId: friend['uid']));
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
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.bottomToTop,
                                    child: Scaffold(
                                        appBar: AppBar(
                                          title: Text(
                                              '${friend['name']}\'s Profile'),
                                          centerTitle: true,
                                        ),
                                        body: ProfilePage(
                                            viewId: friend['uid']))));
                          },
                          child: Text("View Profile")),
                      TextButton(
                          onPressed: () async {
                            await LoaderWithToast(
                                    context: context,
                                    api: Database(uid)
                                        .removeFriend(friend['uid'])
                                        .then((value) {
                                      Navigator.pop(context);
                                      Provider.of<TabProvider>(context,
                                              listen: false)
                                          .rebuildPage('friendPage');
                                    }),
                                    msg: 'Unfriended',
                                    isSuccess: true)
                                .show();
                          },
                          child: Text("Remove Friend",
                              style: TextStyle(color: Colors.red[400]))),
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

class NewRequestsPage extends StatelessWidget {
  const NewRequestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Requests'),
        centerTitle: true,
      ),
      body: ListView.builder(itemBuilder: (context, index) {
        return Text('Nice');
      }),
    );
  }
}
