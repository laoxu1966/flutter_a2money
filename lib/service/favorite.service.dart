import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../model/favorite.model.dart';

import 'dio.service.dart';

class FavoriteService with ChangeNotifier {
  List<Favorite> _favorites = [];
  List<Favorite> get favorites => _favorites;

  int? _statusCode;
  int? get statusCode => _statusCode;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  FavoriteService() {
    //
  }

  Future findAll(
    int code,
    int uid,
  ) async {
    var response = await DioSingleton().dioGet('/favorite/findAll', {
      'code': code,
      'uid': uid,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200) {
      List<dynamic>? favoritesArr = response.data['data'];
      if (favoritesArr != null) {
        _favorites = favoritesArr.map((i) => Favorite.fromJson(i)).toList();
        notifyListeners();
      }
    }

    return this;
  }

  Future createFavorite(
      int code, int peer, Map<String, dynamic> profile) async {
    var response = await DioSingleton().dioPost('/favorite/createFavorite', {
      'code': code,
      'peer': peer,
      'profile': jsonEncode(profile),
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future deleteFavorite(int code, int peer) async {
    var response = await DioSingleton().dioPost('/favorite/deleteFavorite', {
      'code': code,
      'peer': peer,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      notifyListeners();
    }

    return this;
  }

  Future updateMemo(int favoriteid, String? memo) async {
    var response = await DioSingleton().dioPost('/favorite/updateMemo', {
      'favoriteid': favoriteid,
      'memo': memo,
    });

    _statusCode = response?.statusCode;
    _statusMessage = response?.statusMessage;

    if (_statusCode == 200 || _statusCode == 201) {
      _favorites = _favorites.map((favorite) {
        if(favorite.id == favoriteid) {
          return favorite.memo = memo;
        }
      }).cast<Favorite>().toList();
      notifyListeners();
    }

    return this;
  }
}
