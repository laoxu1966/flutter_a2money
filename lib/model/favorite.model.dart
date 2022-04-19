import 'dart:convert';

import 'package:azlistview/azlistview.dart';

class Favorite extends ISuspensionBean {
  Favorite({
    this.id,
    required this.code,
    required this.peer,
    required this.profile,
    this.memo,
    required this.uid,
    this.nameIndex,
    this.namePinyin,
  });

  int? id;
  int code;
  int peer;
  Map<String, dynamic> profile;
  String? memo;
  int uid;
  String? nameIndex;
  String? namePinyin;

  factory Favorite.fromJson(Map<String, dynamic> parsedJson) {
    return Favorite(
      id: parsedJson['id'],
      code: parsedJson['code'],
      peer: parsedJson['peer'],
      profile: jsonDecode(parsedJson['profile'] ?? '{}'),
      memo: parsedJson['memo'],
      uid: parsedJson['uid'],
      nameIndex: parsedJson['nameIndex'] ?? '',
      namePinyin: parsedJson['namePinyin'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = <String, dynamic>{};

    map['code'] = code;
    map['peer'] = peer;
    map['memo'] = memo;
    map['profile'] = profile;
    map['uid'] = uid;

    return map;
  }

  @override
  String getSuspensionTag() => nameIndex!;
}
