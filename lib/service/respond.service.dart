import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../model/respond.model.dart';

import 'dio.service.dart';

class RespondService with ChangeNotifier {
  Respond? _respond;
  Respond? get respond => _respond;

  final List<Respond> _responds = [];
  List<Respond> get responds => _responds;

  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  RespondService() {
    //
  }

  Future findOne(int? id) async {
    _respond = null;

    var response = await DioSingleton().dioGet('/respond/findOne', {
      'id': id,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        _respond = Respond.fromJson(parsedJson);
        notifyListeners();
      }
    }

    return this;
  }

  Future createRespond(
    int? abilityid,
    int? abilityuid,
    Map<String, dynamic> contract,
    String captcha,
  ) async {
    var response = await DioSingleton().dioPost('/respond/createRespond', {
      "abilityid": abilityid,
      "abilityuid": abilityuid,
      "contractB": json.encode(contract),
      "captcha": captcha,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response?.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        _respond = Respond.fromJson(parsedJson);
        notifyListeners();
      }
    }

    return this;
  }

  Future updateContractAB(int? id, Map<String, dynamic> contractAB) async {
    var response = await DioSingleton().dioPost('/respond/updateContractAB', {
      "id": id,
      "contractAB": json.encode(contractAB),
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        notifyListeners();
      }
    }

    return this;
  }

  Future updateContract(int? id, Map<String, dynamic> contract) async {
    var response = await DioSingleton().dioPost('/respond/updateContract', {
      "id": id,
      "contract": json.encode(contract),
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        notifyListeners();
      }
    }

    return this;
  }

  Future updateSettlementAB(
    int? id,
    Map<String, dynamic> settlementAB,
  ) async {
    var response = await DioSingleton().dioPost('/respond/updateSettlementAB', {
      "id": id.toString(),
      "settlementAB": json.encode(settlementAB),
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        notifyListeners();
      }
    }

    return this;
  }

  Future updateSettlement(
    int? id,
    Map<String, dynamic> settlement,
  ) async {
    var response = await DioSingleton().dioPost('/respond/updateSettlement', {
      "id": id,
      "settlement": json.encode(settlement),
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      Map<String, dynamic>? parsedJson = response.data['data'];
      if (parsedJson != null && parsedJson.isNotEmpty) {
        notifyListeners();
      }
    }

    return this;
  }

  Future deleteRespond(int? id) async {
    var response = await DioSingleton().dioPost('/respond/deleteRespond', {
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
