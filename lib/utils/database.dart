import 'dart:io';

import 'package:shizen_app/modules/tasks/addtracker.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shizen_app/models/todoTask.dart';
import 'package:shizen_app/models/trackerTask.dart';

import 'package:path/path.dart';

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

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    await userDoc
        .collection('todo')
        .add(toDoTask.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));

    OneContext().hideProgressIndicator();
  }

  Future<void> editToDoTask(tid, toDoTask) async {
    print("Firing editToDoTask");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    await userDoc
        .collection('todo')
        .doc(tid)
        .update(toDoTask.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));

    OneContext().hideProgressIndicator();
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

  Future<void> addNewPost(Map<String, dynamic> postData, visibility) async {
    print("Firing addNewPost");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

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

    batch.set(newPostDoc, postData);
    batch.set(
        userDoc,
        {
          'posts': FieldValue.arrayUnion([newPostDoc.id])
        },
        SetOptions(merge: true));

    if (visibility != 'Anonymous') {
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

    OneContext().hideProgressIndicator();

    return;
  }

  Future<List<Map<String, dynamic>>> getCommunityPost(filter, hashtag) async {
    // Can add parameter for lazy loading, count number of reloads then
    //postIds sublist accordingly
    print("Firing getCommunityPost");

    List<Map<String, dynamic>> results = [];

    switch (filter) {
      case 'Everyone':
        if (hashtag != '') {
          QuerySnapshot<Map<String, dynamic>> query = await postCol
              .where('uid', isNotEqualTo: uid)
              .where('hashtags', arrayContainsAny: hashtag)
              .get();
          query.docs.forEach((doc) => results.add(doc.data()));
        } else {
          QuerySnapshot<Map<String, dynamic>> query =
              await postCol.where('uid', isNotEqualTo: uid).get();
          query.docs.forEach((doc) => results.add(doc.data()));
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
              value.docs.forEach((doc) => results.add(doc.data()));
            });
          } else {
            await postCol
                .where(FieldPath.documentId, whereIn: element)
                .get()
                .then((value) {
              value.docs.forEach((doc) => results.add(doc.data()));
            });
          }
        }
        return results;
      case 'Anonymous':
        if (hashtag != '') {
          QuerySnapshot<Map<String, dynamic>> query = await postCol
              .where('uid', isNotEqualTo: uid)
              .where('visibility', isEqualTo: filter)
              .where('hashtags', arrayContains: hashtag)
              .get();
          query.docs.forEach((doc) => results.add(doc.data()));
        } else {
          QuerySnapshot<Map<String, dynamic>> query = await postCol
              .where('uid', isNotEqualTo: uid)
              .where('visibility', isEqualTo: filter)
              .get();
          query.docs.forEach((doc) => results.add(doc.data()));
        }
        return results;
    }
    return results;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserData() {
    print("Firing getUserProfileData");
    return userDoc.get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfileData(
      targetUserID) {
    print("Firing getUserProfileData");
    return userCol.doc(targetUserID).get();
  }

  Future uploadProfilePic(image) async {
    print("Firing uploadProfilePic");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    File imageFile = image;
    FirebaseStorage storage = FirebaseStorage.instance;
    final fileName = basename(imageFile.path);
    final destination = 'files/$fileName';

    var batch = firestore.batch();

    try {
      final ref = storage.ref(destination).child(uid);
      await ref.putFile(imageFile);
      var downloadURL = await ref.getDownloadURL();
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
    } catch (e) {
      print(e);
    }

    OneContext().hideProgressIndicator();
  }

  Future removeProfilePic() async {
    print("Firing removeProfilePic");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

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

    OneContext().hideProgressIndicator();
  }

  Future editUserName(newName) async {
    print("Firing editUserName");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

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

    OneContext().hideProgressIndicator();
  }

  Future getUserPosts(uid) async {
    print("Firing getUserPosts");

    var results = [];

    var userDoc1 = await userDoc.get();

    if (userDoc1.data()!.containsKey('posts')) {
      var postList = userDoc1.data()!['posts'];
      for (var i = 0; i < postList.length; i++) {
        var postData = await postCol.doc(postList[i]).get();
        results.add(postData.data());
      }
    }

    return results;
  }

  //-----------------------------------------------------
  //--------------  TRACKER TASK  -----------------------
  //-----------------------------------------------------
  //

  Future addTrackerTask(TrackerTask tracker) async {
    print("Firing addNewTracker");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    await userDoc.collection('trackers').add(tracker.toJson());

    OneContext().hideProgressIndicator();
  }

  //-----------------------------------------------------
  //--------------  PROGRESS LIST  ----------------------
  //-----------------------------------------------------
  //

  Future getProgressList(filter, search) async {
    print("Firing getProgressList");

    return userDoc
        .collection('todo')
        .where('allComplete', isEqualTo: true)
        .orderBy('dateCompleted', descending: false)
        .get();
  }
}
