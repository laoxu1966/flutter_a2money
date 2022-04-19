import 'dart:convert';

import 'favorite.model.dart';

class User {
  User({
    this.id,
    required this.username,
    required this.password,
    this.email,
    this.tel,
    this.profile,
    this.role,
    this.favorites,
    this.created,
    this.updated,
  });

  int? id;
  String username;
  String password;
  String? email;
  String? tel;
  Map<String, dynamic>? profile;
  int? role;
  List<Favorite>? favorites;
  DateTime? created;
  DateTime? updated;

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      id: parsedJson['id'],
      username: parsedJson['username'],
      password: parsedJson['password'],
      email: parsedJson['email'],
      tel: parsedJson['tel'],
      profile: jsonDecode(parsedJson['profile'] ?? '{}'),
      role: parsedJson['role'],
      favorites: ((parsedJson['favorites'] ?? []) as List)
          .map((e) => Favorite.fromJson(e))
          .toList(),
      created: (DateTime.tryParse(parsedJson['created']) ?? DateTime.now()).toLocal(),
      updated: (DateTime.tryParse(parsedJson['updated']) ?? DateTime.now()).toLocal(),
    );
  }
}
