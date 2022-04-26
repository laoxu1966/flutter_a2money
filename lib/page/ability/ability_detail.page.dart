import 'dart:core';

import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/ability.model.dart';
import '../../model/respond.model.dart';
import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/pref.service.dart';
import '../../service/ability.service.dart';

import '../my/other.page.dart';
import '../respond/respond_detail.page.dart';
import '../respond/create_respond.page.dart';

import 'abilities.page.dart';
import 'update_ability.page.dart';

class AbilityDetailPage extends StatefulWidget {
  final int? id;
  @override
  const AbilityDetailPage({Key? key, this.id}) : super(key: key);

  @override
  AbilityDetailPageState createState() => AbilityDetailPageState();
}

class AbilityDetailPageState extends State<AbilityDetailPage> {
  List<Panel> panels = [];

  Future<Ability?>? futureAbility;
  Ability? ability;

  User? user;

  Future<Ability?> _getData() async {
    final response = await context.read<AbilityService>().findOne(widget.id);

    if (response != null && response?.statusCode == 200) {
      return response.ability;
    } else if (response?.statusCode == 404) {
      showToast('没有找到数据', context);
      return null;
    } else {
      showToast(response?.statusMessage, context);
      return null;
    }
  }

  Future _deleteAbility(int? id) async {
    var response = await Provider.of<AbilityService>(context, listen: false)
        .deleteAbility(id);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功，请稍后刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为没有找到数据。', context);
    } else if (response?.statusCode == 406) {
      showToast('提交失败，因为已经有响应。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _updateMemo(int id, String? memo) async {
    var response = await Provider.of<AbilityService>(context, listen: false)
        .updateMemo(id, memo);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  String _resolveStatus(Respond? respond) {
    if (respond!.settlement!.isNotEmpty) {
      return '已确定最终结算方案';
    } else if (respond.settlementA!.isNotEmpty ||
        respond.settlementB!.isNotEmpty) {
      return '已提交结算方案';
    } else if (respond.contract!.isNotEmpty &&
        (respond.contractA!.isNotEmpty || respond.contractB!.isNotEmpty)) {
      return '已提交变更请求';
    } else if (respond.contract!.isNotEmpty) {
      return '发起方已同意签约';
    } else {
      return '响应方已提交合约';
    }
  }

  @override
  void initState() {
    super.initState();

    futureAbility = _getData();

    panels = [
      '关于供给或需求的描述',
      '关于交易风险的提示',
      '响应截止日期和时间',
      '发起方电子邮件账号',
      '发起方手机号码',
      '发起方地理位置',
    ]
        .map(
          (s) => Panel(header: s, isExpanded: false),
        )
        .toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _detailleading() {
    return getAvatar(ability!.profile!['avatar']);
  }

  Widget _detailtitle() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          child: Text(
            ability!.profile!['displayName'],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtherPage(
                  uid: ability!.uid,
                  profile: ability!.profile!,
                ),
              ),
            );
          },
        ),
        Text(
          formatter.format(ability!.created!),
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          formatter.format(ability!.updated!),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _detailtrailing() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<AbilityAction>>[
          PopupMenuItem(
            enabled: ability!.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  Entypo.pencil,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '修改此交易',
                )
              ],
            ),
            value: AbilityAction.UPDATE,
          ),
          PopupMenuItem(
            enabled: ability!.responds!.isEmpty && ability!.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.delete,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '删除此交易',
                )
              ],
            ),
            value: AbilityAction.DELETE,
          ),
        ];
      },
      onSelected: (AbilityAction selected) async {
        switch (selected) {
          case AbilityAction.UPDATE:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateAbilityPage(
                  id: widget.id,
                  ability: ability,
                ),
              ),
            ).then(
              (value) => setState(() {
                futureAbility = _getData();
              }),
            );
            break;

          case AbilityAction.DELETE:
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要删除这个能力变现交易吗？'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                _deleteAbility(ability!.id);
              }
              return;
            });
            break;
          default:
            showToast('$selected', context);
            break;
        }
      },
    );
  }

  Widget _title() {
    return Text(
      ability!.title,
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.grey,
      ),
    );
  }

  Widget _respondDateTime() {
    return Text(
      '${ability!.respondDate}  ${ability!.respondTime}',
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

  Widget _classification() {
    Widget classification = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AbilitysPage(
              title: '分类 > ${classificationArr[ability!.classification]}',
              path: '/ability/classification',
              params: {'classification': ability!.classification},
            ),
          ),
        );
      },
      child: Chip(
        label: Text(
          classificationArr[ability!.classification],
        ),
      ),
    );

    Widget tag = Container();
    if (ability!.tag!.isNotEmpty) {
      tag = GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '标签 > ${ability!.tag}',
                path: '/ability/tag',
                params: {
                  'classification': ability!.classification,
                  'tag': ability!.tag
                },
              ),
            ),
          );
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text: ability!.tag,
            ),
          );
          showToast('已将这个标签复制到剪贴板。', context);
        },
        child: Chip(
          label: Text(
            ability!.tag!,
          ),
        ),
      );
    }

    return Container(
      alignment: Alignment.topLeft,
      child: Wrap(
        runSpacing: 0,
        spacing: 3,
        children: [
          classification,
          const SizedBox(
            width: 3,
          ),
          tag,
        ],
      ),
    );
  }

  Widget _des() {
    return Text(
      ability!.des,
      style: const TextStyle(
        fontSize: 15.0,
        color: Colors.grey,
      ),
    );
  }

  Widget _risk() {
    return Text(
      ability!.risk,
      style: const TextStyle(
        fontSize: 15.0,
        color: Colors.grey,
      ),
    );
  }

  Widget _email() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if ((ability!.email ?? '').isNotEmpty)
          GestureDetector(
            child: Text(
              '${ability!.email}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'mailto',
                path: '${ability!.email}',
              );
              await canLaunchUrl(uri)
                  ? await launchUrl(uri)
                  : showToast('无法启动 $uri', context);
            },
          ),
      ],
    );
  }

  Widget _tel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if ((ability!.tel ?? '').isNotEmpty)
          GestureDetector(
            child: Text(
              '${ability!.tel}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            onTap: () async {
              final Uri uri = Uri(
                scheme: 'tel',
                path: '${ability!.tel}',
              );
              await canLaunchUrl(uri)
                  ? await launchUrl(uri)
                  : showToast('无法启动 $uri', context);
            },
          )
      ],
    );
  }

  Widget _geo() {
    if ((ability!.geo ?? '').isEmpty) return Container();

    return GestureDetector(
      child: Text(
        '${ability!.geo}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
      onTap: () async {
        final Uri uri = Uri(
          scheme: 'geo',
          path: '${ability!.geo}',
        );
        await canLaunchUrl(uri)
            ? await launchUrl(uri)
            : showToast('无法启动 $uri', context);
      },
    );
  }

  Widget _respond(Respond respond) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    String updated = '';
    if (Pref.containsKey('respondUpdate' '_' + respond.id.toString())) {
      updated = Pref.getString('respondUpdate' '_' + respond.id.toString())!;
    }

    Widget _respondLeading = Badge(
      showBadge: updated.isEmpty || updated != respond.updated!.toString()
          ? false
          : true,
      badgeContent: const Text(""),
      child: getAvatar(respond.profile!['avatar']),
    );

    Widget _respondTitle = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          child: Text(
            respond.profile!['displayName'],
          ),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtherPage(
                  uid: respond.uid,
                  profile: respond.profile,
                ),
              ),
            );
          },
        ),
        if ((respond.memo ?? '').isNotEmpty)
          Text(
            '(${respond.memo!})',
            style: const TextStyle(color: Colors.grey),
          ),
        Text(
          formatter.format(respond.created!),
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          formatter.format(respond.updated!),
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          _resolveStatus(respond),
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );

    Widget _respondtrailing = PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<RespondAction>>[
          PopupMenuItem(
            enabled: ability!.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  MaterialCommunityIcons.note_outline,
                ),
                Container(width: 15),
                const Text(
                  '设置备注',
                )
              ],
            ),
            value: RespondAction.MEMO,
          ),
          PopupMenuItem(
            enabled: ability!.uid == user?.id || respond.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  MaterialCommunityIcons.note_outline,
                ),
                Container(width: 15),
                const Text(
                  '查看响应详情',
                )
              ],
            ),
            value: RespondAction.VIEW,
          ),
        ];
      },
      onSelected: (RespondAction selected) async {
        switch (selected) {
          case RespondAction.MEMO:
            showDialog<String>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  memo(context, respond.memo ?? ''),
            ).then((value) async {
              if (value != null) {
                respond.memo = value;
                _updateMemo(respond.id!, respond.memo)
                    .then((value) => setState(() {
                          futureAbility = _getData();
                        }));
              }

              return;
            });
            break;

          case RespondAction.VIEW:
            if (updated.isEmpty || updated != respond.updated!.toString()) {
              await Pref.setString(
                'respondUpdate' '_' + respond.id.toString(),
                respond.updated.toString(),
              );
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RespondDetailPage(
                  id: respond.id,
                ),
              ),
            );
            break;

          default:
            showToast('$selected', context);
            break;
        }
      },
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 6, top: 6, bottom: 6),
        child: Row(
          children: <Widget>[
            _respondLeading,
            const SizedBox(
              width: 18,
            ),
            Expanded(
              child: _respondTitle,
            ),
            _respondtrailing,
          ],
        ),
      ),
    );
  }

  Widget _responds() {
    List<Widget> responds = ability!.responds!
        .where((respond) => respond.uid == user?.id || ability!.uid == user?.id)
        .map((respond) {
      return _respond(respond);
    }).toList();

    if (responds.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: responds,
      );
    }

    DateTime deliver = DateFormat("yyyy-MM-dd hh:mm")
        .parse(ability!.respondDate + ' ' + ability!.respondTime);

    if (ability!.uid != user?.id && DateTime.now().isBefore(deliver)) {
      return ElevatedButton(
        child: const Text(
          '响应此交易',
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateRespondPage(
                ability: ability,
              ),
            ),
          ).then(
            (value) => setState(() {
              futureAbility = _getData();
            }),
          );
        },
      );
    }

    return Container();
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
            panel = _des();
            break;

          case 1:
            panel = _risk();
            break;

          case 2:
            panel = _respondDateTime();
            break;

          case 3:
            panel = _email();
            break;

          case 4:
            panel = _tel();
            break;

          case 5:
            panel = _geo();
            break;

          default:
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

  Future<void> _refresh() async {
    setState(() {
      futureAbility = _getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('能力变现交易详情'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: FutureBuilder<Ability?>(
          future: futureAbility,
          builder: (BuildContext context, AsyncSnapshot<Ability?> snapshot) {
            if (snapshot.hasData) {
              ability = snapshot.data;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _detailleading(),
                          const SizedBox(
                            width: 18,
                          ),
                          Expanded(
                            child: _detailtitle(),
                          ),
                          _detailtrailing(),
                        ],
                      ),
                      const SizedBox(height: 6.0),
                      _title(),
                      _classification(),
                      _expansionPanelList(),
                      const SizedBox(height: 6.0),
                      if (user == null)
                        ElevatedButton(
                          child: const Text(
                            '你还没有登录，无法响应或查看响应',
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/signin', (router) => true);
                          },
                        ),
                      if (user != null) _responds(),
                      const SizedBox(height: 6.0),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError &&
                snapshot.error.toString().contains('Too Many Requests')) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('你的访问太频繁，已经被暂时限流，请稍后重试。'),
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
      ),
    );
  }
}
