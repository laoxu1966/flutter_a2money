import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../service/dio.service.dart';
import '../../service/theme.service.dart';

import 'markdown.page.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({Key? key}) : super(key: key);
  @override
  DrawerPageState createState() => DrawerPageState();
}

class DrawerPageState extends State<DrawerPage> {
  String version = '';
  String buildNumber = '';
  String newversion = '';
  String newbuildNumber = '';

  Future _init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
    newversion = version;
    newbuildNumber = buildNumber;

    var response = await DioSingleton().dioGet('/version');
    Map<String, dynamic>? parsedJson = response.data;
    if (parsedJson!.isNotEmpty) {
      newversion = parsedJson['version'];
      newbuildNumber = parsedJson['buildNumber'];
    }

    setState(() {
      //
    });
  }

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/image/icon.jpg',
                  //fit: BoxFit.fill,
                ),
                const SizedBox(
                  width: 12,
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(
              '关于',
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarkdownPage(
                      title: '关于', file: 'assets/markdown/README.md'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text(
              '帮助',
            ),
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarkdownPage(
                      title: '帮助', file: 'assets/markdown/HELP.md'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.note),
            title: const Text(
              '服务条款',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarkdownPage(
                      title: '服务条款', file: 'assets/markdown/TERMS.md'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text(
              '隐私政策',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarkdownPage(
                      title: '隐私政策', file: 'assets/markdown/PRIVACY.md'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text(
              '商业流程',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarkdownPage(
                      title: '商业流程', file: 'assets/markdown/BUSINESS.md'),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.call),
            title: const Text(
              '联系我们',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarkdownPage(
                      title: '联系我们', file: 'assets/markdown/CONTACT.md'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.update),
            title: Text(
              '当前版本：$version+$buildNumber',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            subtitle: GestureDetector(
              child: Text('检测最新：$newversion+$newbuildNumber'),
              onTap: '$version+$buildNumber' != '$newversion+$newbuildNumber'
                  ? () {
                      showDialog<ConfirmDialogAction>(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) =>
                            confirm(context, '确定要通过浏览器下载并更新吗？'),
                      ).then<ConfirmDialogAction?>(
                          (ConfirmDialogAction? value) async {
                        if (value == ConfirmDialogAction.OK) {
                          String url = 'https://www.a2money.com:3000/download';
                          await canLaunch(url)
                              ? await launch(url)
                              : showToast('无法启动 $url', context);
                        }
                        return;
                      });
                    }
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text(
              '暗黑主题',
            ),
            trailing: CupertinoSwitch(
              value: Provider.of<ThemeService>(context).themeMode ==
                  ThemeMode.dark,
              activeColor: Theme.of(context).colorScheme.secondary,
              onChanged: (bool value) {
                Provider.of<ThemeService>(context, listen: false)
                    .updateThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                setState(() {
                  //
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
