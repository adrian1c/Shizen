import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shizen_app/models/trackerTask.dart';
import 'package:intl/intl.dart';

class Database {
  Database(this.uid);

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String uid;

  final CollectionReference<Map<String, dynamic>> userCol =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference<Map<String, dynamic>> postCol =
      FirebaseFirestore.instance.collection('posts');
  late DocumentReference<Map<String, dynamic>> userDoc =
      FirebaseFirestore.instance.collection('users').doc(uid);

  Future getToDoTasks() {
    print("Firing getToDoTasks");
    return userDoc
        .collection('todo')
        .where("allComplete", isEqualTo: false)
        .orderBy("dateCreated", descending: false)
        .get();
  }

  Future getTrackerTasks() {
    print("Firing getTrackerTasks");

    return userDoc
        .collection('trackers')
        .orderBy('dateCreated', descending: true)
        .get();
  }

  Future<void> addToDoTask(toDoTask) async {
    print("Firing addToDoTask");

    await userDoc
        .collection('todo')
        .add(toDoTask.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future<void> editToDoTask(tid, toDoTask) async {
    print("Firing editToDoTask");

    await userDoc
        .collection('todo')
        .doc(tid)
        .update(toDoTask.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future<void> deleteToDoTask(tid) async {
    print("Firing deleteToDoTask");
    await userDoc
        .collection('todo')
        .doc(tid)
        .delete()
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future<void> deleteTrackerTask(tid) async {
    print("Firing deleteTrackerTask");
    await userDoc
        .collection('trackers')
        .doc(tid)
        .delete()
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future<void> completeTask(tid, newDesc) async {
    print("Firing completeTask");

    await userDoc.collection('todo').doc(tid).update({'desc': newDesc});
  }

  Future<void> completeTaskAll(tid, newDesc) async {
    print("Firing completeTaskAll");

    await userDoc.collection('todo').doc(tid).set(
        {'desc': newDesc, 'allComplete': true, 'dateCompleted': DateTime.now()},
        SetOptions(merge: true));
  }

  Future editMilestones(tid, milestoneList) async {
    print("Firing editMilestones");

    await userDoc
        .collection('trackers')
        .doc(tid)
        .update({'milestones': milestoneList});
  }

  //-----------------------------------------------------
  //--------------     FRIENDS --------------------------
  //-----------------------------------------------------
  //
  // KEY: 0 = Sent Request
  //      1 = Received Request
  //      2 = Accepted Friends

  Future<List<QuerySnapshot>> getFriendSearch(email) async {
    print("Firing getFriendSearch");

    List<QuerySnapshot> results = [];
    results
        .add(await userCol.where('email', isGreaterThanOrEqualTo: email).get());
    print(results);
    results.add(await userDoc.collection('friends').get());
    return results;
  }

  Future<void> sendFriendReq(user) async {
    print("Firing sendFriendReq");

    Map<String, dynamic> senderData = {'status': 1};
    await getCurrentUserData()
        .then((value) => senderData.addAll(value.data()!));

    Map<String, dynamic> receiverData = {'status': 0};
    await getUserProfileData(user)
        .then((value) => receiverData.addAll(value.data()!));

    var batch = firestore.batch();
    batch.set(userDoc.collection('friends').doc(user), receiverData);
    batch.set(userCol.doc(user).collection('friends').doc(uid), senderData);
    await batch.commit();
    return;
  }

  Future<void> acceptFriendReq(user) async {
    print("Firing acceptFriendReq");

    var batch = firestore.batch();
    batch.set(userDoc.collection('friends').doc(user), {'status': 2},
        SetOptions(merge: true));
    batch.set(userCol.doc(user).collection('friends').doc(uid), {'status': 2},
        SetOptions(merge: true));
    await batch.commit();
    return;
  }

  Future<void> declineFriendReq(user) async {
    print("Firing declineFriendReq");

    var batch = firestore.batch();
    batch.delete(userCol.doc(user).collection('friends').doc(uid));
    batch.delete(userDoc.collection('friends').doc(user));
    await batch.commit();
    return;
  }

  Future<void> removeFriend(user) async {
    print("Firing removeFriend");

    var batch = firestore.batch();

    await batch.commit();
  }

  Future<Map<dynamic, dynamic>> friendsPageData() async {
    print("Firing friendsPageData");

    Map results = {
      "sentRequests": [],
      "newRequests": [],
      "friendsList": [],
    };

    var friendsFields = await userDoc.collection('friends').get();

    if (friendsFields.docs.length < 1) {
      return results;
    }
    var friendsMap = friendsFields.docs;

    if (friendsMap.isEmpty) {
      return results;
    }

    friendsMap.forEach((element) {
      switch (element['status']) {
        case 0:
          results['sentRequests'].add(element);
          break;
        case 1:
          results['newRequests'].add(element);
          break;
        case 2:
          results['friendsList'].add(element);
          break;
      }
    });

    return results;
  }

  Future<List<String>> getAllFriendsID() async {
    print("Firing getAllFriendsInList");

    List<String> allFriends = [];

    await userDoc.collection('friends').get().then((value) {
      if (value.docs.length < 1) {
        return allFriends;
      }
      value.docs.forEach((doc) {
        if (doc['status'] == 2) {
          allFriends.add(doc.id);
        }
      });
    });
    return allFriends;
  }

  //-----------------------------------------------------
  //--------------  COMMUNITY  --------------------------
  //-----------------------------------------------------
  //

  Future<void> addNewPost(
      Map<String, dynamic> postData, visibility, attachmentType) async {
    print("Firing addNewPost");
    print(postData['attachment']);

    var batch = firestore.batch();
    var newPostDoc = firestore.collection('posts').doc();

    if (visibility != 'Anonymous') {
      await getCurrentUserData().then((value) {
        var data = value.data()!;
        var map = {
          'email': data['email'],
          'name': data['name'],
          'age': data['age'],
          'image': data['image']
        };
        postData.addAll(map);
      });
    } else {
      var map = {
        'email': 'anon@somewhere.com',
        'name': 'Anonymous',
        'age': '0',
        'image': '',
      };
      postData.addAll(map);
    }

    if (attachmentType == 'image') {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("image1" + DateTime.now().toString());
      UploadTask uploadTask = ref.putFile(postData['attachment']);
      await uploadTask.whenComplete(() async {
        postData['attachment'] = await ref.getDownloadURL();
      });
    }

    batch.set(newPostDoc, postData);
    if (visibility == 'Anonymous') {
      batch.set(
          userDoc,
          {
            'anonPosts': FieldValue.arrayUnion([newPostDoc.id])
          },
          SetOptions(merge: true));
    }

    if (visibility != 'Anonymous') {
      batch.set(
          userDoc,
          {
            'posts': FieldValue.arrayUnion([newPostDoc.id])
          },
          SetOptions(merge: true));
      List<String> friendsList = await getAllFriendsID();
      friendsList.forEach((e) {
        batch.set(
            userCol.doc(e),
            {
              'friendFeed': FieldValue.arrayUnion([newPostDoc.id])
            },
            SetOptions(merge: true));
      });
    }

    await batch.commit();

    return;
  }

  Future<List<Map<String, dynamic>>> getCommunityPost(filter, hashtag,
      {loadMore = false}) async {
    // Can add parameter for lazy loading, count number of reloads then
    //postIds sublist accordingly
    print("Firing getCommunityPost");

    List<Map<String, dynamic>> results = [];

    switch (filter) {
      case 'Everyone':
        if (hashtag != '') {
          QuerySnapshot<Map<String, dynamic>> query = await postCol
              .where('uid', isNotEqualTo: uid)
              .where('hashtags', arrayContains: hashtag)
              .orderBy('uid')
              .orderBy('dateCreated', descending: true)
              .get();
          query.docs.forEach((doc) {
            var data = doc.data();
            data['postId'] = doc.id;
            results.add(data);
          });
        } else {
          QuerySnapshot<Map<String, dynamic>> query = await postCol
              .where('uid', isNotEqualTo: uid)
              .orderBy('uid')
              .orderBy('dateCreated', descending: true)
              .get();
          query.docs.forEach((doc) {
            var data = doc.data();
            data['postId'] = doc.id;
            results.add(data);
          });
        }
        return results;
      case 'Friends Only':
        var ids = await userDoc.get().then((value) => value.data());
        if (!ids!.containsKey('friendFeed')) return results;
        var postIds = ids['friendFeed'];
        var chunks = [];
        for (var i = 0; i < postIds.length; i += 10) {
          if (i + 10 > postIds.length) {
            chunks.add(postIds.sublist(i));
            break;
          }
          chunks.add(postIds.sublist(i, i + 10));
        }

        for (var element in chunks) {
          if (hashtag != '') {
            await postCol
                .where(FieldPath.documentId, whereIn: element)
                .where('hashtags', arrayContains: hashtag)
                .get()
                .then((value) {
              value.docs.forEach((doc) {
                var data = doc.data();
                data['postId'] = doc.id;
                results.add(data);
              });
            });
          } else {
            await postCol
                .where(FieldPath.documentId, whereIn: element)
                .get()
                .then((value) {
              value.docs.forEach((doc) {
                var data = doc.data();
                data['postId'] = doc.id;
                results.add(data);
              });
            });
          }
        }
        results.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));
        return results;
      case 'Anonymous':
        if (hashtag != '') {
          QuerySnapshot<Map<String, dynamic>> query = await postCol
              .where('uid', isNotEqualTo: uid)
              .where('visibility', isEqualTo: filter)
              .where('hashtags', arrayContains: hashtag)
              .get();
          query.docs.forEach((doc) {
            var data = doc.data();
            data['postId'] = doc.id;
            results.add(data);
          });
        } else {
          QuerySnapshot<Map<String, dynamic>> query = await postCol
              .where('uid', isNotEqualTo: uid)
              .where('visibility', isEqualTo: filter)
              .get();
          query.docs.forEach((doc) {
            var data = doc.data();
            data['postId'] = doc.id;
            results.add(data);
          });
        }
        return results;
    }
    return results;
  }

  Future postComment(pid, commentText) async {
    print("Firing postComment");

    var userData = await Database(uid).getCurrentUserData().then((value) {
      var data = value.data()!;
      return {'userId': value.id, 'name': data['name'], 'image': data['image']};
    });
    userData.addAll({'comment': commentText, 'dateCreated': DateTime.now()});
    postCol.doc(pid).update({'commentCount': FieldValue.increment(1)});
    await postCol.doc(pid).collection('comments').add(userData);
    return userData;
  }

  Future getComments(pid) async {
    print("Firing getComments");

    return postCol
        .doc(pid)
        .collection('comments')
        .orderBy('dateCreated', descending: true)
        .get();
  }

  Future getAllTasks() async {
    print("Firing getAllTasks");

    return userDoc.collection('todo').orderBy('dateCreated').get();
  }

  //-----------------------------------------------------
  //----------------  PROFILE  --------------------------
  //-----------------------------------------------------
  //

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserData() {
    print("Firing getUserProfileData");
    return userDoc.get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfileData(
      targetUserID) {
    print("Firing getUserProfileData");
    return userCol.doc(targetUserID).get();
  }

  Future uploadProfilePic(image, {hasPic = false, currPicUrl}) async {
    print("Firing uploadProfilePic");

    String downloadURL;
    FirebaseStorage storage = FirebaseStorage.instance;

    if (hasPic) {
      Reference currPic = storage.refFromURL(currPicUrl);
      currPic.delete();
    }
    var batch = firestore.batch();

    Reference ref = storage.ref().child("image1" + DateTime.now().toString());
    UploadTask uploadTask = ref.putFile(image);
    await uploadTask.whenComplete(() async {
      downloadURL = await ref.getDownloadURL();
      batch.update(userDoc, {'image': downloadURL});
      var userDoc1 = await userDoc.get().then((value) => value.data());

      if (userDoc1!.containsKey('posts')) {
        var postList = userDoc1['posts'];
        for (var i = 0; i < postList.length; i++) {
          batch.update(firestore.collection('posts').doc(postList[i]),
              {'image': downloadURL});
        }
      }

      var userFriends = await userDoc.collection('friends').get();

      if (userFriends.size != 0) {
        for (var i = 0; i < userFriends.size; i++) {
          batch.update(
              userCol
                  .doc(userFriends.docs[i].id)
                  .collection('friends')
                  .doc(uid),
              {'image': downloadURL});
        }
      }
      await batch.commit();
    });
  }

  Future removeProfilePic() async {
    print("Firing removeProfilePic");

    var batch = firestore.batch();
    batch.update(userDoc, {'image': ''});

    var userDoc1 = await userDoc.get().then((value) => value.data());

    if (userDoc1!.containsKey('posts')) {
      var postList = userDoc1['posts'];
      for (var i = 0; i < postList.length; i++) {
        batch.update(
            firestore.collection('posts').doc(postList[i]), {'image': ''});
      }
    }

    var userFriends = await userDoc.collection('friends').get();

    if (userFriends.size != 0) {
      for (var i = 0; i < userFriends.size; i++) {
        batch.update(
            userCol.doc(userFriends.docs[i].id).collection('friends').doc(uid),
            {'image': ''});
      }
    }

    await batch.commit();
  }

  Future editUserName(newName) async {
    print("Firing editUserName");

    var batch = firestore.batch();
    batch.update(userDoc, {'name': newName});

    var userDoc1 = await userDoc.get().then((value) => value.data());

    if (userDoc1!.containsKey('posts')) {
      var postList = userDoc1['posts'];
      for (var i = 0; i < postList.length; i++) {
        batch.update(
            firestore.collection('posts').doc(postList[i]), {'name': newName});
      }
    }

    var userFriends = await userDoc.collection('friends').get();

    if (userFriends.size != 0) {
      for (var i = 0; i < userFriends.size; i++) {
        batch.update(
            userCol.doc(userFriends.docs[i].id).collection('friends').doc(uid),
            {'name': newName});
      }
    }

    await batch.commit();
  }

  Future getUserPostsOwnProfile(uid, {loadMore = false}) async {
    print("Firing getUserPosts");

    var results = [];

    var userDoc1 = await userDoc.get().then((value) => value.data());

    if (userDoc1!.containsKey('posts')) {
      var postList = userDoc1['posts'];
      for (var i = 0; i < postList.length; i++) {
        var postData = await postCol.doc(postList[i]).get().then((value) {
          var data = value.data();
          data!['postId'] = value.id;
          return data;
        });
        results.add(postData);
      }
    }

    if (userDoc1.containsKey('anonPosts')) {
      var postList = userDoc1['anonPosts'];
      for (var i = 0; i < postList.length; i++) {
        var postData = await postCol.doc(postList[i]).get().then((value) {
          var data = value.data();
          data!['postId'] = value.id;
          return data;
        });
        results.add(postData);
      }
    }

    results.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));

    return results;
  }

  Future getUserPostsOtherProfile(uid) async {
    print("Firing getUserPosts");

    var results = [];

    var userDoc1 = await userDoc.get();

    if (userDoc1.data()!.containsKey('posts')) {
      var postList = userDoc1.data()!['posts'];
      for (var i = 0; i < postList.length; i++) {
        var postData = await postCol.doc(postList[i]).get().then((value) {
          var data = value.data();
          data!['postId'] = value.id;
          return data;
        });
        results.add(postData);
      }
    }

    results.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));

    return results;
  }

  Stream getPublicToDo(uid) {
    print("Firing getPublicToDo");

    return userCol
        .doc(uid)
        .collection('todo')
        .where('allComplete', isEqualTo: false)
        .where('isPublic', isEqualTo: true)
        .orderBy('dateCreated', descending: true)
        .snapshots();
  }

  Future getHighlightTracker(uid) async {
    print("Firing getHighlightTracker");

    var result;
    await userCol.doc(uid).get().then((value) async {
      var data = value.data();
      if (data!.containsKey('highlightTracker')) {
        if (data['highlightTracker'] != null) {
          result = await getTrackerData(data['highlightTracker']);
        }
      }
    });
    return result;
  }

  Future setHighlightTracker(tid) async {
    print("Firing setHightlightTracker");

    await userCol
        .doc(uid)
        .set({'highlightTracker': tid}, SetOptions(merge: true));
  }

  //-----------------------------------------------------
  //--------------  TRACKER TASK  -----------------------
  //-----------------------------------------------------
  //

  Future addTrackerTask(TrackerTaskModel tracker) async {
    print("Firing addNewTracker");

    await userDoc.collection('trackers').add(tracker.toJson());
  }

  Future editTrackerTask(TrackerTaskModel tracker, tid) async {
    print("Firing editTrackerTask");

    await userDoc
        .collection('trackers')
        .doc(tid)
        .update(tracker.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future checkInTracker(tid, day, note, attachment, ciid) async {
    print("Firing checkInTracker");
    print(tid);

    var newCheckInDoc;
    if (ciid != null) {
      newCheckInDoc = userDoc
          .collection('trackers')
          .doc(tid)
          .collection('checkin')
          .doc(ciid);
    } else {
      newCheckInDoc =
          userDoc.collection('trackers').doc(tid).collection('checkin').doc();
    }

    await newCheckInDoc
        .set({'day': day, 'note': note, 'attachment': attachment}).then(
            (value) async => await userDoc
                    .collection('trackerCheckIn')
                    .doc(newCheckInDoc.id)
                    .set({
                  'dateCreated': DateTime.now(),
                  'day': day,
                  'note': note,
                  'attachment': attachment,
                  'trackerId': tid
                }));
    print(newCheckInDoc.id);
  }

  Future resetTrackerTask(tid, note) async {
    print("FIring resetTrackerTask");

    await userDoc
        .collection('trackers')
        .doc(tid)
        .update({'currStreakDate': DateTime.now()}).then((value) => userDoc
                .collection('trackers')
                .doc(tid)
                .collection('checkin')
                .get()
                .then((snapshot) {
              for (DocumentSnapshot ds in snapshot.docs) {
                ds.reference.delete();
              }
            }));

    await userDoc
        .collection('trackers')
        .doc(tid)
        .collection('resets')
        .add({'resetDate': DateTime.now(), 'note': note});
  }

  Future getTrackerData(tid) async {
    var result = await userDoc
        .collection('trackers')
        .doc(tid)
        .get()
        .then((value) => value.data());

    return result;
  }

  Future getExpandedTrackerData(tid) async {
    print("Firing getExpandedTrackerData");

    var results = {};

    var resetsList = [];
    var query1 = await userDoc
        .collection('trackers')
        .doc(tid)
        .collection('resets')
        .get();
    query1.docs.forEach((doc) {
      resetsList.add(doc.data());
    });

    var checkinList = [];
    var query2 = await userDoc
        .collection('trackers')
        .doc(tid)
        .collection('checkin')
        .get();
    query2.docs.forEach((doc) {
      checkinList.add(doc.data());
    });

    results['resets'] = resetsList;
    results['checkin'] = checkinList;

    return results;
  }

  Future getCheckInButtonData(tid) async {
    return userDoc.collection('trackers').doc(tid).collection('checkin').get();
  }

  Future getTrackerProgressList() async {
    List<Map> progressList = [];

    await userDoc
        .collection('trackerCheckIn')
        .orderBy('dateCreated', descending: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        var currElement = element.data();
        currElement['dateCreatedDay'] = new DateFormat("dd MMM yy").format(
            DateTime.parse(
                (currElement['dateCreated'] as Timestamp).toDate().toString()));
        currElement['dateCreated'] =
            (currElement['dateCreated'] as Timestamp).toDate();
        progressList.add(currElement);
      });
    });
    return progressList;
  }

