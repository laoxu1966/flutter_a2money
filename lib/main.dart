import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'service/ability.service.dart';
import 'service/captcha.service.dart';
import 'service/chat.service.dart';
import 'service/dio.service.dart';
import 'service/favorite.service.dart';
import 'service/pref.service.dart';
import 'service/respond.service.dart';
import 'service/theme.service.dart';
import 'service/token.service.dart';
import 'service/user.service.dart';
import 'service/question.service.dart';
import 'service/answer.service.dart';

import 'page/home/home.page.dart';
import 'page/home/privacy.page.dart';
import 'page/user/signin.page.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  await Pref.init();
  await DioSingleton.init();

  String oldVersion = Pref.getString('version')!;
  String oldBuildNumber = Pref.getString('buildNumber')!;

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String buildNumber = packageInfo.buildNumber;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AbilityService>(
          //lazy: false,
          create: (_) => AbilityService(),
        ),
        ChangeNotifierProvider<ChatService>(
          //lazy: false,
          create: (_) => ChatService(),
        ),
        ChangeNotifierProvider<CaptchaService>(
          //lazy: false,
          create: (_) => CaptchaService(),
        ),
        ChangeNotifierProvider<FavoriteService>(
          //lazy: false,
          create: (_) => FavoriteService(),
        ),
        ChangeNotifierProvider<RespondService>(
          //lazy: false,
          create: (_) => RespondService(),
        ),
        ChangeNotifierProvider<ThemeService>(
          //lazy: false,
          create: (_) => ThemeService(),
        ),
        ChangeNotifierProvider<TokenService>(
          //lazy: false,
          create: (_) => TokenService(),
        ),
        ChangeNotifierProvider<UserService>(
          lazy: false,
          create: (_) => UserService(),
        ),
        ChangeNotifierProvider<QuestionService>(
          lazy: false,
          create: (_) => QuestionService(),
        ),
        ChangeNotifierProvider<AnswerService>(
          lazy: false,
          create: (_) => AnswerService(),
        ),
      ],
      child: MyApp(
        oldVersion: oldVersion,
        oldBuildNumber: oldBuildNumber,
        version: version,
        buildNumber: buildNumber,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
    this.oldVersion,
    this.oldBuildNumber,
    this.version,
    this.buildNumber,
  }) : super(key: key);

  final String? oldVersion;
  final String? oldBuildNumber;
  final String? version;
  final String? buildNumber;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Provider.of<ThemeService>(context),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          restorationScopeId: 'app',
          theme: ThemeData(),
          darkTheme: ThemeData.dark(),
          themeMode: Provider.of<ThemeService>(context).themeMode,
          initialRoute: version != oldVersion || buildNumber != oldBuildNumber
              ? '/privacy'
              : '/home',
          routes: <String, WidgetBuilder>{
            "/home": (BuildContext context) => const MyHomePage(),
            "/signin": (BuildContext context) => const SigninPage(),
            "/privacy": (BuildContext context) => PrivacyPage(
                  version: version,
                  buildNumber: buildNumber,
                ),
          },
        );
      },
    );
  }
}
