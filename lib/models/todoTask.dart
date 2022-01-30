class ToDoTask {
  String? key;
  String title = '';
  String desc = '';
  DateTime dateCreated = DateTime.now();
  Map<String, dynamic> settings = {
    "recur": [],
    "reminder": null,
    "deadline": null,
  };
  bool isComplete = false;

  ToDoTask(this.title, this.desc, this.settings);

  toJson() {
    return {
      'dateCreated': dateCreated,
      'title': title,
      'desc': desc,
      'settings': settings,
      'isComplete': isComplete,
    };
  }
}
