import 'package:cloud_firestore/cloud_firestore.dart';

class ToDoTaskModel {
  String? key;
  String title = '';
  List desc = [];
  Timestamp dateCreated = Timestamp.now();
  DateTime? reminder;
  bool isPublic = false;
  bool isEdit;
  int timesCompleted;
  String note = '';

  ToDoTaskModel(this.title, this.desc, this.reminder, this.isPublic, this.note,
      [this.isEdit = false, this.timesCompleted = 0]);

  toJson() {
    if (title == '') {
      title = 'Task';
    }

    if (isEdit) {
      return {
        'title': title,
        'desc': desc,
        'reminder': reminder,
        'isPublic': isPublic,
        'timesCompleted': timesCompleted,
        'note': note
      };
    }

    return {
      'dateCreated': dateCreated,
      'title': title,
      'desc': desc,
      'reminder': reminder,
      'isPublic': isPublic,
      'timesCompleted': timesCompleted,
      'note': note
    };
  }
}
