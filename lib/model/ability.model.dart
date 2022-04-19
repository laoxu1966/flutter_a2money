import 'dart:convert';

import 'respond.model.dart';

class Ability {
  Ability({
    this.id,
    required this.paying,
    required this.classification,
    this.tag,
    required this.title,
    required this.des,
    required this.risk,
    required this.respondDate,
    required this.respondTime,
    this.files,
    this.email,
    this.tel,
    this.geo,
    this.status,
    this.responds,
    this.uid,
    this.profile,
    this.created,
    this.updated,
  });

  int? id;
  int paying;
  int classification;
  String? tag;
  String title;
  String des;
  String risk;
  String respondDate;
  String respondTime;
  List<String>? files;
  String? email;
  String? tel;
  String? geo;
  int? status;
  List<Respond>? responds;
  int? uid;
  Map<String, dynamic>? profile;
  DateTime? created;
  DateTime? updated;

  factory Ability.fromJson(Map<String, dynamic> parsedJson) {
    return Ability(
      id: parsedJson['id'],
      paying: parsedJson['paying'],
      classification: parsedJson['classification'],
      tag: parsedJson['tag'] ?? '',
      title: parsedJson['title'] ?? '',
      des: parsedJson['des'] ?? '',
      risk: parsedJson['risk'] ?? '',
      respondDate: parsedJson['respondDate'],
      respondTime: parsedJson['respondTime'],
      files: (jsonDecode(parsedJson['files'] ?? '[]') as List?)!
          .map((e) => e as String)
          .toList(),
      email: parsedJson['email'],
      tel: parsedJson['tel'],
      geo: parsedJson['geo'],
      status: parsedJson['status'],
      responds: ((parsedJson['responds'] ?? []) as List)
          .map((e) => Respond.fromJson(e))
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
