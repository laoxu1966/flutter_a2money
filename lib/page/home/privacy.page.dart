import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intro_slider/slide_object.dart';

import 'package:flutter_markdown/flutter_markdown.dart';

import '../../service/pref.service.dart';

import 'intro.page.dart';

class PrivacyPage extends StatefulWidget {
  final String? version;
  final String? buildNumber;
  @override
  const PrivacyPage({Key? key, this.version, this.buildNumber})
      : super(key: key);

  @override
  PrivacyPageState createState() => PrivacyPageState();
}

class PrivacyPageState extends State<PrivacyPage> {
  Future<String>? futureString;

  Future<String> _getData() async {
    return await rootBundle.loadString('assets/markdown/PRIVACY.md');
  }

  @override
  void initState() {
    super.initState();

    futureString = _getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _input(String? data) {
    return Column(
      children: <Widget>[
        Expanded(
          child: Markdown(
            data: data!,
          ),
        ),
        const SizedBox(
          height: 3,
        ),
        Row(
          children: [
            const SizedBox(
              width: 51,
            ),
            ElevatedButton(
              child: const Text(
                '不同意并退出',
              ),
              onPressed: () {
                SystemNavigator.pop();
              },
            ),
            const SizedBox(
              width: 6,
            ),
            ElevatedButton(
              child: const Text(
                '同意并继续使用',
              ),
              onPressed: () async {
                await Pref.setString('version', widget.version!);
                await Pref.setString('buildNumber', widget.buildNumber!);

                List<Slide> slides = [];

                slides.add(
                  Slide(
                    widgetTitle: Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '缘起\r\n\r\n\r\n',
                              style: TextStyle(
                                fontSize: 36.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const TextSpan(
                              text: '很多人，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '空有一身才华和能力，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '却没有获得\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '与能力相匹配的\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '财富和社会地位，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '令人扼腕叹息。\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                  ),
                );

                slides.add(
                  Slide(
                    widgetTitle: Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '愿景\r\n\r\n\r\n',
                              style: TextStyle(
                                fontSize: 36.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const TextSpan(
                              text: '本平台试图打造一个\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '创新的\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '能力变现商业模式，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '实现这个愿景的路径就是\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '能力量化\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '以及能力市场化。',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                  ),
                );

                slides.add(
                  Slide(
                    widgetTitle: Center(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '痛点\r\n\r\n\r\n',
                              style: TextStyle(
                                fontSize: 36.0,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const TextSpan(
                              text: '由于规则不透明，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '以及信息不对称，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '交易过程充满坎坷和风险。\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '本平台利用支付宝的预授权机制，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '双方都要冻结全额的保证金，\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                            const TextSpan(
                              text: '这样大大降低了交易的风险。\r\n\r\n',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 18.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                  ),
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IntroPage(slides: slides),
                  ),
                );
              },
            ),
            const SizedBox(
              width: 6,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
      ),
      body: FutureBuilder<String>(
        future: futureString,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return _input(snapshot.data!);
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('${snapshot.error}'),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
