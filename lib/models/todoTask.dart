import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoTaskModel {
  String? key;
  String title = '';
  List desc = [];
  Timestamp dateCreated = Timestamp.now();
  List<bool> recur = [false, false, false, false, false, false, false];
  DateTime? reminder;
  bool allComplete = false;
  bool isPublic = false;
  bool isEdit;

  ToDoTaskModel(this.title, this.desc, this.recur, this.reminder, this.isPublic,
      [this.isEdit = false]);

  toJson() {
    if (title == '') {
      title = 'Task';
    }

    if (isEdit) {
      return {
        'title': title,
        'desc': desc,
        'recur': recur,
        'reminder': reminder,
        'allComplete': allComplete,
        'isPublic': isPublic,
      };
    }

    return {
      'dateCreated': dateCreated,
      'title': title,
      'desc': desc,
      'recur': recur,
      'reminder': reminder,
      'allComplete': allComplete,
      'isPublic': isPublic,
    };
  }
}
