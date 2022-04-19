import 'package:flutter/foundation.dart';

import '../model/token.model.dart';

import 'dio.service.dart';

class TokenService with ChangeNotifier {
  String? _payUrl;
  String? get payUrl => _payUrl;

  List<Token> _tokens = [];
  List<Token> get tokens => _tokens;

  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  TokenService() {
    //
  }

  Future findAll(int? uid) async {
    var response = await DioSingleton().dioGet('/token/findAll', {
      "uid": uid,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      List<dynamic>? tokensArr = response.data['data'];
      if (tokensArr != null) {
        _tokens = tokensArr.map((i) => Token.fromJson(i)).toList();
        notifyListeners();
      }
    }

    return this;
  }

  Future freeze(int? tokenid) async {
    var response = await DioSingleton().dioPost('/token/freeze', {
      "tokenid": tokenid,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    String message = response.data['message'] ?? '';
    if (message.isNotEmpty) _statusMessage = response.data['message'];

    if (_statusCode == 200 || _statusCode == 201) {
      _payUrl = response?.data['data'];
    }

    return this;
  }

  Future unfreezeorpay(int? respondid, int? tokenid) async {
    var response = await DioSingleton().dioPost('/token/unfreezeorpay', {
      "respondid": respondid,
      "tokenid": tokenid,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    String message = response.data['message'] ?? '';
    if (message.isNotEmpty) _statusMessage = response.data['message'];

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        notifyListeners();
      }
    }

    return this;
  }

  Future trans(int? respondid, int? tokenid) async {
    var response = await DioSingleton().dioPost('/token/trans', {
      "respondid": respondid,
      "tokenid": tokenid,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    String message = response.data['message'] ?? '';
    if (message.isNotEmpty) _statusMessage = response.data['message'];

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }
}
