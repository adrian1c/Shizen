import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shizen_app/models/todoTask.dart';
import 'package:path/path.dart';
import 'package:loader_overlay/loader_overlay.dart';

class Database {
  Database(this.uid);

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String uid;

  Stream getToDoTasks() {
    print("Firing getToDoTasks");
    return firestore
        .collection('tasks')
        .doc(uid)
        .collection('todo')
        .where("isComplete", isEqualTo: false)
        .orderBy("dateCreated", descending: true)
        .snapshots();
  }

  Stream getTrackerTasks() {
    print("Firing getTrackerTasks");
    return firestore
        .collection('tasks')
        .doc(uid)
        .collection('tracker')
        .snapshots();
  }

  Future<void> addToDoTask(toDoTask) async {
    print("Firing addToDoTask");
    await firestore
        .collection('tasks')
        .doc(uid)
        .collection('todo')
        .add(toDoTask.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  Future<void> deleteToDoTask(toDoTaskID) async {
    print("Firing deleteToDoTask");
    await firestore
        .collection('tasks')
        .doc(uid)
        .collection('todo')
        .doc(toDoTaskID)
        .delete()
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }

  //-----------------------------------------------------
  //--------------     FRIENDS --------------------------
  //-----------------------------------------------------
  //
  // KEY: 0 = Sent Request
  //      1 = Received Request
  //      2 = Accepted Friends

  Future<QuerySnapshot> getFriendSearch(email) {
    print("Firing getFriendSearch");
    return firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where(FieldPath.documentId, isNotEqualTo: uid)
        .get();
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
    batch.commit();
  }

  Future<void> acceptFriendReq(user) async {
    print("Firing acceptFriendReq");

    var userCollection = firestore.collection('users');

    var batch = firestore.batch();
    batch.set(userCollection.doc(uid).collection('friends').doc(user),
        {'status': 2}, SetOptions(merge: true));
    batch.set(userCollection.doc(user).collection('friends').doc(uid),
        {'status': 2}, SetOptions(merge: true));
    batch.commit();
  }

  Future<void> declineFriendReq(user) async {
    print("Firing declineFriendReq");

    var userCollection = firestore.collection('users');

    var batch = firestore.batch();
    batch.delete(userCollection.doc(user).collection('friends').doc(uid));
    batch.delete(userCollection.doc(uid).collection('friends').doc(user));
    batch.commit();
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

    var batch = firestore.batch();
    var newPostDoc = firestore.collection('posts').doc();

    if (visibility != 'Anonymous') {
      await getCurrentUserData().then((value) {
        var data = value.data()!;
        var map = {
          'email': data['email'],
          'name': data['name'],
          'age': data['age']
        };
        postData.addAll(map);
      });
    } else {
      var map = {
        'email': 'anon@somewhere.com',
        'name': 'Anonymous',
        'age': '0'
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

    batch.commit();
  }

  Future<List<Map<String, dynamic>>> getCommunityPost(filter) async {
    // Can add parameter for lazy loading, count number of reloads then
    //postIds sublist accordingly
    print("Firing getCommunityPost");

    List<Map<String, dynamic>> results = [];

    switch (filter) {
      case 'Everyone':
        QuerySnapshot<Map<String, dynamic>> query = await firestore
            .collection('posts')
            .where('uid', isNotEqualTo: uid)
            .get();
        query.docs.forEach((doc) => results.add(doc.data()));
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
          var result = await firestore
              .collection('posts')
              .where(FieldPath.documentId, whereIn: element)
              .get()
              .then((value) {
            value.docs.forEach((doc) => results.add(doc.data()));
          });
        }

        print(results);
        return results;
      case 'Anonymous':
        QuerySnapshot<Map<String, dynamic>> query = await firestore
            .collection('posts')
            .where('visibility', isEqualTo: filter)
            .get();
        query.docs.forEach((doc) => results.add(doc.data()));
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

  Future uploadProfilePic(BuildContext context, image) async {
    print("Firing uploadProfilePic");

    context.loaderOverlay.show();

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

    context.loaderOverlay.hide();
  }
}
