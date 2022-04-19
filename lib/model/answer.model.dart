import 'dart:convert';

class Answer {
  Answer({
    this.id,
    required this.questionid,
    required this.questionuid,
    required this.des,
    this.uid,
    this.profile,
    this.created,
    this.updated,
  });

  int? id;
  int questionid;
  int questionuid;
  String des;
  int? uid;
  Map<String, dynamic>? profile;
  DateTime? created;
  DateTime? updated;

  factory Answer.fromJson(Map<String, dynamic> parsedJson) {
    return Answer(
      id: parsedJson['id'],
      questionid: parsedJson['questionid'],
      questionuid: parsedJson['questionuid'],
      des: parsedJson['des'],
      uid: parsedJson['uid'],
      profile: jsonDecode(parsedJson['profile'] ?? '{}'),
      created: (DateTime.tryParse(parsedJson['created']) ?? DateTime.now())
          .toLocal(),
      updated: (DateTime.tryParse(parsedJson['updated']) ?? DateTime.now())
          .toLocal(),
    );
  }
}
