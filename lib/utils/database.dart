import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:shizen_app/models/todoTask.dart';

class Database {
  Database(this.uid);

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String uid;

  Stream getToDoTasks() {
    return firestore
        .collection('tasks')
        .doc(uid)
        .collection('todo')
        .orderBy("dateCreated", descending: true)
        .snapshots();
  }

  Stream getTrackerTasks() {
    return firestore
        .collection('tasks')
        .doc(uid)
        .collection('tracker')
        .snapshots();
  }

  Future<void> addToDoTask(toDoTask) async {
    await firestore
        .collection('tasks')
        .doc(uid)
        .collection('todo')
        .add(toDoTask.toJson())
        .whenComplete(() => print("Done"))
        .catchError((e) => print(e));
  }
}
