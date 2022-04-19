import "package:dio/dio.dart";
import 'package:flutter/foundation.dart';

import 'dio.service.dart';

import '../model/question.model.dart';
import '../model/answer.model.dart';

class QuestionService with ChangeNotifier {
  List<Question> _questions = [];
  List<Question> get questions => _questions;

  Question? _question;
  Question? get question => _question;

  Answer? _answer;
  Answer? get answer => _answer;

  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  QuestionService() {
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
      List<dynamic>? questionsArr = response.data['data'];
      if (questionsArr != null) {
        _questions = questionsArr.map((i) => Question.fromJson(i)).toList();
        notifyListeners();
      }
    }

    return this;
  }

  Future findOne(int? id) async {
    _question = null;

    var response = await DioSingleton().dioGet('/question/findOne', {
      'id': id,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        _question = Question.fromJson(parsedJson);
        notifyListeners();
      }
    }

    return this;
  }

  Future createQuestion(
    String title,
    String des,
    String classification,
    String? tag,
    List<String>? files,
    String captcha,
    int? uid,
  ) async {
    FormData formData = FormData.fromMap({
      "title": title,
      "des": des,
      "classification": classification,
      "tag": tag,
      "captcha": captcha,
      "uid": uid.toString(),
      "pics": files!
          .where((element) =>
              element.startsWith("mock/question/") ||
              element.startsWith("question/"))
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
        .dioPostFormData('/question/createQuestion', formData);

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future updateQuestion(
    int? id,
    String title,
    String des,
    String classification,
    String? tag,
    List<String>? files,
    int? uid,
  ) async {
    FormData formData = FormData.fromMap({
      "id": id.toString(),
      "title": title,
      "des": des,
      "classification": classification,
      "tag": tag,
      "uid": uid.toString(),
      "pics": files!
          .where((element) =>
              element.startsWith("mock/question/") ||
              element.startsWith("question/"))
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
        .dioPostFormData('/question/updateQuestion', formData);

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future deleteQuestion(int? id) async {
    var response = await DioSingleton().dioPost('/question/deleteQuestion', {
      'id': id,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }
}
