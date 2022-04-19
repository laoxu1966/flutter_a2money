import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';
import '../../model/search.model.dart';

import '../../service/user.service.dart';
import '../../service/pref.service.dart';
import '../../service/ability.service.dart';

import '../ability/abilities.page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  User? user;

  List<Hot>? hots = [];
  List<String> keywords = [];
  List<Panel> panels = [];

  List<String> matchs = ['不限', '仅标题', '仅正文'];
  int matchSelected = 0;

  List<String> payings = ['不限', '仅供给', '仅需求'];
  int payingSelected = 0;

  List<String> classifications = ['不限', ...classificationArr];
  int classificationSelected = 0;

  final TextEditingController skController = TextEditingController();

  Future _getData() async {
    if (Pref.containsKey('keyword')) {
      keywords = Pref.getStringList('keyword')!;
    }

    var response = await context.read<AbilityService>().hot();

    if (response != null && response?.statusCode == 200) {
      hots = response.hots;

      if (mounted) {
        setState(() {
          //
        });
      }
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _deleteKeyword(String? sk) async {
    keywords.removeWhere((element) => element == sk);
    await Pref.setStringList('keyword', keywords);

    setState(() {
      //
    });
  }

  @override
  void initState() {
    super.initState();

    panels = ['热门搜索', '历史搜索']
        .map(
          (s) => Panel(header: s, isExpanded: false),
        )
        .toList();

    _getData();
  }

  Future _submit() async {
    String sk = skController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AbilitysPage(
          title: '搜索 > $sk',
          path: '/ability/search',
          params: {
            'match': matchSelected,
            'paying': payingSelected,
            'classification': classificationSelected,
            'sk': sk
          },
        ),
      ),
    );

    if (keywords.contains(sk) == false) {
      keywords.add(sk);
      await Pref.setStringList('keyword', keywords);
    }

    setState(() {
      //
    });
  }

  Widget _search() {
    return Container(
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: Colors.grey),
        ),
      ),
      child: TextField(
        controller: skController,
        onSubmitted: (String text) {
          if (skController.text != '') {
            _submit();
          }
        },
        decoration: InputDecoration(
          hintText: '支持布尔表达式语法，详见帮助',
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            onPressed: () {
              if (skController.text != '') {
                _submit();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _match() {
    return DropdownButtonFormField(
      value: matchSelected,
      decoration: const InputDecoration(
        labelText: '关键词出现位置',
      ),
      onChanged: (dynamic val) {
        setState(() {
          matchSelected = val;
        });
      },
      items: matchs.map((item) {
        return DropdownMenuItem(
          child: Text(item),
          value: matchs.indexOf(item),
        );
      }).toList(),
    );
  }

  Widget _paying() {
    return DropdownButtonFormField(
      value: payingSelected,
      decoration: const InputDecoration(
        labelText: '交易类型',
      ),
      onChanged: (dynamic val) {
        setState(() {
          payingSelected = val;
        });
      },
      items: payings.map((item) {
        return DropdownMenuItem(
          child: Text(item),
          value: payings.indexOf(item),
        );
      }).toList(),
    );
  }

  Widget _classification() {
    return DropdownButtonFormField(
      value: classificationSelected,
      decoration: const InputDecoration(
        labelText: '能力类型',
      ),
      onChanged: (dynamic val) {
        setState(() {
          classificationSelected = val;
        });
      },
      items: classifications.map((item) {
        return DropdownMenuItem(
          child: Text(item),
          value: classifications.indexOf(item),
        );
      }).toList(),
    );
  }

  Widget _hot() {
    List<Widget> hotWidgets = hots!.map((item) {
      return GestureDetector(
        child: Chip(
          label: Text(
            item.hot,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AbilitysPage(
                title: '搜索 > ${item.hot}',
                path: '/ability/search',
                params: {
                  'match': matchSelected,
                  'paying': payingSelected,
                  'classification': classificationSelected,
                  'sk': item.hot
                },
              ),
            ),
          );
        },
      );
    }).toList();

    return Container(
      alignment: Alignment.topLeft,
      child: Wrap(runSpacing: 0, spacing: 3, children: hotWidgets),
    );
  }

  Widget _history() {
    List<Widget> historyWidgets = keywords.map((item) {
      return GestureDetector(
        child: Chip(
          label: Text(
            item,
          ),
          deleteIconColor: Colors.grey,
          onDeleted: () {
            _deleteKeyword(item);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => AbilitysPage(
                title: '搜索 > $item',
                path: '/ability/search',
                params: {
                  'match': matchSelected,
                  'paying': payingSelected,
                  'classification': classificationSelected,
                  'sk': item
                },
              ),
            ),
          );
        },
      );
    }).toList();

    return Container(
      alignment: Alignment.topLeft,
      child: Wrap(runSpacing: 0, spacing: 3, children: historyWidgets),
    );
  }

  Widget _expansionPanelList() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          panels.map((element) {
            element.isExpanded = false;
          });
          panels[index].isExpanded = !isExpanded;
        });
      },
      children: panels.map<ExpansionPanel>((Panel item) {
        Widget panel = Container();

        switch (panels.indexOf(item)) {
          case 0:
            panel = _hot();
            break;

          case 1:
            panel = _history();
            break;

          default:
            {
              //
            }
            break;
        }

        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                item.header + '\r\n',
              ),
              subtitle: item.isExpanded ? panel : Container(),
            );
          },
          body: Container(),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('搜索'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _search(),
              const SizedBox(
                height: 6,
              ),
              _match(),
              _paying(),
              _classification(),
              const SizedBox(
                height: 12,
              ),
              _expansionPanelList(),
            ],
          ),
        ),
      ),
    );
  }
}
