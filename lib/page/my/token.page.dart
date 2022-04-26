import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';
import '../../model/token.model.dart';

import '../../service/user.service.dart';
import '../../service/token.service.dart';

import '../ability/ability_detail.page.dart';
import '../respond/respond_detail.page.dart';

class TokenPage extends StatefulWidget {
  final int? uid;
  const TokenPage({Key? key, this.uid}) : super(key: key);

  @override
  TokenPageState createState() => TokenPageState();
}

class TokenPageState extends State<TokenPage> {
  List<Panel> panels = [];

  Future<List<Token>?>? futureTokens;
  List<Token>? tokens = [];

  num totalIncome = 0;
  num totalPay = 0;

  int totalOut = 0;
  int totalCredit = 0;

  User? user;

  Future<List<Token>?> _getData() async {
    final response = await context.read<TokenService>().findAll(widget.uid);

    if (response != null && response?.statusCode == 200) {
      return response.tokens;
    } else {
      throw Exception(response?.statusMessage);
    }
  }

  @override
  void initState() {
    super.initState();

    panels = tokenArr
        .map(
          (s) => Panel(header: s, isExpanded: false),
        )
        .toList();
  }

  Widget _header() {
    Widget _leading = getAvatar(user!.profile!['avatar']);

    Widget _title = Text(
      user!.profile!['displayName'],
    );

    Widget _subtitle = Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: '总收入：',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: totalIncome.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const TextSpan(
            text: '\r\n总支出：',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: totalPay.toString(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const TextSpan(
            text: '\r\n失信比：',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: '$totalOut / $totalCredit',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );

    return ListTile(
      leading: _leading,
      title: _title,
      subtitle: _subtitle,
    );
  }

  Widget _freeze() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<TableRow> rows =
        tokens!.where((element) => element.freeze! > 0).map((element) {
      return TableRow(
        children: [
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AbilityDetailPage(id: element.abilityid),
                  ),
                );
              },
              child: Text(
                '${element.abilityid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RespondDetailPage(id: element.respondid),
                  ),
                );
              },
              child: Text(
                '${element.respondid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: Text(
              '${element.id}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.freeze!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.updated!)}\r\n',
              style: const TextStyle(color: Colors.grey, height: 1),
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
                '交易   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '响应   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '凭证   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '金额   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '日期时间\r\n',
                style: TextStyle(height: 1),
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

  Widget _unfreeze() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<TableRow> rows =
        tokens!.where((element) => element.unfreeze! > 0).map((element) {
      return TableRow(
        children: [
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AbilityDetailPage(id: element.abilityid),
                  ),
                );
              },
              child: Text(
                '${element.abilityid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RespondDetailPage(id: element.respondid),
                  ),
                );
              },
              child: Text(
                '${element.respondid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: Text(
              '${element.id}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.unfreeze!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.updated!)}\r\n',
              style: const TextStyle(color: Colors.grey, height: 1),
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
                '交易   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '响应   ',
                style: TextStyle(height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '凭证   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '金额   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '日期时间\r\n',
                style: TextStyle(height: 1),
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

  Widget _pay() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<TableRow> rows =
        tokens!.where((element) => element.pay! > 0).map((element) {
      return TableRow(
        children: [
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AbilityDetailPage(id: element.abilityid),
                  ),
                );
              },
              child: Text(
                '${element.abilityid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RespondDetailPage(id: element.respondid),
                  ),
                );
              },
              child: Text(
                '${element.respondid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: Text(
              '${element.id}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.pay!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.updated!)}\r\n',
              style: const TextStyle(color: Colors.grey, height: 1),
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
                '交易   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '响应   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '凭证   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '金额   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '日期时间\r\n',
                style: TextStyle(height: 1),
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

  Widget _income() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<TableRow> rows =
        tokens!.where((element) => element.income! > 0).map((element) {
      return TableRow(
        children: [
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AbilityDetailPage(id: element.abilityid),
                  ),
                );
              },
              child: Text(
                '${element.abilityid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RespondDetailPage(id: element.respondid),
                  ),
                );
              },
              child: Text(
                '${element.respondid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: Text(
              '${element.id}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.income!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.updated!)}\r\n',
              style: const TextStyle(color: Colors.grey, height: 1),
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
                '交易   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '响应   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '凭证   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '金额   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '日期时间\r\n',
                style: TextStyle(height: 1),
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

  Widget _fee() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<TableRow> rows =
        tokens!.where((element) => element.fee! > 0).map((element) {
      return TableRow(
        children: [
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AbilityDetailPage(id: element.abilityid),
                  ),
                );
              },
              child: Text(
                '${element.abilityid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RespondDetailPage(id: element.respondid),
                  ),
                );
              },
              child: Text(
                '${element.respondid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: Text(
              '${element.id}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.fee!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.updated!)}\r\n',
              style: const TextStyle(color: Colors.grey, height: 1),
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
                '交易   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '响应   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '凭证   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '金额   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '日期时间\r\n',
                style: TextStyle(height: 1),
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

  Widget _cash() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    List<TableRow> rows =
        tokens!.where((element) => element.cash! > 0).map((element) {
      return TableRow(
        children: [
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AbilityDetailPage(id: element.abilityid),
                  ),
                );
              },
              child: Text(
                '${element.abilityid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RespondDetailPage(id: element.respondid),
                  ),
                );
              },
              child: Text(
                '${element.respondid}',
                style: const TextStyle(height: 1),
              ),
            ),
          ),
          TableCell(
            child: Text(
              '${element.id}',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${double.tryParse(element.cash!.toStringAsFixed(3)) ?? 0.01}   ',
              style: const TextStyle(color: Colors.grey, height: 1),
            ),
          ),
          TableCell(
            child: Text(
              '${formatter.format(element.updated!)}\r\n',
              style: const TextStyle(color: Colors.grey, height: 1),
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
                '交易   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '响应   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '凭证   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '金额   ',
                style: TextStyle(color: Colors.grey, height: 1),
              ),
            ),
            TableCell(
              child: Text(
                '日期时间\r\n',
                style: TextStyle(height: 1),
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
            panel = _freeze();
            break;

          case 1:
            panel = _unfreeze();
            break;

          case 2:
            panel = _pay();
            break;

          case 3:
            panel = _income();
            break;

          case 4:
            panel = _fee();
            break;

          case 5:
            panel = _cash();
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
      futureTokens = _getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    var thisuser = context.watch<UserService>().user;
    if (thisuser == null) {
      return anonymous(context, true);
    }

    if (user != thisuser) {
      user = thisuser;

      futureTokens = _getData();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("我的交易资金"),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: FutureBuilder<List<Token>?>(
          future: futureTokens,
          builder:
              (BuildContext context, AsyncSnapshot<List<Token>?> snapshot) {
            if (snapshot.hasData) {
              tokens = snapshot.data;

              totalIncome = 0.0;
              totalPay = 0.0;
              totalOut = 0;
              totalCredit = 0;

              for (var pay in tokens!) {
                if (pay.income! > 0) {
                  totalIncome += pay.income!;
                }
                if (pay.pay! > 0) {
                  totalPay += pay.pay!;
                }

                totalCredit += 1;
                if (pay.freeze == 0 &&
                    DateTime.now().isAfter(pay.created!
                        .add(const Duration(minutes: 15 * 1440)))) {
                  totalOut += 1;
                }
              }

              if (user!.profile!['credit'] != '$totalOut / $totalCredit') {
                user!.profile!['credit'] = '$totalOut / $totalCredit';
                context.read<UserService>().updateProfile(user!.profile!);
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Column(
                    children: <Widget>[
                      _header(),
                      const SizedBox(height: 6.0),
                      _expansionPanelList(),
                    ],
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
      ),
    );
  }
}
