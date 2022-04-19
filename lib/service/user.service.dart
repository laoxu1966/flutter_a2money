import 'dart:convert';

import "package:dio/dio.dart";
import 'package:flutter/foundation.dart';

import '../model/user.model.dart';

import 'dio.service.dart';

class UserService with ChangeNotifier {
  User? _user;
  User? get user => _user;

  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  UserService() {
    currentUser();
  }

  Future currentUser() async {
    _user = null;

    var response = await DioSingleton().dioGet('/user/currentUser');

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        bool? _isAuthenticated = parsedJson['isAuthenticated'];
        if (_isAuthenticated == true && parsedJson['user'] != {}) {
          _user = User.fromJson(parsedJson['user']);
        }
        notifyListeners();
      }
    }

    return this;
  }

  Future createUser(
    String? username,
    String? password,
    Map<String, dynamic>? profile,
  ) async {
    var response = await DioSingleton().dioPost('/user/createUser', {
      'username': username,
      'password': password,
      'profile': jsonEncode(profile),
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future signin(String? username, String? password) async {
    var response = await DioSingleton()
        .dioPost('/user/signin', {'username': username, 'password': password});

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 302) {
      response = await currentUser();

      _statusCode = response?.statusCode;
      _statusMessage = response?.statusMessage;

      if (response?.statusCode == 200) {
        notifyListeners();
      }
    }

    return this;
  }

  Future signout(int? id) async {
    var response = await DioSingleton().dioPost('/user/signout', {"id": id});

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 302) {
      response = await currentUser();
    }

    return this;
  }

  Future logout() async {
    var response = await DioSingleton().dioPost('/user/logout');

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 302) {
      response = await currentUser();
    }

    return this;
  }

  Future updateUsername(String username) async {
    var response = await DioSingleton().dioPost('/user/updateUsername', {
      'username': username,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      _user!.username = username;
      
      notifyListeners();
    }

    return this;
  }

  Future resetPassword(
    String? username,
    String? hash,
    String? password,
  ) async {
    var response = await DioSingleton().dioPost('/user/resetPassword',
        {'username': username, 'hash': hash, 'password': password});

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future updatePassword(String? password) async {
    var response = await DioSingleton().dioPost('/user/updatePassword', {
      'password': password,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future updateProfile(
    Map<String, dynamic>? profile,
  ) async {
    FormData formData = FormData.fromMap({
      'profile': jsonEncode(profile),
    });

    if (profile!['avatar'].startsWith("/storage/") ||
        profile['avatar'].startsWith("/data/")) {
      var url = profile['avatar'].replaceAll('"', '');
      var filename = url.substring(url.lastIndexOf("/") + 1, url.length);

      formData = FormData.fromMap({
        'profile': jsonEncode(profile),
        'uid': _user!.id.toString(),
        "file": MultipartFile.fromFileSync(url, filename: filename),
      });
    }

    var response =
        await DioSingleton().dioPostFormData('/user/updateProfile', formData);

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      _user!.profile = profile;

      notifyListeners();
    }

    return this;
  }

  Future updateEmail(String? email, String? hash) async {
    var response = await DioSingleton().dioPost('/user/updateEmail', {
      'email': email,
      'hash': hash,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      _user!.email = email;
      
      notifyListeners();
    }

    return this;
  }

  Future updateTel(String? tel, String? hash) async {
    var response = await DioSingleton().dioPost('/user/updateTel', {
      'tel': tel,
      'hash': hash,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      _user!.email = tel;
      
      notifyListeners();
    }

    return this;
  }

  Future verifyEmail(String? email) async {
    var response = await DioSingleton().dioPost('/user/verifyEmail', {
      'email': email,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future verifyTel(String? tel) async {
    var response = await DioSingleton().dioPost('/user/verifyTel', {
      'tel': tel,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }
}
