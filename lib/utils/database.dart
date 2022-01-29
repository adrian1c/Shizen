import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import '../main.dart';

class Database {
  Database(this.uid);

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final String uid;

  Stream getToDoTasks() {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('todo')
        .snapshots();
  }

  Stream getTrackerTasks() {
    return firestore
        .collection('users')
        .doc(uid)
        .collection('tracker')
        .snapshots();
  }
}
