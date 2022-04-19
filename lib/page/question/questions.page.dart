import 'dart:core';

import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:expandable/expandable.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../common/ui.dart';
import '../../common/carousel.dart';

import '../../model/question.model.dart';
import '../../model/user.model.dart';

import '../../service/question.service.dart';
import '../../service/user.service.dart';

import '../my/other.page.dart';

import 'create_question.page.dart';
import 'question_detail.page.dart';

class QuestionsPage extends StatefulWidget {
  final String? title;
  final String? path;
  final Map<String, dynamic>? params;
  @override
  const QuestionsPage({Key? key, this.title, this.path, this.params})
      : super(key: key);

  @override
  QuestionsPageState createState() => QuestionsPageState();
}

class QuestionsPageState extends State<QuestionsPage>
    with AutomaticKeepAliveClientMixin {
  User? user;

  final PagingController<int, Question> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final response =
          await Provider.of<QuestionService>(context, listen: false).findAll(
        widget.path!,
        widget.params!,
        pageKey,
      );
      if (response != null && response?.statusCode == 200) {
        final List<Question> newItems = response.questions;

        if (newItems.length < 10) {
          _pagingController.appendLastPage(newItems);
        } else {
          final int nextPageKey = pageKey + newItems.length;

          _pagingController.appendPage(newItems, nextPageKey);
        }
      } else {
        if (response?.statusMessage.contains('Too Many Requests')) {
          showToast('你的访问太频繁，已经被暂时限流，请稍后重试。', context);
        } else {
          showToast(response?.statusMessage, context);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();

    super.dispose();
  }

  Widget _leading(Question question) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    Widget _leading = Badge(
      showBadge: question.status == 0 ? true : false,
      badgeContent: const Text(""),
      child: getAvatar(question.profile!['avatar']),
    );

    Widget _title = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          child: Text(
            question.profile!['displayName'],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtherPage(
                  uid: question.uid,
                  profile: question.profile,
                ),
              ),
            );
          },
        ),
        Text(
          formatter.format(question.created!),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
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
      ],
    );
  }

  Widget _title(Question question) {
    Widget titleWidget = Text(
      question.title,
      style: TextStyle(
        fontSize: 18.0,
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
    );

    if (widget.params!['match'] == 0 || widget.params!['match'] == 1) {
      final List<String> terms = widget.params!['sk']
          .toString()
          .replaceAll(RegExp(r"\+|\-|\~|\>|\<"), "")
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => s.toLowerCase())
          .toList();

      List<InlineSpan> highlights = highlight(
        question.title,
        terms,
        TextStyle(
          fontSize: 18.0,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ),
        const TextStyle(
          fontSize: 18.0,
          color: Colors.red,
        ),
      );

      titleWidget = Text.rich(
        TextSpan(children: highlights),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionDetailPage(
              id: question.id,
            ),
          ),
        );
      },
      child: Container(
        child: titleWidget,
      ),
    );
  }

  Widget _des(Question question) {
    List<InlineSpan> desWidget = [
      TextSpan(
        text: question.des,
        style: const TextStyle(
          color: Colors.grey,
        ),
      ),
    ];

    if (widget.params!['match'] == 0 || widget.params!['match'] == 2) {
      final List<String> terms = widget.params!['sk']
          .toString()
          .replaceAll(RegExp(r"\+|\-|\~|\>|\<"), "")
          .split(' ')
          .where((s) => s.isNotEmpty)
          .map((s) => s.toLowerCase())
          .toList();

      desWidget = highlight(
        question.des,
        terms,
        const TextStyle(
          color: Colors.grey,
        ),
        const TextStyle(
          color: Colors.red,
        ),
      );
    }

    if (question.files == null ||
        question.files!.isEmpty ||
        question.files![0] == '') {
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

    Widget collapsed = Row(
      children: <Widget>[
        Expanded(
          child: ExpandableButton(
            child: Text.rich(
              TextSpan(children: desWidget),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          flex: 2,
        ),
        const SizedBox(
          width: 3,
        ),
        Expanded(
          child: GestureDetector(
            child: AspectRatio(
              aspectRatio: 3.0 / 2.0,
              child: getPicture(
                question.files![0],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarouselPage(question.files!, 0),
                ),
              );
            },
          ),
          flex: 1,
        ),
      ],
    );

    Widget expanded = Row(
      children: <Widget>[
        Expanded(
          child: ExpandableButton(
            child: Text.rich(
              TextSpan(children: desWidget),
            ),
          ),
          flex: 2,
        ),
        const SizedBox(
          width: 3,
        ),
        Expanded(
          child: GestureDetector(
            child: AspectRatio(
              aspectRatio: 3.0 / 2.0,
              child: getPicture(
                question.files![0],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarouselPage(question.files!, 0),
                ),
              );
            },
          ),
          flex: 1,
        ),
      ],
    );

    return ExpandableNotifier(
      child: Column(
        children: [
          Expandable(
            collapsed: collapsed,
            expanded: expanded,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    user = context.watch<UserService>().user;

    return Scaffold(
      appBar: widget.title == null
          ? null
          : AppBar(
              title: Text(widget.title!),
            ),
      floatingActionButton: widget.title == null
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: widget.title == null
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey,
              child: const Icon(Icons.create),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateQuestionPage(),
                  ),
                );
              },
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedListView<int, Question>.separated(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Question>(
            animateTransitions: true,
            firstPageErrorIndicatorBuilder: (_) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '出现异常',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6.0),
                  ElevatedButton(
                    child: const Text(
                      '重试',
                    ),
                    onPressed: () {
                      _pagingController.refresh();
                    },
                  ),
                ],
              ),
            ),
            newPageErrorIndicatorBuilder: (_) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    '出现异常',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6.0),
                  ElevatedButton(
                    child: const Text(
                      '重试',
                    ),
                    onPressed: () {
                      _pagingController.refresh();
                    },
                  ),
                ],
              ),
            ),
            noItemsFoundIndicatorBuilder: (_) => const Center(
              child: Text(
                '没有找到数据',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            noMoreItemsIndicatorBuilder: (_) => const Center(
              child: Text(
                '没有更多数据',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            itemBuilder: (context, item, index) {
              if (item.status! == -1 &&
                  widget.path!.contains('myQuestion') == false &&
                  widget.path!.contains('myAnswer') == false) {
                return Container();
              }

              return Card(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 9.0, right: 9.0, bottom: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _leading(item),
                      _title(item),
                      const SizedBox(
                        height: 3,
                      ),
                      _des(item),
                    ],
                  ),
                ),
              );
            },
          ),
          separatorBuilder: (context, index) => Container(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
