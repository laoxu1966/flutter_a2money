import 'dart:core';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tobias/tobias.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/respond.model.dart';
import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/token.service.dart';
import '../../service/respond.service.dart';

import '../my/other.page.dart';

import 'update_contract.page.dart';
import 'update_settlement.page.dart';

class RespondDetailPage extends StatefulWidget {
  final int? id;
  @override
  const RespondDetailPage({Key? key, this.id}) : super(key: key);

  @override
  RespondDetailPageState createState() => RespondDetailPageState();
}

class RespondDetailPageState extends State<RespondDetailPage> {
  List<Panel> panels = [];

  Future<Respond?>? futureRespond;
  Respond? respond;
  User? user;

  Future<Respond?> _getData() async {
    final response = await context.read<RespondService>().findOne(widget.id);

    if (response != null && response?.statusCode == 200) {
      return response.respond;
    } else if (response?.statusCode == 404) {
      throw Exception('没有找到数据');
    } else {
      throw Exception(response?.statusMessage);
    }
  }

  Future _updateContractAB(
    int? id,
    Map<String, dynamic> contractAB,
  ) async {
    var response = await Provider.of<RespondService>(context, listen: false)
        .updateContractAB(id, contractAB);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功，稍后请刷新。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _updateContract(
    int? id,
    Map<String, dynamic> contract,
  ) async {
    var response = await Provider.of<RespondService>(context, listen: false)
        .updateContract(id, contract);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功，稍后请刷新。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _updateSettlementAB(
    int? id,
    Map<String, dynamic> settlementAB,
  ) async {
    var response = await Provider.of<RespondService>(context, listen: false)
        .updateSettlementAB(id, settlementAB);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功，稍后请刷新。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _updateSettlement(
    int? id,
    Map<String, dynamic> settlement,
  ) async {
    var response = await Provider.of<RespondService>(context, listen: false)
        .updateSettlement(id, settlement);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功，稍后请刷新。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _freeze(
    int? tokenid,
  ) async {
    var response =
        await Provider.of<TokenService>(context, listen: false).freeze(tokenid);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Uri uri = Uri.tryParse(response.payUrl) ?? Uri();
      Map<dynamic, dynamic> query = await aliPay(uri.query);
      String? resultStatus = query['resultStatus'];

      if (resultStatus == '9000') {
        showToast('提交成功，正在等待异步通知，请稍后刷新。', context);
      } else {
        showToast('提交未成功，请查看支付宝返回的消息。', context);
      }
    } else if (response?.statusCode == 404) {
      showToast('没有找到数据', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _unfreezeorpay(
    int? respondid,
    int? tokenid,
  ) async {
    var response = await Provider.of<TokenService>(context, listen: false)
        .unfreezeorpay(respondid, tokenid);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功，稍后请刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为没有找到数据', context);
    } else if (response?.statusCode == 412) {
      showToast('提交未成功，因为超出了应支付的金额。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _trans(
    int? respondid,
    int? tokenid,
  ) async {
    var response = await Provider.of<TokenService>(context, listen: false)
        .trans(respondid, tokenid);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功，稍后请刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为没有找到数据', context);
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

  Future _deleteRespond(int? id) async {
    var response = await Provider.of<RespondService>(context, listen: false)
        .deleteRespond(id);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功，稍后请刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为没有找到数据。', context);
    } else if (response?.statusCode == 406) {
      showToast('提交失败，因为发起方已经同意签约。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  @override
  void initState() {
    super.initState();

    futureRespond = _getData();

    panels = [
      '响应方提交的合约(变更)',
      '发起方提交的变更',
      '双方达成的合约',
      '响应方的资金详情',
      '发起方的资金详情',
      '响应方提交结算方案',
      '发起方提交结算方案',
      '最终结算方案',
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
    return getAvatar(respond!.profile!['avatar']);
  }

  Widget _detailtitle() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          child: Text(
            respond!.profile!['displayName'],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtherPage(
                  uid: respond!.uid!,
                  profile: respond!.profile,
                ),
              ),
            );
          },
        ),
        Text(
          formatter.format(respond!.created!),
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          formatter.format(respond!.updated!),
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
  }

  Widget _detailtrailing() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<RespondAction>>[
          PopupMenuItem(
            enabled: respond!.uid == user?.id && respond!.contract!.isEmpty,
            child: Row(
              children: <Widget>[
                const Icon(
                  Entypo.pencil,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '修改此响应',
                )
              ],
            ),
            value: RespondAction.UPDATE,
          ),
          PopupMenuItem(
            enabled: respond!.uid == user?.id && respond!.contract!.isEmpty,
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.delete,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '删除此响应',
                )
              ],
            ),
            value: RespondAction.DELETE,
          ),
        ];
      },
      onSelected: (RespondAction selected) async {
        switch (selected) {
          case RespondAction.UPDATE:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateContractPage(
                  id: respond!.id,
                  contractAB: respond!.contractB,
                ),
              ),
            ).then(
              (value) => setState(() {
                futureRespond = _getData();
              }),
            );
            break;
          case RespondAction.DELETE:
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要删除这个响应吗？'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) _deleteRespond(respond!.id);

              return;
            });
            break;

          default:
            showToast(selected.toString(), context);
            break;
        }
      },
    );
  }

  Widget _contractB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['paying'] !=
                    respond!.contract!['paying'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '支付方向：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${payingArr[respond!.contractB!['paying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['payable'] !=
                    respond!.contract!['payable'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '合约金额：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractB!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['understand'] !=
                    respond!.contract!['understand'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '对交易的理解：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractB!['understand']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['subject'] !=
                    respond!.contract!['subject'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付物及其规格条件：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractB!['subject']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['deliver'] !=
                    respond!.contract!['deliver'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付方式：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractB!['deliver']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['deliverDate'] !=
                    respond!.contract!['deliverDate'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付截止日期：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractB!['deliverDate']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['deliverTime'] !=
                    respond!.contract!['deliverTime'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付截止时间：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractB!['deliverTime']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractB!['violate'] !=
                    respond!.contract!['violate'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '违约责任：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractB!['violate']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.uid == user?.id)
          ElevatedButton(
            child: respond!.contractB!.isNotEmpty
                ? const Text(
                    '响应方修改变更请求',
                  )
                : const Text(
                    '响应方提交变更请求',
                  ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateContractPage(
                    id: respond!.id,
                    contractAB: respond!.contractB!.isNotEmpty
                        ? respond!.contractB
                        : respond!.contract,
                  ),
                ),
              ).then(
                (value) => setState(() {
                  futureRespond = _getData();
                }),
              );
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.contractB!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.uid == user?.id)
          ElevatedButton(
            child: const Text(
              '响应方撤回变更请求',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要撤回这个变更请求吗？'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateContractAB(
                    respond!.id,
                    {},
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.contractB!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.abilityuid == user?.id)
          ElevatedButton(
            child: const Text(
              '发起方同意变更请求',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要同意这个变更请求吗？'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateContract(
                    respond!.id,
                    respond!.contractB!,
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
        if (respond!.contract!.isEmpty &&
            respond!.contractB!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.abilityuid == user?.id)
          ElevatedButton(
            child: const Text(
              '发起方同意签约',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要同意签约吗？'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateContract(
                    respond!.id,
                    respond!.contractB!,
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
      ],
    );
  }

  Widget _contractA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['paying'] !=
                    respond!.contract!['paying'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '支付方向：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${payingArr[respond!.contractA!['paying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['payable'] !=
                    respond!.contract!['payable'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '合约金额：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractA!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['understand'] !=
                    respond!.contract!['understand'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '对交易的理解：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractA!['understand']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['subject'] !=
                    respond!.contract!['subject'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付物及其规格条件：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractA!['subject']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['deliver'] !=
                    respond!.contract!['deliver'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付方式：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractA!['deliver']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['deliverDate'] !=
                    respond!.contract!['deliverDate'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付截止日期：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractA!['deliverDate']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['deliverTime'] !=
                    respond!.contract!['deliverTime'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '交付截止时间：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractA!['deliverTime']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contractA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                if (respond!.contractA!['violate'] !=
                    respond!.contract!['violate'])
                  const TextSpan(
                    text: '* ',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                const TextSpan(
                  text: '违约责任：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contractA!['violate']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.abilityuid == user?.id)
          ElevatedButton(
            child: respond!.contractA!.isNotEmpty
                ? const Text(
                    '发起方修改变更请求',
                  )
                : const Text(
                    '发起方提交变更请求',
                  ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateContractPage(
                    id: respond!.id,
                    contractAB: respond!.contractA!.isNotEmpty
                        ? respond!.contractA
                        : respond!.contract,
                  ),
                ),
              ).then(
                (value) => setState(() {
                  futureRespond = _getData();
                }),
              );
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.contractA!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.abilityuid == user?.id)
          ElevatedButton(
            child: const Text(
              '发起方撤回变更请求',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要撤回这个变更请求吗？'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateContractAB(
                    respond!.id,
                    {},
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.contractA!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.uid == user?.id)
          ElevatedButton(
            child: const Text(
              '响应方同意变更请求',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要同意这个变更请求吗？'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateContract(
                    respond!.id,
                    respond!.contractA!,
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
      ],
    );
  }

  Widget _contract() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '支付方向：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${payingArr[respond!.contract!['paying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '合约金额：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '对交易的理解：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['understand']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '交付物及其规格条件：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['subject']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '交付方式：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['deliver']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '交付截止日期：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['deliverDate']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '交付截止时间：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['deliverTime']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '违约责任：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['violate']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _tokenB() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    DateTime deliver = DateTime.now();
    String deliverDate = respond!.contract!['deliverDate'] ?? '';
    String deliverTime = respond!.contract!['deliverTime'] ?? '';
    if (deliverDate.isNotEmpty && deliverTime.isNotEmpty) {
      deliver =
          DateFormat("yyyy-MM-dd hh:mm").parse(deliverDate + ' ' + deliverTime);
    }
    deliver = deliver.add(const Duration(minutes: 15 * 1440));

    int paying = -1;
    if (respond!.contract!.isNotEmpty &&
        respond!.settlementA!.isEmpty &&
        respond!.settlementB!.isEmpty &&
        DateTime.now().isAfter(deliver)) {
      paying = respond!.contract!['paying'];
    }
    if (respond!.contract!.isNotEmpty && respond!.settlement!.isNotEmpty) {
      paying = respond!.settlement!['paying'];
    }

    List<TableRow> rows = respond!.tokens!
        .where((element) => element.uid == respond!.uid)
        .map((element) {
      return TableRow(
        children: [
          TableCell(
            child: Text(
              '${double.tryParse(element.payable.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.freeze!.toStringAsFixed(3)) ?? 0.01}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.unfreeze!.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.pay!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.income!.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.fee!.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.cash!.toStringAsFixed(3)) ?? 0.01}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              element.msg!,
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.created!)}\r\n${formatter.format(element.updated!)}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          if (element.uid == user!.id && (0.0).compareTo(element.freeze!) == 0)
            TableCell(
              child: ElevatedButton(
                child: const Text(
                  '预授权',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要通过支付宝来预授权吗？请先确保你已经安装支付宝客户端并且已登录支付宝客户端。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _freeze(
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
          if (element.uid == user!.id &&
              element.freeze! > 0 &&
              (0.0).compareTo(element.unfreeze!) == 0 &&
              ((paying == 0 && respond!.abilityuid == user!.id) ||
                  (paying == 1 && respond!.uid == user!.id)))
            TableCell(
              child: ElevatedButton(
                child: const Text(
                  '结算',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要进行结算吗？这意味着将解除预授权或者预授权转支付，具体操作取决于支付方向。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _unfreezeorpay(
                        respond!.id,
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
           if (element.uid == user!.id &&
              element.freeze! > 0 &&
              (0.0).compareTo(element.pay!) == 0 &&
              ((paying == 1 && respond!.abilityuid == user!.id) ||
                  (paying == 0 && respond!.uid == user!.id)))
            TableCell(
              child: ElevatedButton(
                child: const Text(
                  '结算',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要进行结算吗？这意味着将解除预授权或者预授权转支付，具体操作取决于支付方向。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _unfreezeorpay(
                        respond!.id,
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
          if (element.uid == user!.id &&
              paying > -1 &&
              element.freeze! > 0 &&
              element.unfreeze! > 0 &&
              element.income! > 0 &&
              (0.0).compareTo(element.cash!) == 0)  TableCell(
              child: ElevatedButton(
                child: const Text(
                  '提现',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要提现到你的支付宝账户吗？如果成功，你可以在支付宝上查看到这笔转账记录。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _trans(
                        respond!.id,
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
        ],
      );
    }).toList();

    if (rows.isNotEmpty) {
      rows.insert(
        0,
        const TableRow(
          children: [
            TableCell(
              child: Text(
                '应付/实付   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '解除/转支付   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '收入/手续费/提现   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '支付宝消息   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '创建/更新',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '操作\r\n',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Table(
          children: rows,
          defaultColumnWidth: const IntrinsicColumnWidth(),
        ),
      ),
    );
  }

  Widget _tokenA() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    DateTime deliver = DateTime.now();
    String deliverDate = respond!.contract!['deliverDate'] ?? '';
    String deliverTime = respond!.contract!['deliverTime'] ?? '';
    if (deliverDate.isNotEmpty && deliverTime.isNotEmpty) {
      deliver =
          DateFormat("yyyy-MM-dd hh:mm").parse(deliverDate + ' ' + deliverTime);
    }
    deliver = deliver.add(const Duration(minutes: 15 * 1440));

    int paying = -1;
    if (respond!.contract!.isNotEmpty &&
        respond!.settlementA!.isEmpty &&
        respond!.settlementB!.isEmpty &&
        DateTime.now().isAfter(deliver)) {
      paying = respond!.contract!['paying'];
    }
    if (respond!.contract!.isNotEmpty && respond!.settlement!.isNotEmpty) {
      paying = respond!.settlement!['paying'];
    }

    List<TableRow> rows = respond!.tokens!
        .where((element) => element.uid == respond!.abilityuid)
        .map((element) {
      return TableRow(
        children: [
          TableCell(
            child: Text(
              '${double.tryParse(element.payable.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.freeze!.toStringAsFixed(3)) ?? 0.01}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.unfreeze!.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.pay!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.income!.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.fee!.toStringAsFixed(3)) ?? 0.01}\r\n${double.tryParse(element.cash!.toStringAsFixed(3)) ?? 0.01}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              element.msg!,
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.created!)}\r\n${formatter.format(element.updated!)}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          if (element.uid == user!.id && (0.0).compareTo(element.freeze!) == 0)
            TableCell(
              child: ElevatedButton(
                child: const Text(
                  '预授权',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要通过支付宝来预授权吗？请先确保你已经安装支付宝客户端并且已登录支付宝客户端。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _freeze(
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
          if (element.uid == user!.id &&
              element.freeze! > 0 &&
              (0.0).compareTo(element.unfreeze!) == 0 &&
              ((paying == 0 && respond!.abilityuid == user!.id) ||
                  (paying == 1 && respond!.uid == user!.id)))
            TableCell(
              child: ElevatedButton(
                child: const Text(
                  '结算',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要进行结算吗？这意味着将解除预授权或者预授权转支付，具体操作取决于支付方向。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _unfreezeorpay(
                        respond!.id,
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
           if (element.uid == user!.id &&
              element.freeze! > 0 &&
              (0.0).compareTo(element.pay!) == 0 &&
              ((paying == 1 && respond!.abilityuid == user!.id) ||
                  (paying == 0 && respond!.uid == user!.id)))
            TableCell(
              child: ElevatedButton(
                child: const Text(
                  '结算',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要进行结算吗？这意味着将解除预授权或者预授权转支付，具体操作取决于支付方向。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _unfreezeorpay(
                        respond!.id,
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
          if (element.uid == user!.id &&
              paying > -1 &&
              element.freeze! > 0 &&
              element.unfreeze! > 0 &&
              element.income! > 0 &&
              (0.0).compareTo(element.cash!) == 0)  TableCell(
              child: ElevatedButton(
                child: const Text(
                  '提现',
                ),
                onPressed: () async {
                  showDialog<ConfirmDialogAction>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) => confirm(
                        context, '确定要提现到你的支付宝账户吗？如果成功，你可以在支付宝上查看到这笔转账记录。'),
                  ).then<ConfirmDialogAction?>(
                      (ConfirmDialogAction? value) async {
                    if (value == ConfirmDialogAction.OK) {
                      _trans(
                        respond!.id,
                        element.id,
                      ).then((value) => setState(() {
                            futureRespond = _getData();
                          }));
                    }
                    return;
                  });
                },
              ),
            ),
        ],
      );
    }).toList();

    if (rows.isNotEmpty) {
      rows.insert(
        0,
        const TableRow(
          children: [
            TableCell(
              child: Text(
                '应付/实付   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '解除/转支付   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '收入/手续费/提现   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '支付宝消息   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '创建/更新',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '操作\r\n',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0),
        child: Table(
          children: rows,
          defaultColumnWidth: const IntrinsicColumnWidth(),
        ),
      ),
    );
  }

  Widget _settlementB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (respond!.settlementB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '支付方向(原)：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text:
                      '${payingArr[respond!.settlementB!['originalpaying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '支付方向：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${payingArr[respond!.settlementB!['paying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '结算金额(原)：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '结算金额：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.settlementB!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementB!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '关于结算方案的说明：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.settlementB!['note']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.uid == user?.id)
          ElevatedButton(
            child: respond!.settlementB!.isNotEmpty
                ? const Text(
                    '响应方修改结算方案',
                  )
                : const Text(
                    '响应方提交结算方案',
                  ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateSettlementPage(
                    id: respond!.id,
                    settlementAB: respond!.settlementB!.isNotEmpty
                        ? respond!.settlementB
                        : {
                            "originalpaying": respond!.contract!['paying'],
                            "paying": respond!.contract!['paying'],
                            "originalpayable": respond!.contract!['payable'],
                            "payable": respond!.contract!['payable'],
                          },
                  ),
                ),
              ).then(
                (value) => setState(() {
                  futureRespond = _getData();
                }),
              );
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlementB!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.uid == user?.id)
          ElevatedButton(
            child: const Text(
              '响应方撤回结算方案',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要撤回结算方案吗？'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateSettlementAB(
                    respond!.id,
                    {},
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlementB!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.abilityuid == user?.id)
          ElevatedButton(
            child: const Text(
              '发起方同意结算方案',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要同意这个结算方案吗？这意味着，再也无法变更合约或提交结算方案。'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateSettlement(
                    respond!.id,
                    respond!.settlementB!,
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
      ],
    );
  }

  Widget _settlementA() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (respond!.settlementA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '支付方向(原)：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text:
                      '${payingArr[respond!.settlementA!['originalpaying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '支付方向：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${payingArr[respond!.settlementA!['paying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '结算金额(原)：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '结算金额：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.settlementA!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlementA!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '关于结算方案的说明：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.settlementA!['note']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.abilityuid == user?.id)
          ElevatedButton(
            child: respond!.settlementA!.isNotEmpty
                ? const Text(
                    '发起方修改结算方案',
                  )
                : const Text(
                    '发起方提交结算方案',
                  ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateSettlementPage(
                    id: respond!.id,
                    settlementAB: respond!.settlementA!.isNotEmpty
                        ? respond!.settlementA
                        : {
                            "originalpaying": respond!.contract!['paying'],
                            "paying": respond!.contract!['paying'],
                            "originalpayable": respond!.contract!['payable'],
                            "payable": respond!.contract!['payable'],
                          },
                  ),
                ),
              ).then(
                (value) => setState(() {
                  futureRespond = _getData();
                }),
              );
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlementA!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.abilityuid == user?.id)
          ElevatedButton(
            child: const Text(
              '发起方撤回结算方案',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要撤回结算方案吗？'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateSettlementAB(
                    respond!.id,
                    {},
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlementA!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            respond!.uid == user?.id)
          ElevatedButton(
            child: const Text(
              '响应方同意结算方案',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要同意这个结算方案吗？这意味着，再也无法变更合约或提交结算方案。'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                if (value == ConfirmDialogAction.OK) {
                  _updateSettlement(
                    respond!.id,
                    respond!.settlementA!,
                  ).then((value) => setState(() {
                        futureRespond = _getData();
                      }));
                }
                return;
              });
            },
          ),
      ],
    );
  }

  Widget _settlement() {
    DateTime deliver = DateTime.now();
    String deliverDate = respond!.contract!['deliverDate'] ?? '';
    String deliverTime = respond!.contract!['deliverTime'] ?? '';
    if (deliverDate.isNotEmpty && deliverTime.isNotEmpty) {
      deliver =
          DateFormat("yyyy-MM-dd hh:mm").parse(deliverDate + ' ' + deliverTime);
    }
    deliver = deliver.add(const Duration(minutes: 15 * 1440));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (respond!.settlement!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '支付方向(原)：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text:
                      '${payingArr[respond!.settlement!['originalpaying']!]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlement!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '支付方向：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${payingArr[respond!.settlement!['paying']]}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlement!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '结算金额(原)：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.contract!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlement!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '结算金额：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.settlement!['payable']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.settlement!.isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: '关于结算方案的说明：\r\n',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
                TextSpan(
                  text: '${respond!.settlement!['note']}\r\n',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        if (respond!.contract!.isNotEmpty &&
            respond!.settlement!.isEmpty &&
            (respond!.settlementA!.isNotEmpty ||
                respond!.settlementB!.isNotEmpty) &&
            DateTime.now().isAfter(deliver))
          ElevatedButton(
            child: const Text(
              '提交纠纷证据',
            ),
            onPressed: () {
              showDialog<ConfirmDialogAction>(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) =>
                    confirm(context, '确定要提交纠纷证据吗？将向系统管理员发送一份电子邮件(可以有附件)。'),
              ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
                String url =
                    'mailto:support@a2money.com?subject=纠纷证据，响应编号是${respond!.id}';
                await canLaunch(url)
                    ? await launch(url)
                    : showToast('无法启动 $url', context);

                return;
              });
            },
          ),
      ],
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
            panel = _contractB();
            break;

          case 1:
            panel = _contractA();
            break;

          case 2:
            panel = _contract();
            break;

          case 3:
            panel = _tokenB();
            break;

          case 4:
            panel = _tokenA();
            break;

          case 5:
            panel = _settlementB();
            break;

          case 6:
            panel = _settlementA();
            break;

          case 7:
            panel = _settlement();
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

  Future<void> _refresh() async {
    setState(() {
      futureRespond = _getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;
    if (user == null) {
      return anonymous(context, true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('响应详情'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: FutureBuilder<Respond?>(
          future: futureRespond,
          builder: (BuildContext context, AsyncSnapshot<Respond?> snapshot) {
            if (snapshot.hasData) {
              respond = snapshot.data;

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          _detailleading(),
                          const SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: _detailtitle(),
                          ),
                          _detailtrailing(),
                        ],
                      ),
                      const SizedBox(
                        height: 9,
                      ),
                      _expansionPanelList(),
                      const SizedBox(
                        height: 6,
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: snapshot.error.toString().contains('Too Many Requests')
                      ? const Text('你的访问太频繁，已经被暂时限流，请稍后重试。')
                      : Text('${snapshot.error}'),
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
