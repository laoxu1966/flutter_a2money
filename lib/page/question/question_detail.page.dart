import 'dart:core';

import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/question.model.dart';
import '../../model/answer.model.dart';
import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/answer.service.dart';
import '../../service/question.service.dart';

import '../my/other.page.dart';

import '../answer/create_answer.page.dart';
import '../answer/update_answer.page.dart';

import 'questions.page.dart';
import 'update_question.page.dart';

class QuestionDetailPage extends StatefulWidget {
  final int? id;
  @override
  const QuestionDetailPage({Key? key, this.id}) : super(key: key);

  @override
  QuestionDetailPageState createState() => QuestionDetailPageState();
}

class QuestionDetailPageState extends State<QuestionDetailPage> {
  List<Panel> panels = [];

  Future<Question?>? futureQuestion;
  Question? question;

  User? user;

  Future<Question?> _getData() async {
    final response = await context.read<QuestionService>().findOne(widget.id);

    if (response != null && response?.statusCode == 200) {
      return response.question;
    } else if (response?.statusCode == 404) {
      showToast('没有找到数据', context);
      return null;
    } else {
      showToast(response?.statusMessage, context);
      return null;
    }
  }

  Future _deleteQuestion(int? id) async {
    var response = await Provider.of<QuestionService>(context, listen: false)
        .deleteQuestion(id);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Navigator.of(context).pop();

      showToast('提交成功，请稍后刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为没有找到数据。', context);
    } else if (response?.statusCode == 406) {
      showToast('提交失败，因为已经有答案。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _deleteAnswer(int? id) async {
    var response = await Provider.of<AnswerService>(context, listen: false)
        .deleteAnswer(id);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功，请稍后刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为没有找到数据。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  @override
  void initState() {
    super.initState();

    futureQuestion = _getData();

    panels = [
      '关于问题的描述',
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
    return getAvatar(question!.profile!['avatar']);
  }

  Widget _detailtitle() {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          child: Text(
            question!.profile!['displayName'],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtherPage(
                  uid: question!.uid,
                  profile: question!.profile!,
                ),
              ),
            );
          },
        ),
        Text(
          formatter.format(question!.created!),
          style: const TextStyle(color: Colors.grey),
        ),
        Text(
          formatter.format(question!.updated!),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _detailtrailing() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<QuestionAction>>[
          PopupMenuItem(
            enabled: question!.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  Entypo.pencil,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '修改此问题',
                )
              ],
            ),
            value: QuestionAction.UPDATE,
          ),
          PopupMenuItem(
            enabled: question!.answers!.isEmpty && question!.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.delete,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '删除此问题',
                )
              ],
            ),
            value: QuestionAction.DELETE,
          ),
        ];
      },
      onSelected: (QuestionAction selected) async {
        switch (selected) {
          case QuestionAction.UPDATE:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateQuestionPage(
                  id: widget.id,
                  question: question,
                ),
              ),
            ).then(
              (value) => setState(() {
                futureQuestion = _getData();
              }),
            );
            break;

          case QuestionAction.DELETE:
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要删除这个问题吗？'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                _deleteQuestion(question!.id);
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
      question!.title,
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.grey,
      ),
    );
  }

  Widget _classification() {
    Widget classification = GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionsPage(
              title: '分类 > ${classificationArr[question!.classification]}',
              path: '/question/classification',
              params: {'classification': question!.classification},
            ),
          ),
        );
      },
      child: Chip(
        label: Text(
          classificationArr[question!.classification],
        ),
      ),
    );

    Widget tag = Container();
    if (question!.tag!.isNotEmpty) {
      tag = GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionsPage(
                title: '标签 > ${question!.tag}',
                path: '/question/tag',
                params: {
                  'classification': question!.classification,
                  'tag': question!.tag
                },
              ),
            ),
          );
        },
        onLongPress: () {
          Clipboard.setData(
            ClipboardData(
              text: question!.tag,
            ),
          );
          showToast('已将这个标签复制到剪贴板。', context);
        },
        child: Chip(
          label: Text(
            question!.tag!,
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
      question!.des,
      style: const TextStyle(
        fontSize: 15.0,
        color: Colors.grey,
      ),
    );
  }

  Widget _answerLeading(Answer answer) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    Widget _leading = getAvatar(answer.profile!['avatar']);

    Widget _title = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          child: Text(
            answer.profile!['displayName'],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtherPage(
                  uid: answer.uid,
                  profile: answer.profile,
                ),
              ),
            );
          },
        ),
        Text(
          formatter.format(answer.created!),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );

    Widget _trailing = PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<AnswerAction>>[
          PopupMenuItem(
            enabled: answer.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  Entypo.pencil,
                ),
                Container(width: 15),
                const Text(
                  '修改此答案',
                )
              ],
            ),
            value: AnswerAction.UPDATE,
          ),
          PopupMenuItem(
            enabled: answer.uid == user?.id,
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.delete,
                ),
                Container(width: 15),
                const Text(
                  '删除此答案',
                )
              ],
            ),
            value: AnswerAction.DELETE,
          ),
        ];
      },
      onSelected: (AnswerAction selected) async {
        switch (selected) {
          case AnswerAction.UPDATE:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateAnswerPage(
                  id: answer.id,
                  answer: answer,
                ),
              ),
            ).then(
              (value) => setState(() {
                futureQuestion = _getData();
              }),
            );
            break;
          case AnswerAction.DELETE:
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要删除这个答案吗？'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                _deleteAnswer(answer.id).then((value) => setState(() {
                      futureQuestion = _getData();
                    }));
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

    return Row(
      children: <Widget>[
        _leading,
        const SizedBox(
          width: 18,
        ),
        Expanded(
          child: _title,
        ),
        _trailing,
      ],
    );
  }

  Widget _answerDes(Answer answer) {
    List<InlineSpan> desWidget = [
      TextSpan(
        text: answer.des,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    ];

    return ExpandableNotifier(
      child: Column(
        children: [
          Expandable(
            collapsed: ExpandableButton(
              child: Text.rich(
                TextSpan(children: desWidget),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            expanded: ExpandableButton(
              child: Text.rich(
                TextSpan(children: desWidget),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _answers() {
    List<Widget> answers = question!.answers!
        //.where((answer) => answer.uid == user?.id || question!.uid == user?.id)
        .map((answer) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.only(left: 9.0, right: 9.0, bottom: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _answerLeading(answer),
              _answerDes(answer),
            ],
          ),
        ),
      );
    }).toList();

    if (answers.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: answers,
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
      futureQuestion = _getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('问题详情'),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(),
        child: FutureBuilder<Question?>(
          future: futureQuestion,
          builder: (BuildContext context, AsyncSnapshot<Question?> snapshot) {
            if (snapshot.hasData) {
              question = snapshot.data;
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
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
                            '你还没有登录，无法回答或查看答案',
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                '/signin', (router) => true);
                          },
                        ),
                      if (user != null) _answers(),
                      if (user != null)
                        ElevatedButton(
                          child: const Text(
                            '回答此问题',
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateAnswerPage(
                                  question: question,
                                ),
                              ),
                            ).then(
                              (value) => setState(() {
                                futureQuestion = _getData();
                              }),
                            );
                          },
                        ),
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
