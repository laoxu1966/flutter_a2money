import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../common/ui.dart';

class MarkdownPage extends StatefulWidget {
  final String? title;
  final String? file;
  @override
  const MarkdownPage({Key? key, this.title, this.file}) : super(key: key);

  @override
  MarkdownPageState createState() => MarkdownPageState();
}

class MarkdownPageState extends State<MarkdownPage> {
  Future<String>? futureString;

  Future<String> _getData() async {
    return await rootBundle.loadString(widget.file!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: FutureBuilder<String>(
        future: futureString,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
              onTapLink: (text, url, title) async {
                if (url!.startsWith('https://') || url.startsWith('http://')) {
                  final Uri uri = Uri.parse(url);
                  await canLaunchUrl(uri)
                      ? await launchUrl(uri)
                      : showToast('无法启动 $uri', context);
                } else if (url.endsWith('.md')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MarkdownPage(
                        title: title,
                        file: 'assets/markdown/' + url,
                      ),
                    ),
                  );
                }
              },
            );
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
