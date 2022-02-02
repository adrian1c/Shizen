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
    return firestore.collection('users').where('email', isEqualTo: email).get();
  }

  Future<void> sendFriendReq(user) async {
    print("Firing sendFriendReq");
    await firestore.collection('friends').doc(uid).set({user: 0});
  }
}
