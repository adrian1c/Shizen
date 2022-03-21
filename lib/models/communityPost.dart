class CommunityPost {
  String uid;
  String desc = '';
  DateTime dateCreated = DateTime.now();
  List<String> hashtags = [];
  String visibility = 'Friends Only';
  var attachment;
  List<String> comments = [];

  CommunityPost(
      this.uid, this.desc, this.hashtags, this.visibility, this.attachment);

  toJson() {
    return {
      'uid': uid,
      'dateCreated': dateCreated,
      'desc': desc,
      'hashtags': hashtags,
      'attachment': attachment,
      'visibility': visibility,
      'comments': comments,
    };
  }
}
