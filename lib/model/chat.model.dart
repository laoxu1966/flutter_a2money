import 'dart:convert';

import 'package:flutter/material.dart';

class Chat {
  Chat(
      {required this.room,
      required this.message,
      this.uid,
      this.profile,
      this.created,
      this.animationController});

  String room;
  String message;
  int? uid;
  Map<String, dynamic>? profile;
  DateTime? created;
  AnimationController? animationController;

  factory Chat.fromJson(Map<String, dynamic> parsedJson) {
    return Chat(
      room: parsedJson['room'],
      message: parsedJson['message'] ?? '',
      uid: parsedJson['uid'],
      profile: jsonDecode(parsedJson['profile'] ?? '{}'),
      created: (DateTime.tryParse(parsedJson['created']) ?? DateTime.now())
          .toLocal(),
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = <String, dynamic>{};

    map['message'] = message;
    map['uid'] = uid;
    map['profile'] = profile;
    map['created'] = created.toString();

    return map;
  }
}
