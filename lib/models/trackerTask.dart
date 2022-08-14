class TrackerTaskModel {
  String? key;
  String title = '';
  String note = '';
  DateTime startDate;
  List milestones = [];
  DateTime? reminder;

  TrackerTaskModel(
      this.title, this.note, this.milestones, this.startDate, this.reminder);

  toJson() {
    return {
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
