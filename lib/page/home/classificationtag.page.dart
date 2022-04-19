import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/search.model.dart';

import '../../service/ability.service.dart';

import '../ability/abilities.page.dart';

class ClassificationTagPage extends StatefulWidget {
  const ClassificationTagPage({Key? key}) : super(key: key);

  @override
  ClassificationTagPageState createState() => ClassificationTagPageState();
}

class ClassificationTagPageState extends State<ClassificationTagPage> {
  Future<List<Tag>?>? futureTags;
  List<Tag>? tags = [];

  Future<List<Tag>?> _getData() async {
    final response = await context.read<AbilityService>().classificationtag();

    if (response != null && response?.statusCode == 200) {
      return response.tags;
    } else {
      throw Exception(response?.statusMessage);
    }
  }

  @override
  void initState() {
    super.initState();

    futureTags = _getData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _title(int classification) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AbilitysPage(
              title: '分类 > ${classificationArr[classification]}',
              path: '/ability/classification',
              params: {'classification': classification},
            ),
          ),
        );
      },
      child: Text(
        classificationArr[classification],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _subtitle(int classification, List<String>? tags, bool isExpanded) {
    Iterable<String> _tags;
    if (isExpanded == false) {
      _tags = tags!.take(9);
    } else {
      _tags = tags!.take(99);
    }

    List<Widget> tagWidgets = _tags.map((tag) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '标签 > $tag',
                path: '/ability/tag',
                params: {'classification': classification, 'tag': tag},
              ),
            ),
          );
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text: tag,
            ),
          );
          showToast('已将这个标签复制到剪贴板。', context);
        },
        child: Text(
          tag + '，',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }).toList();

    return Container(
      margin: const EdgeInsets.only(top: 6.0, bottom: 6.0),
      child: Wrap(
        children: tagWidgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分类，分标签'),
      ),
      body: FutureBuilder<List<Tag>?>(
        future: futureTags,
        builder: (BuildContext context, AsyncSnapshot<List<Tag>?> snapshot) {
          if (snapshot.hasData) {
            tags = snapshot.data!;
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(6.0),
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      tags!.map((element) {
                        element.isExpanded = false;
                      });
                      tags![index].isExpanded = !isExpanded;
                    });
                  },
                  children: tags!.map<ExpansionPanel>((Tag tag) {
                    return ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                          title: _title(tag.classification),
                          subtitle: _subtitle(
                              tag.classification, tag.tags, isExpanded),
                        );
                      },
                      body: Container(),
                      isExpanded: tag.isExpanded,
                    );
                  }).toList(),
                ),
              ),
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
