import "package:dio/dio.dart";
import 'package:flutter/foundation.dart';

import 'dio.service.dart';

import '../model/ability.model.dart';
import '../model/search.model.dart';

class AbilityService with ChangeNotifier {
  List<Ability> _abilities = [];
  List<Ability> get abilities => _abilities;

  Ability? _ability;
  Ability? get ability => _ability;

  List<Tag>? _tags;
  List<Tag>? get tags => _tags;

  List<Hot>? _hots;
  List<Hot>? get hots => _hots;

  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  AbilityService() {
    //
  }

  Future findAll(
    String path,
    Map<String, dynamic> params,
    int offset,
  ) async {
    final thisparams = {...params, 'offset': offset};
    var response = await DioSingleton().dioGet(path, thisparams);

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      List<dynamic>? abilitiesArr = response.data['data'];
      if (abilitiesArr != null) {
        _abilities = abilitiesArr.map((i) => Ability.fromJson(i)).toList();
        notifyListeners();
      }
    }

    return this;
  }

  Future findOne(int? id) async {
    _ability = null;

    var response = await DioSingleton().dioGet('/ability/findOne', {
      'id': id,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        _ability = Ability.fromJson(parsedJson);
        notifyListeners();
      }
    }

    return this;
  }

  Future createAbility(
    int paying,
    String classification,
    String? tag,
    String title,
    String des,
    String risk,
    String respondDate,
    String respondTime,
    List<String>? files,
    String? email,
    String? tel,
    String? geo,
    String captcha,
    int? uid,
  ) async {
    FormData formData = FormData.fromMap({
      "paying": paying.toString(),
      "classification": classification,
      "tag": tag,
      "title": title,
      "des": des,
      "risk": risk,
      "respondDate": respondDate.toString(),
      "respondTime": respondTime.toString(),
      "email": email,
      "tel": tel,
      "geo": geo,
      "captcha": captcha,
      "uid": uid.toString(),
      "pics": files!
          .where((element) =>
              element.startsWith("mock/ability/") ||
              element.startsWith("ability/"))
          .map((pic) {
            return pic.replaceAll('"', '');
          })
          .toList()
          .join(','),
      "files": files
          .where((element) =>
              element.startsWith("/storage/") || element.startsWith("/data/"))
          .map((file) {
        var url = file.replaceAll('"', '');
        var filename = url.substring(url.lastIndexOf("/") + 1, url.length);
        return MultipartFile.fromFileSync(url, filename: filename);
      }).toList(),
    });

    var response = await DioSingleton()
        .dioPostFormData('/ability/createAbility', formData);

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future updateAbility(
    int? id,
    String classification,
    String? tag,
    String title,
    String des,
    String risk,
    String respondDate,
    String respondTime,
    List<String>? files,
    String? email,
    String? tel,
    String? geo,
    int? uid,
  ) async {
    FormData formData = FormData.fromMap({
      "id": id.toString(),
      "classification": classification,
      "tag": tag,
      "title": title,
      "des": des,
      "risk": risk,
      "respondDate": respondDate.toString(),
      "respondTime": respondTime.toString(),
      "email": email,
      "tel": email,
      "geo": geo,
      "uid": uid.toString(),
      "pics": files!
          .where((element) =>
              element.startsWith("mock/ability/") ||
              element.startsWith("ability/"))
          .map((pic) {
            return pic.replaceAll('"', '');
          })
          .toList()
          .join(','),
      "files": files
          .where((element) =>
              element.startsWith("/storage/") || element.startsWith("/data/"))
          .map((file) {
        var url = file.replaceAll('"', '');
        var filename = url.substring(url.lastIndexOf("/") + 1, url.length);
        return MultipartFile.fromFileSync(url, filename: filename);
      }).toList(),
    });
    var response = await DioSingleton()
        .dioPostFormData('/ability/updateAbility', formData);

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future deleteAbility(int? id) async {
    var response = await DioSingleton().dioPost('/ability/deleteAbility', {
      'id': id,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future classificationtag() async {
    _tags = [];

    var response = await DioSingleton().dioGet('/ability/classificationtag');

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      List<dynamic>? tagsArr = response.data['data'];
      if (tagsArr != null) {
        _tags = tagsArr.map((i) => Tag.fromJson(i)).toList();
        notifyListeners();
      }
    }

    return this;
  }

  Future hot() async {
    _hots = [];
    var response = await DioSingleton().dioGet('/ability/hot');

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      List<dynamic>? hotsArr = response.data['data'];
      if (hotsArr != null) {
        _hots = hotsArr.map((i) => Hot.fromJson(i)).toList();
        notifyListeners();
      }
    }

    return this;
  }

  Future updateMemo(int id, String? memo) async {
    var response = await DioSingleton().dioPost('/respond/updateMemo', {
      'id': id,
      'memo': memo,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }
}
