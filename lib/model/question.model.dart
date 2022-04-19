import 'dart:convert';

import 'answer.model.dart';

class Question {
  Question({
    this.id,
    required this.classification,
    this.tag,
    required this.title,
    required this.des,
    this.files,
    this.status,
    this.answers,
    this.uid,
    this.profile,
    this.created,
    this.updated,
  });

  int? id;
  int classification;
  String? tag;
  String title;
  String des;
  List<String>? files;
  int? status;
  List<Answer>? answers;
  int? uid;
  Map<String, dynamic>? profile;
  DateTime? created;
  DateTime? updated;

  factory Question.fromJson(Map<String, dynamic> parsedJson) {
    return Question(
      id: parsedJson['id'],
      classification: parsedJson['classification'],
      tag: parsedJson['tag'] ?? '',
      title: parsedJson['title'] ?? '',
      des: parsedJson['des'] ?? '',
      files: (jsonDecode(parsedJson['files'] ?? '[]') as List?)!
          .map((e) => e as String)
          .toList(),
      status: parsedJson['status'],
      answers: ((parsedJson['answers'] ?? []) as List)
          .map((e) => Answer.fromJson(e))
          .toList(),
      uid: parsedJson['uid'],
      profile: jsonDecode(parsedJson['profile'] ?? '{}'),
      created: (DateTime.tryParse(parsedJson['created']) ?? DateTime.now())
          .toLocal(),
      updated: (DateTime.tryParse(parsedJson['updated']) ?? DateTime.now())
          .toLocal(),
    );
  }
}
