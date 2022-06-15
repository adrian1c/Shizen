import 'package:cloud_firestore/cloud_firestore.dart';

class CommunityPost {
  String uid;
  String desc = '';
  Timestamp dateCreated = Timestamp.now();
  List<String> hashtags = [];
  String visibility = 'Friends Only';
  var attachment;
  String? attachmentType;

  CommunityPost(this.uid, this.desc, this.hashtags, this.visibility,
      this.attachment, this.attachmentType);

  toJson() {
    return {
      'uid': uid,
      'dateCreated': dateCreated,
      'desc': desc,
      'hashtags': hashtags,
      'attachment': attachment,
      'attachmentType': attachmentType,
      'visibility': visibility,
      'commentCount': 0
    };
  }
}
