import 'package:flutter/foundation.dart';

import 'dio.service.dart';

class AnswerService with ChangeNotifier {
  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  AnswerService() {
    //
  }

  Future createAnswer(
    int? questionid,
    int? questionuid,
    String des,
    String captcha,
  ) async {
    var response = await DioSingleton().dioPost('/answer/createAnswer', {
      "questionid": questionid,
      "questionuid": questionuid,
      "des": des,
      "captcha": captcha,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response?.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        notifyListeners();
      }
    }

    return this;
  }

  Future updateAnswer(
    int id,
    String des,
  ) async {
    var response = await DioSingleton().dioPost('/answer/updateAnswer', {
      "id": id.toString(),
      "des": des,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future deleteAnswer(int? id) async {
    var response = await DioSingleton().dioPost('/answer/deleteAnswer', {
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
