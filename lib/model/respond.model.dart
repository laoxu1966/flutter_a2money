import 'dart:convert';

import 'token.model.dart';

class Respond {
  Respond({
    this.id,
    required this.abilityid,
    required this.abilityuid,
    this.contractA,
    this.contractB,
    this.contract,
    this.settlementA,
    this.settlementB,
    this.settlement,
    this.memo,
    this.tokens,
    this.status,
    this.uid,
    this.profile,
    this.created,
    this.updated,
  });

  int? id;
  int abilityid;
  int abilityuid;
  Map<String, dynamic>? contractA;
  Map<String, dynamic>? contractB;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? settlementA;
  Map<String, dynamic>? settlementB;
  Map<String, dynamic>? settlement;
  String? memo;
  List<Token>? tokens;
  int? status;
  int? uid;
  Map<String, dynamic>? profile;
  DateTime? created;
  DateTime? updated;

  factory Respond.fromJson(Map<String, dynamic> parsedJson) {
    return Respond(
      id: parsedJson['id'],
      abilityid: parsedJson['abilityid'],
      abilityuid: parsedJson['abilityuid'],
      contractA: jsonDecode(parsedJson['contractA'] ?? '{}'),
      contractB: jsonDecode(parsedJson['contractB'] ?? '{}'),
      contract: jsonDecode(parsedJson['contract'] ?? '{}'),
      settlementA: jsonDecode(parsedJson['settlementA'] ?? '{}'),
      settlementB: jsonDecode(parsedJson['settlementB'] ?? '{}'),
      settlement: jsonDecode(parsedJson['settlement'] ?? '{}'),
      memo: parsedJson['memo'],
      tokens: ((parsedJson['tokens'] ?? []) as List)
          .map((e) => Token.fromJson(e))
          .toList(),
      status: parsedJson['status'],
      uid: parsedJson['uid'],
      profile: jsonDecode(parsedJson['profile'] ?? '{}'),
      created: (DateTime.tryParse(parsedJson['created']) ?? DateTime.now())
          .toLocal(),
      updated: (DateTime.tryParse(parsedJson['updated']) ?? DateTime.now())
          .toLocal(),
    );
  }
}
