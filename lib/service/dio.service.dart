// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:async';

import "package:dio/dio.dart";
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../common/constant.dart';

class DioSingleton {
  static Dio? _dioInstance;

  static Future<Dio?> get _instance async {
    BaseOptions options = BaseOptions(
      baseUrl: endPoint,
      connectTimeout: 6000,
      receiveTimeout: 3000,
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
    );

    Dio dioClient = Dio(options);

    /*(dioClient.httpClientAdapter as DefaultHttpClientAdapter)
        .onHttpClientCreate = (client) {
      client.badCertificateCallback = (cert, host, port) {
        return true;
      };
    };*/

    final directory = await getApplicationDocumentsDirectory();
    CookieJar cookieJar = PersistCookieJar(
      storage: FileStorage(directory.path),
    );

    dioClient.interceptors.add(
      CookieManager(cookieJar),
    );
    return dioClient;
  }

  static init() async {
    _dioInstance ??= await _instance;
  }

  Future dioGet(String? path, [Map<String, dynamic>? params]) async {
    var response;

    try {
      if (null != params) {
        response =
            await _dioInstance!.get(endPoint + path!, queryParameters: params);
      } else {
        response = await _dioInstance!.get(endPoint + path!);
      }
    } on DioError catch (e) {
      return errorHandle(e);
    }

    return response;
  }

  Future dioPost(String path, [Map<String, dynamic>? params]) async {
    var response;

    try {
      if (null != params) {
        response = await _dioInstance!.post(endPoint + path, data: params);
      } else {
        response = await _dioInstance!.post(endPoint + path);
      }
    } on DioError catch (e) {
      return errorHandle(e);
    }

    return response;
  }

  Future dioPostFormData(String path, FormData? params) async {
    var response;

    try {
      if (null != params) {
        response = await _dioInstance!.post(endPoint + path, data: params);
      }
    } on DioError catch (e) {
      return errorHandle(e);
    }

    return response;
  }

  errorHandle(DioError e) {
    if (e.response != null) {
      return e.response;
    } else {
      if (e.error == DioErrorType.connectTimeout) {
        throw Exception('连接超时');
      } else if (e.error == DioErrorType.sendTimeout) {
        throw Exception('请求超时');
      } else if (e.error == DioErrorType.receiveTimeout) {
        throw Exception('响应超时');
      } else if (e.error == DioErrorType.response) {
        throw Exception('响应出错');
      } else {
        throw Exception(e.message);
      }
    }
  }
}
