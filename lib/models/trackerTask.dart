class TrackerTask {
  String? key;
  String title = '';
  String note = '';
  DateTime dateCreated = DateTime.now();
  DateTime startDate;
  List milestones = [];

  TrackerTask(this.title, this.note, this.milestones, this.startDate);

  toJson() {
    return {
      'dateCreated': dateCreated,
      'startDate': startDate,
      'title': title,
      'note': note,
      'milestones': milestones,
    };
  }
}
