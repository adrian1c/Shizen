import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shizen_app/models/todoTask.dart';

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

  Future<QuerySnapshot> getFriendSearch(email) {
    print("Firing getFriendSearch");
    return firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .where(FieldPath.documentId, isNotEqualTo: uid)
        .get();
  }

  //-----------------------------------------------------
  //--------------     FRIENDS --------------------------
  //-----------------------------------------------------
  //
  // KEY: 0 = Sent Request
  //      1 = Received Request
  //      2 = Accepted Friends

  Future<void> sendFriendReq(user) async {
    print("Firing sendFriendReq");
    var batch = firestore.batch();
    batch.update(firestore.collection('friends').doc(uid), {"$user": 0});
    batch.update(firestore.collection('friends').doc(user), {"$uid": 1});
    batch.commit();
  }

  Future<void> acceptFriendReq(user) async {
    print("Firing acceptFriendReq");
    var batch = firestore.batch();
    batch.update(firestore.collection('friends').doc(user), {"$uid": 2});
    batch.update(firestore.collection('friends').doc(uid), {"$user": 2});
    batch.commit();
  }

  Future<void> declineFriendReq(user) async {
    print("Firing declineFriendReq");
    var batch = firestore.batch();
    batch.update(firestore.collection('friends').doc(user),
        {"$uid": FieldValue.delete()});
    batch.update(firestore.collection('friends').doc(uid),
        {"$user": FieldValue.delete()});
    batch.commit();
  }

  // Future<List<QuerySnapshot<Map<String, dynamic>>>> getProfileDetails(
  //     chunks) async {
  //   print("Firing getProfileDetails");
  //   List<QuerySnapshot<Map<String, dynamic>>> profiles = [];
  //   for (var i = 0; i < chunks.length; i++) {
  //     profiles.add(await firestore
  //         .collection('users')
  //         .where(FieldPath.documentId, whereIn: chunks[i])
  //         .get());
  //   }
  //   print("Test ${profiles.length}");
  //   return profiles;
  // }

  Future<Map<dynamic, dynamic>> friendsPageData() async {
    print("Firing friendsPageData");

    Map results = {
      "newRequests": [],
      "friendsList": [],
    };

    var friendsFields = await firestore.collection('friends').doc(uid).get();
    var friendsMap = friendsFields.data();

    if (friendsMap!.isEmpty) {
      return results;
    }

    List friendsList = friendsMap.keys.toList();
    print(friendsList);

    var profiles = await firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendsList)
        .get();

    profiles.docs.forEach((element) {
      switch (friendsMap[element.id]) {
        case 1:
          results["newRequests"].add(element);
          break;
        case 2:
          results["friendsList"].add(element);
          break;
      }
    });
    print(results);
    return results;
  }
}
