import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shizen_app/models/trackerTask.dart';
import 'package:intl/intl.dart';
import 'package:shizen_app/utils/notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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
        .orderBy("dateCreated", descending: true)
        .get();
  }

  Future getTrackerTasks() {
    print("Firing getTrackerTasks");

    return userDoc
        .collection('trackers')
        .orderBy('dateCreated', descending: true)
        .get();
  }

  Future<void> addToDoTask(toDoTask, reminder) async {
    print("Firing addToDoTask");
    var taskData = toDoTask.toJson();
    var notifDesc = '';
    for (var i = 0; i < taskData['desc'].length; i++) {
      notifDesc += '${taskData['desc'][i]['task']}';
      if (i != taskData['desc'].length - 1) {
        notifDesc += ', ';
      }
    }
    await userDoc.collection('todo').add(taskData).then((doc) async {
      if (reminder != null) {
        await NotificationService().showNotification(
            doc.id, 'REMINDER: ${taskData['title']}', notifDesc, reminder);
      } else {
        await NotificationService()
            .flutterLocalNotificationsPlugin
            .cancel(doc.id.hashCode);
      }
    }).whenComplete(() => print("Done"));
  }

  Future<void> editToDoTask(tid, toDoTask, reminder) async {
    print("Firing editToDoTask");
    var taskData = toDoTask.toJson();
    var notifDesc = '';
    for (var i = 0; i < taskData['desc'].length; i++) {
      notifDesc += '${taskData['desc'][i]['task']}';
      if (i != taskData['desc'].length - 1) {
        notifDesc += ', ';
      }
    }
    await userDoc
        .collection('todo')
        .doc(tid)
        .update(taskData)
        .then((doc) async {
      if (reminder != null) {
        await NotificationService().showNotification(
            tid, 'REMINDER: ${taskData['title']}', notifDesc, reminder);
      } else {
        await NotificationService()
            .flutterLocalNotificationsPlugin
            .cancel(tid.hashCode);
      }
    }).whenComplete(() => print("Done"));
  }

  Future<void> deleteToDoTask(tid) async {
    print("Firing deleteToDoTask");
    await userDoc.collection('todo').doc(tid).delete().then((value) async {
      await NotificationService()
          .flutterLocalNotificationsPlugin
          .cancel(tid.hashCode);
    }).whenComplete(() => print("Done"));
  }

  Future<void> deleteTrackerTask(tid) async {
    print("Firing deleteTrackerTask");

    var userData = await userDoc.get();
    if (userData.data()!.containsKey('highlightTracker')) {
      if (userData.data()!['highlightTracker'] == tid) {
        await userDoc.set({'highlightTracker': null}, SetOptions(merge: true));
      }
    }

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

    await userDoc.collection('todo').doc(tid).set({
      'desc': newDesc,
      'allComplete': true,
      'dateCompleted': Timestamp.now()
    }, SetOptions(merge: true)).then((value) async =>
        await NotificationService()
            .flutterLocalNotificationsPlugin
            .cancel(tid.hashCode));
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
    await getCurrentUserData().then((value) {
      var data = value.data()!;
      senderData.addAll({
        'email': data['email'],
        'name': data['name'],
        'age': data['age'],
        'image': data['image']
      });
    });

    Map<String, dynamic> receiverData = {'status': 0};
    await getUserProfileData(user).then((value) {
      var data = value.data()!;
      receiverData.addAll({
        'email': data['email'],
        'name': data['name'],
        'age': data['age'],
        'image': data['image']
      });
    });

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
    batch.set(userDoc, {'friendCount': FieldValue.increment(1)},
        SetOptions(merge: true));
    batch.set(userCol.doc(user), {'friendCount': FieldValue.increment(1)},
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
    batch.delete(userCol.doc(user).collection('friends').doc(uid));
    batch.delete(userDoc.collection('friends').doc(user));
    batch.set(userDoc, {'friendCount': FieldValue.increment(-1)},
        SetOptions(merge: true));
    batch.set(userCol.doc(user), {'friendCount': FieldValue.increment(-1)},
        SetOptions(merge: true));
    await batch.commit();
  }

  Stream getNewFriendRequestsList() {
    print('Frinfeisnfoiesjf');
    return userDoc
        .collection('friends')
        .where('status', isEqualTo: 1)
        .snapshots()
        .map((query) => query.docs);
  }

  Future getFriendsList([loadMore = false, lastDoc]) async {
    print("Firing friendsPageData");

    var query;
    var results = [];

    if (!loadMore) {
      query = await userDoc
          .collection('friends')
          .where('status', isEqualTo: 2)
          .orderBy('name')
          .limit(10)
          .get();
    } else {
      query = await userDoc
          .collection('friends')
          .where('status', isEqualTo: 2)
          .orderBy('name')
          .limit(10)
          .startAfterDocument(lastDoc!)
          .get();
    }
    var friendCount = 0;
    if (!loadMore) {
      friendCount =
          await userDoc.get().then((value) => value.data()?['friendCount']);
    }
    if (query.docs.length > 0) {
      lastDoc = query.docs.last;
    }
    query.docs.forEach((doc) {
      var data = doc.data();
      data['uid'] = doc.id;
      results.add(data);
    });
    return [results, friendCount, lastDoc];
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

    // IF visibility is EVERYONE or FRIENDS ONLY
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

    batch.set(
        userDoc,
        {
          'posts': FieldValue.arrayUnion([newPostDoc.id])
        },
        SetOptions(merge: true));

    if (visibility != 'Anonymous') {
      batch.set(
          userDoc,
          {
            'friendsOnlyPosts': FieldValue.arrayUnion([
              {'postId': newPostDoc.id, 'dateCreated': postData['dateCreated']},
            ])
          },
          SetOptions(merge: true));
    }

    // TODO: Implement cloud function to check if array is >100 length

    await batch.commit();

    return;
  }

  Future getCommunityPostEveryone(hashtag, [loadMore = false, lastDoc]) async {
    // Can add parameter for lazy loading, count number of reloads then
    //postIds sublist accordingly
    print("Firing getCommunityPost");

    List<Map<String, dynamic>> results = [];
    QuerySnapshot<Map<String, dynamic>> query;

    if (!loadMore) {
      query = await postCol
          .orderBy('dateCreated', descending: true)
          .where('visibility', isEqualTo: 'Everyone')
          .where('hashtags', arrayContains: hashtag != '' ? hashtag : null)
          .limit(10)
          .get();
    } else {
      query = await postCol
          .orderBy('dateCreated', descending: true)
          .where('visibility', isEqualTo: 'Everyone')
          .where('hashtags', arrayContains: hashtag != '' ? hashtag : null)
          .limit(10)
          .startAfterDocument(lastDoc!)
          .get();
    }
    if (query.docs.length > 0) {
      lastDoc = query.docs.last;
    }
    query.docs.forEach((doc) {
      var data = doc.data();
      data['postId'] = doc.id;
      results.add(data);
    });
    // TODO: Add friend posts inside of everyone as well (Example: max 3 days ago)
    return [results, lastDoc];
  }

  Future getCommunityPostFriendsOnlyFirstLoad(hashtag) async {
    List<String> friendIds = [];
    await userDoc
        .collection('friends')
        .where('status', isEqualTo: 2)
        .get()
        .then((value) => value.docs.forEach((element) {
              friendIds.add(element.id);
            }));

    var postIds = [];
    // TODO: optimization
    for (var i = 0; i < friendIds.length; i++) {
      await userCol.doc(friendIds[i]).get().then(
          (value) => postIds.addAll(value.data()?['friendsOnlyPosts'] ?? []));

      postIds.sort((a, b) => b['dateCreated'].compareTo(a['dateCreated']));
    }

    var posts = [];
    var lastIndex = 0;

    for (var i = 0; i < postIds.length; i++) {
      lastIndex++;
      if (posts.length < 10) {
        print(postIds[i]['postId']);
        await postCol.doc(postIds[i]['postId']).get().then((value) {
          var currDoc = value.data();
          if (hashtag != '') {
            if ((currDoc!['hashtags'].firstWhere((item) => item == hashtag,
                    orElse: () => null)) !=
                null) {
              print('TYRESUIO YRESOUHR');
              currDoc['postId'] = value.id;
              posts.add(currDoc);
            }
          } else {
            currDoc!['postId'] = value.id;
            posts.add(currDoc);
          }
        });
      } else {
        return [postIds, posts, lastIndex];
      }
    }
    return [postIds, posts, lastIndex];
  }

  Future getCommunityPostFriendsOnly(postIds, hashtag, [lastIndex = 0]) async {
    var result = [];
    for (var i = lastIndex; i < postIds.length; i++) {
      lastIndex++;
      if (result.length < 10) {
        await postCol.doc(postIds[i]['postId']).get().then((value) {
          var currDoc = value.data();
          if (hashtag != '') {
            if (currDoc!['hashtags'].firstWhere((item) => item == hashtag,
                    orElse: () => null) !=
                null) {
              print('ESESRESR');
              currDoc['postId'] = value.id;
              result.add(currDoc);
            }
          } else {
            currDoc!['postId'] = value.id;
            result.add(currDoc);
          }
        });
      } else {
        return [result, lastIndex];
      }
    }
    return [result, lastIndex];
  }

  Future getCommunityPostAnonymous(hashtag, [loadMore = false, lastDoc]) async {
    List<Map<String, dynamic>> results = [];
    QuerySnapshot<Map<String, dynamic>> query;

    if (!loadMore) {
      query = await postCol
          .orderBy('dateCreated', descending: true)
          .where('visibility', isEqualTo: 'Anonymous')
          .where('hashtags', arrayContains: hashtag != '' ? hashtag : null)
          .limit(10)
          .get();
    } else {
      query = await postCol
          .orderBy('dateCreated', descending: true)
          .where('visibility', isEqualTo: 'Anonymous')
          .where('hashtags', arrayContains: hashtag != '' ? hashtag : null)
          .limit(10)
          .startAfterDocument(lastDoc!)
          .get();
    }
    if (query.docs.length > 0) {
      lastDoc = query.docs.last;
    }
    query.docs.forEach((doc) {
      var data = doc.data();
      data['postId'] = doc.id;
      results.add(data);
    });
    return [results, lastDoc];
  }

  Future postComment(pid, puid, commentText) async {
    print("Firing postComment");

    var userData = await Database(uid).getCurrentUserData().then((value) {
      var data = value.data()!;
      return {'userId': value.id, 'name': data['name'], 'image': data['image']};
    });
    userData.addAll({
      'comment': commentText,
      'dateCreated': Timestamp.now(),
      'posterUid': puid
    });
    postCol.doc(pid).update({'commentCount': FieldValue.increment(1)});
    await postCol.doc(pid).collection('comments').add(userData);
    return userData;
  }

  Future removeComment(pid, cid) async {
    print("Firing removeComment");

    await postCol.doc(pid).collection('comments').doc(cid).delete();
    await postCol.doc(pid).update({'commentCount': FieldValue.increment(-1)});
  }

  Stream getComments(pid) {
    print("Firing getComments");

    return postCol
        .doc(pid)
        .collection('comments')
        .orderBy('dateCreated', descending: true)
        .snapshots();
  }

  Future getAllTasks() async {
    print("Firing getAllTasks");

    return userDoc.collection('todo').orderBy('dateCreated').get();
  }

  Future getAllTrackers() async {
    return userDoc.collection('trackers').orderBy('dateCreated').get();
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

  Future getTrackerCheckInCount(targetUID) {
    return userCol
        .doc(targetUID)
        .collection('progress')
        .where('type', isEqualTo: 'tracker')
        .get()
        .then((value) => value.docs.length);
  }

  Future getCompletedTasksCount(targetUID) {
    return userCol
        .doc(targetUID)
        .collection('todo')
        .where('allComplete', isEqualTo: true)
        .get()
        .then((value) => value.docs.length);
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
    var taskId;
    await userCol.doc(uid).get().then((value) async {
      var data = value.data();
      if (data!.containsKey('highlightTracker')) {
        if (data['highlightTracker'] != null) {
          result = await getTrackerData(data['highlightTracker']);
          taskId = data['highlightTracker'];
        }
      }
    });
    return [result, taskId];
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

    await userDoc
        .collection('trackers')
        .add(tracker.toJson())
        .then((doc) async {
      if (tracker.reminder != null) {
        DateTime reminder = tracker.reminder!;
        await NotificationService().showTrackerDailyNotification(
          doc.id,
          'DAILY REMINDER: ${tracker.title}',
          'Keep going, you\'ll get there eventually!',
          reminder,
        );
      } else {
        await NotificationService()
            .flutterLocalNotificationsPlugin
            .cancel(doc.id.hashCode);
      }
      print('Nice');
    });
  }

  Future editTrackerTask(TrackerTaskModel tracker, tid) async {
    print("Firing editTrackerTask");

    await userDoc
        .collection('trackers')
        .doc(tid)
        .update(tracker.toJson())
        .then((doc) async {
          if (tracker.reminder != null) {
            DateTime reminder = tracker.reminder!;
            await NotificationService().showTrackerDailyNotification(
              tid,
              'DAILY REMINDER: ${tracker.title}',
              'Keep going, you\'ll get there eventually!',
              reminder,
            );
          } else {
            await NotificationService()
                .flutterLocalNotificationsPlugin
                .cancel(tid.hashCode);
          }
        })
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future checkInTracker(tid, name, day, note, attachment, ciid) async {
    print("Firing checkInTracker");

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

    await newCheckInDoc.set({
      'dateCreated': DateTime.now(),
      'day': day,
      'note': note,
      'attachment': attachment
    }).then((value) async =>
        await userDoc.collection('progress').doc(newCheckInDoc.id).set({
          'dateCreated': DateTime.now(),
          'type': 'tracker',
          'day': day,
          'note': note,
          'attachment': attachment,
          'trackerName': name
        }));
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

  Future getLatestCheckInData(tid) async {
    return userDoc
        .collection('trackers')
        .doc(tid)
        .collection('checkin')
        .orderBy('dateCreated', descending: true)
        .limit(1)
        .get();
  }

  Future getTrackerProgressList(filter, search) async {
    List<Map> progressList = [];

    await userDoc
        .collection('progress')
        .where('type', isEqualTo: 'tracker')
        .where('dateCreated', isGreaterThanOrEqualTo: filter?.startDate)
        .where('dateCreated',
            isLessThanOrEqualTo: filter?.endDate?.add(Duration(days: 1)) ??
                filter?.startDate.add(Duration(days: 1)))
        .orderBy('dateCreated', descending: false)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        var currElement = element.data();
        currElement['dateCreated'] =
            (currElement['dateCreated'] as Timestamp).toDate();
        progressList.add(currElement);
      });
    });
    return progressList;
  }

  Future cancelActiveNotification(type, id) async {
    await userDoc.collection(type).doc(id).update({'reminder': null});
  }

  //-----------------------------------------------------
  //--------------  PROGRESS LIST  ----------------------
  //-----------------------------------------------------
  //

  Future getProgressList(filter, search) async {
    print("Firing getProgressList");

    List<Map> progressList = [];

    await userDoc
        .collection('todo')
        .where('allComplete', isEqualTo: true)
        .where('dateCompleted', isGreaterThanOrEqualTo: filter?.startDate)
        .where('dateCompleted',
            isLessThanOrEqualTo: filter?.endDate?.add(Duration(days: 1)) ??
                filter?.startDate.add(Duration(days: 1)))
        .get()
        .then((value) {
      value.docs.forEach((element) {
        var currElement = element.data();
        currElement['type'] = 'todo';
        currElement['taskId'] = element.id;
        currElement['dateCompleted'] =
            (currElement['dateCompleted'] as Timestamp).toDate();
        progressList.add(currElement);
      });
    });

    await userDoc
        .collection('progress')
        .where('dateCreated', isGreaterThanOrEqualTo: filter?.startDate)
        .where('dateCreated',
            isLessThanOrEqualTo: filter?.endDate?.add(Duration(days: 1)) ??
                filter?.startDate.add(Duration(days: 1)))
        .get()
        .then((value) {
      value.docs.forEach((element) {
        var currElement = element.data();
        currElement['type'] = 'tracker';
        currElement['dateCompleted'] =
            (currElement['dateCreated'] as Timestamp).toDate();
        progressList.add(currElement);
      });
    });
    var result = progressList;

    return result;
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
    print("Firing getMessages");
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('dateCreated', descending: true)
        .limit(30)
        .snapshots();
  }

  Future loadMoreMsgs(chatId, lastMsgDoc) {
    return firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('dateCreated', descending: true)
        .startAfterDocument(lastMsgDoc)
        .limit(15)
        .get();
  }

  Future newChat(chatId, peerId) async {
    var user = await Database(uid).getUserProfileData(peerId);
    var userData = user.data()!;
    await userDoc.collection('chats').doc(peerId).set({
      'chatId': chatId,
      'peerId': peerId,
      'lastMsg': '',
      'lastMsgTime': null,
      'lastMsgSender': null,
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
      'lastMsgTime': null,
      'lastMsgSender': null,
      'user': {
        'name': selfData['name'],
        'email': selfData['email'],
        'image': selfData['image']
      },
      'unreadCount': 0
    });
  }

  Future sendMessage(chatId, message, idFrom, idTo, attachment) async {
    var time = FieldValue.serverTimestamp();
    await firestore.collection('chats').doc(chatId).collection('messages').add({
      'message': message,
      'idFrom': idFrom,
      'idTo': idTo,
      'dateCreated': time,
      'attachment': attachment
    }).then((value) {
      userDoc.collection('chats').doc(idTo).set(
          {'lastMsg': message, 'lastMsgTime': time, 'lastMsgSender': idFrom},
          SetOptions(merge: true));
      userCol.doc(idTo).collection('chats').doc(idFrom).set(
          {'lastMsg': message, 'lastMsgTime': time, 'lastMsgSender': idFrom},
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

  Stream getUnreadMessageCount() {
    return userDoc
        .collection('chats')
        .where('unreadCount', isGreaterThan: 0)
        .snapshots();
  }
}
