import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';

import '../../service/user.service.dart';
import '../../service/favorite.service.dart';

import '../ability/abilities.page.dart';
import '../question/questions.page.dart';

class OtherPage extends StatefulWidget {
  final int? uid;
  final Map<String, dynamic>? profile;
  const OtherPage({Key? key, this.uid, this.profile}) : super(key: key);

  @override
  OtherPageState createState() => OtherPageState();
}

class OtherPageState extends State<OtherPage> {
  User? user;

  Future _createFavorite(
    int code,
    int peer,
    Map<String, dynamic> profile,
  ) async {
    var response = await Provider.of<FavoriteService>(context, listen: false)
        .createFavorite(code, peer, profile);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功。', context);
    } else if (response?.statusCode == 409) {
      showToast('提交失败，因为之前已经关注了此人。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _header() {
    Widget _leading = getAvatar(widget.profile!['avatar']);

    Widget _title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.profile!['displayName'],
        ),
        if ((widget.profile!['description'] ?? '').isNotEmpty)
          Text(
            widget.profile!['description'],
            style: const TextStyle(color: Colors.grey),
          ),
        if ((widget.profile!['credit'] ?? '').isNotEmpty)
          Text(
            widget.profile!['credit'],
            style: const TextStyle(color: Colors.grey),
          ),
      ],
    );

    Widget _trailing = PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21, color: Colors.grey),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<UserAction>>[
          PopupMenuItem(
            enabled: user != null && user!.id != widget.uid,
            child: Row(
              children: <Widget>[
                const Icon(
                  SimpleLineIcons.user_follow,
                ),
                Container(width: 15),
                const Text(
                  '关注此用户',
                )
              ],
            ),
            value: UserAction.FOLLOW,
          ),
        ];
      },
      onSelected: (UserAction selected) async {
        switch (selected) {
          case UserAction.FOLLOW:
            _createFavorite(1, widget.uid!, widget.profile!);
            break;
          default:
            showToast(selected.toString(), context);
            break;
        }
      },
    );

    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        leading: _leading,
        title: _title,
        trailing: _trailing,
      ),
    );
  }

  Widget _otherAbility() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('此人发起的能力变现交易'),
        leading: const Icon(
          MaterialCommunityIcons.file_document,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '此人发起的能力变现交易',
                path: '/ability/otherAbility',
                params: {'uid': widget.uid},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _otherRespond() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('此人响应的能力变现交易'),
        leading: const Icon(
          MaterialCommunityIcons.file_document_edit,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '此人响应的能力变现交易',
                path: '/ability/otherRespond',
                params: {'uid': widget.uid},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _otherMy() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        enabled: user != null,
        title: const Text('此人发起我响应的能力变现交易'),
        leading: const Icon(
          Feather.copy,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '此人发起我响应的能力变现交易',
                path: '/ability/otherMy',
                params: {'uid': widget.uid},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _myOther() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
          enabled: user != null,
          title: const Text('我发起此人响应的能力变现交易'),
          leading: const Icon(
            FontAwesome.copy,
            size: 21.0,
          ),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AbilitysPage(
                  title: '我发起此人响应的能力变现交易',
                  path: '/ability/myOther',
                  params: {'uid': widget.uid},
                ),
              ),
            );
          }),
    );
  }

  Widget _otherQuestion() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('此人发起的能力知乎问题'),
        leading: const Icon(
          MaterialCommunityIcons.comment_question_outline,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionsPage(
                title: '此人发起的能力知乎问题',
                path: '/question/otherQuestion',
                params: {'uid': user!.id},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _otherAnswer() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('此人回答的能力知乎问题'),
        leading: const Icon(
          MaterialCommunityIcons.reply_outline,
          size: 27.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuestionsPage(
                title: '此人回答的能力知乎问题',
                path: '/question/otherAnswer',
                params: {'uid': user!.id},
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('此人的'),
      ),
      body: ListView(
        children: <Widget>[
          _header(),
          const SizedBox(
            height: 6.0,
          ),
          _otherAbility(),
          const SizedBox(
            height: 6.0,
          ),
          _otherRespond(),
          const SizedBox(
            height: 6.0,
          ),
          _otherMy(),
          const SizedBox(
            height: 6.0,
          ),
          _myOther(),
          const SizedBox(
            height: 6.0,
          ),
          _otherQuestion(),
          const SizedBox(
            height: 6.0,
          ),
          _otherAnswer(),
          const SizedBox(
            height: 6.0,
          ),
        ],
      ),
    );
  }
}
