import 'dart:io';

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

  Stream getToDoTasks() {
    print("Firing getToDoTasks");
    return firestore
        .collection('users')
        .doc(uid)
        .collection('todo')
        .where("isComplete", isEqualTo: false)
        .orderBy("dateCreated", descending: true)
        .snapshots();
  }

  Stream getTrackerTasks() {
    print("Firing getTrackerTasks");

    var userCollection = firestore.collection('users');

    return userCollection.doc(uid).collection('trackers').snapshots();
  }

  Future<void> addToDoTask(toDoTask) async {
    print("Firing addToDoTask");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    await firestore
        .collection('users')
        .doc(uid)
        .collection('todo')
        .add(toDoTask.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));

    OneContext().hideProgressIndicator();
  }

  Future<void> editToDoTask(tid, toDoTask) async {
    print("Firing editToDoTask");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    await firestore
        .collection('users')
        .doc(uid)
        .collection('todo')
        .doc(tid)
        .set(toDoTask, SetOptions(merge: true))
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));

    OneContext().hideProgressIndicator();
  }

  Future<void> deleteToDoTask(tid) async {
    print("Firing deleteToDoTask");
    await firestore
        .collection('users')
        .doc(uid)
        .collection('todo')
        .doc(tid)
        .delete()
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future<void> deleteTrackerTask(tid) async {
    print("Firing deleteTrackerTask");
    await firestore
        .collection('users')
        .doc(uid)
        .collection('trackers')
        .doc(tid)
        .delete()
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future<void> completeTask(tid) async {
    print("Firing completeTask");

    await firestore
        .collection('users')
        .doc(uid)
        .collection('todo')
        .doc(tid)
        .update({'isComplete': true});
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
    results.add(await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where(FieldPath.documentId, isNotEqualTo: uid)
        .get());
    print(results);
    results.add(await firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .get());
    return results;
  }

  Future<void> sendFriendReq(user) async {
    print("Firing sendFriendReq");

    var userCollection = firestore.collection('users');

    Map<String, dynamic> senderData = {'status': 1};
    await getCurrentUserData()
        .then((value) => senderData.addAll(value.data()!));

    Map<String, dynamic> receiverData = {'status': 0};
    await getUserProfileData(user)
        .then((value) => receiverData.addAll(value.data()!));

    var batch = firestore.batch();
    batch.set(
        userCollection.doc(uid).collection('friends').doc(user), receiverData);
    batch.set(
        userCollection.doc(user).collection('friends').doc(uid), senderData);
    await batch.commit();
    return;
  }

  Future<void> acceptFriendReq(user) async {
    print("Firing acceptFriendReq");

    var userCollection = firestore.collection('users');

    var batch = firestore.batch();
    batch.set(userCollection.doc(uid).collection('friends').doc(user),
        {'status': 2}, SetOptions(merge: true));
    batch.set(userCollection.doc(user).collection('friends').doc(uid),
        {'status': 2}, SetOptions(merge: true));
    await batch.commit();
    return;
  }

  Future<void> declineFriendReq(user) async {
    print("Firing declineFriendReq");

    var userCollection = firestore.collection('users');

    var batch = firestore.batch();
    batch.delete(userCollection.doc(user).collection('friends').doc(uid));
    batch.delete(userCollection.doc(uid).collection('friends').doc(user));
    await batch.commit();
    return;
  }

  Future<Map<dynamic, dynamic>> friendsPageData() async {
    print("Firing friendsPageData");

    var userCollection = firestore.collection('users');

    Map results = {
      "sentRequests": [],
      "newRequests": [],
      "friendsList": [],
    };

    var friendsFields =
        await userCollection.doc(uid).collection('friends').get();

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

    var userCollection = firestore.collection('users');

    await userCollection.doc(uid).collection('friends').get().then((value) {
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
        firestore.collection('users').doc(uid),
        {
          'posts': FieldValue.arrayUnion([newPostDoc.id])
        },
        SetOptions(merge: true));

    if (visibility != 'Anonymous') {
      List<String> friendsList = await getAllFriendsID();
      friendsList.forEach((e) {
        batch.set(
            firestore.collection('users').doc(e),
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
          QuerySnapshot<Map<String, dynamic>> query = await firestore
              .collection('posts')
              .where('uid', isNotEqualTo: uid)
              .where('hashtags', arrayContains: hashtag)
              .get();
          query.docs.forEach((doc) => results.add(doc.data()));
        } else {
          QuerySnapshot<Map<String, dynamic>> query = await firestore
              .collection('posts')
              .where('uid', isNotEqualTo: uid)
              .get();
          query.docs.forEach((doc) => results.add(doc.data()));
        }
        return results;
      case 'Friends Only':
        var ids = await firestore
            .collection('users')
            .doc(uid)
            .get()
            .then((value) => value.data());
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
            await firestore
                .collection('posts')
                .where(FieldPath.documentId, whereIn: element)
                .where('hashtags', arrayContains: hashtag)
                .get()
                .then((value) {
              value.docs.forEach((doc) => results.add(doc.data()));
            });
          } else {
            await firestore
                .collection('posts')
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
          QuerySnapshot<Map<String, dynamic>> query = await firestore
              .collection('posts')
              .where('uid', isNotEqualTo: uid)
              .where('visibility', isEqualTo: filter)
              .where('hashtags', arrayContains: hashtag)
              .get();
          query.docs.forEach((doc) => results.add(doc.data()));
        } else {
          QuerySnapshot<Map<String, dynamic>> query = await firestore
              .collection('posts')
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
    return firestore.collection('users').doc(uid).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfileData(
      targetUserID) {
    print("Firing getUserProfileData");
    return firestore.collection('users').doc(targetUserID).get();
  }

  Future uploadProfilePic(image) async {
    print("Firing uploadProfilePic");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    var userCollection = firestore.collection('users');

    File imageFile = image;
    FirebaseStorage storage = FirebaseStorage.instance;
    final fileName = basename(imageFile.path);
    final destination = 'files/$fileName';

    try {
      final ref = storage.ref(destination).child(uid);
      await ref.putFile(imageFile);
      await userCollection
          .doc(uid)
          .set({'image': await ref.getDownloadURL()}, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }

    OneContext().hideProgressIndicator();
  }

  Future editUserName(newName) async {
    print("Firing editUserName");

    OneContext().showProgressIndicator(builder: (_) => LoaderOverlay());

    var batch = firestore.batch();
    var userCollection = firestore.collection('users');
    batch.update(userCollection.doc(uid), {'name': newName});

    var userDoc =
        await userCollection.doc(uid).get().then((value) => value.data());

    if (userDoc!.containsKey('posts')) {
      var postList = userDoc['posts'];
      for (var i = 0; i < postList.length; i++) {
        batch.update(
            firestore.collection('posts').doc(postList[i]), {'name': newName});
      }
    }

    var userFriends = await userCollection.doc(uid).collection('friends').get();

    if (userFriends.size != 0) {
      for (var i = 0; i < userFriends.size; i++) {
        batch.update(
            userCollection
                .doc(userFriends.docs[i].id)
                .collection('friends')
                .doc(uid),
            {'name': newName});
      }
    }

    await batch.commit();

    OneContext().hideProgressIndicator();
  }

  Future getUserPosts(uid) async {
    print("Firing getUserPosts");

    var results = [];
    var userCollection = firestore.collection('users');

    var userDoc = await userCollection.doc(uid).get();

    if (userDoc.data()!.containsKey('posts')) {
      var postList = userDoc.data()!['posts'];
      for (var i = 0; i < postList.length; i++) {
        var postData =
            await firestore.collection('posts').doc(postList[i]).get();
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

    var userCollection = firestore.collection('users');

    await userCollection.doc(uid).collection('trackers').add(tracker.toJson());

    OneContext().hideProgressIndicator();
  }
}
