class ToDoTask {
  String? key;
  String title = '';
  List desc = [];
  DateTime dateCreated = DateTime.now();
  List<bool> recur = [false, false, false, false, false, false, false];
  DateTime? reminder;
  bool allComplete = false;
  List? descEdit;

  ToDoTask(this.title, this.desc, this.recur, this.reminder);

  toJson() {
    return {
      'dateCreated': dateCreated,
      'title': title,
      'desc': desc,
      'recur': recur,
      'reminder': reminder,
      'allComplete': allComplete,
    };
  }
}
