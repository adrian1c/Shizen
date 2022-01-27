class TodoTask {
  String title = '';
  String desc = '';
  final String dateCreated;
  Map<String, dynamic> settings = {
    "isRecur": "0",
    "isReminder": false,
    "isDeadline": "0",
  };

  TodoTask(this.title, this.desc, this.dateCreated, this.settings);

  toJson() {
    return {
      'dateCreated': dateCreated,
      'title': title,
      'desc': desc,
      'settings': settings,
    };
  }
}