  //-----------------------------------------------------
  //--------------  PROGRESS LIST  ----------------------
  //-----------------------------------------------------
  //

  Future getTodoProgressList(filter, search) async {
    print("Firing getProgressList");

    List<Map> progressList = [];
    await userDoc
        .collection('todo')
        .where('allComplete', isEqualTo: true)
        .orderBy('dateCompleted', descending: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        var currElement = element.data();
        currElement['taskId'] = element.id;
        currElement['dateCompletedDay'] = new DateFormat("dd MMM yy").format(
            DateTime.parse((currElement['dateCompleted'] as Timestamp)
                .toDate()
                .toString()));
        currElement['dateCompleted'] =
            (currElement['dateCompleted'] as Timestamp).toDate();
        progressList.add(currElement);
      });
    });
    return progressList;

    // var groupByDate = groupBy(progressList,
    //     (Map obj) => obj['dateCompleted'].toString().substring(0, 10));

    // List test = [];

    // groupByDate.forEach((k, v) => test.add([k, v]));
  }

  //-----------------------------------------------------
  //------------  INSTANT MESSAGING  --------------------
  //-----------------------------------------------------
  //

  Stream getChats() {
    return userDoc
        .collection('chats')
        .orderBy('lastMsgTime', descending: true)
        .snapshots();
  }

  Stream getMessages(chatId) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('dateCreated', descending: true)
        .snapshots();
  }

  Future newChat(chatId, peerId) async {
    var user = await Database(uid).getUserProfileData(peerId);
    var userData = user.data()!;
    await userDoc.collection('chats').doc(peerId).set({
      'chatId': chatId,
      'peerId': peerId,
      'lastMsg': '',
      'lastMsgTime': '',
      'user': {
        'name': userData['name'],
        'email': userData['email'],
        'image': userData['image']
      },
      'unreadCount': 0
    });

    var self = await Database(uid).getCurrentUserData();
    var selfData = self.data()!;
    await userCol.doc(peerId).collection('chats').doc(uid).set({
      'chatId': chatId,
      'peerId': uid,
      'lastMsg': '',
      'lastMsgTime': '',
      'user': {
        'name': selfData['name'],
        'email': selfData['email'],
        'image': selfData['image']
      },
      'unreadCount': 0
    });
  }

  Future sendMessage(chatId, message, idFrom, idTo) async {
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'message': message,
      'idFrom': idFrom,
      'idTo': idTo,
      'dateCreated': DateTime.now()
    }).then((value) {
      userDoc.collection('chats').doc(idTo).set(
          {'lastMsg': message, 'lastMsgTime': DateTime.now()},
          SetOptions(merge: true));
      userCol.doc(idTo).collection('chats').doc(idFrom).set(
          {'lastMsg': message, 'lastMsgTime': DateTime.now()},
          SetOptions(merge: true));
    });
  }

  Future chattingWith(value) async {
    await userDoc.set({'chattingWith': value}, SetOptions(merge: true));
  }

  Future resetUnread(peerId) async {
    await userDoc
        .collection('chats')
        .doc(peerId)
        .set({'unreadCount': 0}, SetOptions(merge: true));
  }
}
