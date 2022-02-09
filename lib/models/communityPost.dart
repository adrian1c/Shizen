class CommunityPost {
  String uid;
  String desc = '';
  DateTime dateCreated = DateTime.now();
  List<String> hashtags = [];
  String visibility = 'Friends Only';
  String? attachment;
  List<String> comments = [];

  CommunityPost(this.uid, this.desc, this.hashtags, this.visibility,
      [attachment]);

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
