class TrackerTaskModel {
  String? key;
  String title = '';
  String note = '';
  DateTime dateCreated = DateTime.now();
  DateTime startDate;
  List milestones = [];
  DateTime? reminder;

  TrackerTaskModel(
      this.title, this.note, this.milestones, this.startDate, this.reminder);

  toJson() {
    return {
      'dateCreated': dateCreated,
      'startDate': startDate,
      'currStreakDate': startDate,
      'title': title,
      'note': note,
      'milestones': milestones,
      'checkin': [],
      'reminder': reminder
    };
  }
}
