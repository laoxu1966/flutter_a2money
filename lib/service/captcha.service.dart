import 'package:flutter/foundation.dart';

import 'dio.service.dart';

class CaptchaService with ChangeNotifier {
  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  String? _svg;
  String? get svg => _svg;

  CaptchaService() {
    //
  }

  Future getCaptcha() async {
    var response = await DioSingleton().dioGet('/captcha/getCaptcha');

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        _svg = parsedJson['svg'];

        notifyListeners();
      }
    }

    return this;
  }
}
