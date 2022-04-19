import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';

import '../../service/user.service.dart';

import '../user/update_username.page.dart';
import '../user/update_email.page.dart';
import '../user/update_tel.page.dart';
import '../user/update_password.page.dart';
import '../user/update_profile.page.dart';

import '../ability/abilities.page.dart';
import '../question/questions.page.dart';

import 'follow.page.dart';
import 'token.page.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);
  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> with AutomaticKeepAliveClientMixin {
  User? user;

  Future _signout(int? id) async {
    var response =
        await Provider.of<UserService>(context, listen: false).signout(id);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      Provider.of<UserService>(context, listen: false).logout();
      showToast('提交成功，请稍后刷新。', context);
    } else if (response?.statusCode == 404) {
      showToast('没有找到数据。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _header() {
    Widget _leading = getAvatar(user!.profile!['avatar']);

    Widget _title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user!.profile!['displayName'],
        ),
        if ((user!.profile!['description'] ?? '').isNotEmpty)
          Text(
            user!.profile!['description'],
            style: const TextStyle(color: Colors.grey),
          ),
      ],
    );

    Widget _trailing = PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<AuthAction>>[
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.user,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '修改用户名',
                )
              ],
            ),
            value: AuthAction.USERNAME,
          ),
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                const Icon(
                  MaterialIcons.enhanced_encryption,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '修改密码',
                )
              ],
            ),
            value: AuthAction.PASSWORD,
          ),
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.profile,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '修改用户资料',
                )
              ],
            ),
            value: AuthAction.PROFILE,
          ),
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.email,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '验证电子邮件账号',
                )
              ],
            ),
            value: AuthAction.EMAIL,
          ),
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.phone,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '验证手机号码',
                )
              ],
            ),
            value: AuthAction.TEL,
          ),
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                const Icon(
                  Octicons.sign_out,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '注销账号',
                )
              ],
            ),
            value: AuthAction.SIGNOUT,
          ),
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.logout,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '登出',
                )
              ],
            ),
            value: AuthAction.LOGOUT,
          ),
        ];
      },
      onSelected: (AuthAction selected) {
        switch (selected) {
          case AuthAction.USERNAME:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateUsernamePage(
                  username: user!.username,
                ),
              ),
            );
            break;
          case AuthAction.PASSWORD:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UpdatePasswordPage(),
              ),
            );
            break;
          case AuthAction.PROFILE:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateProfilePage(
                  profile: user!.profile!,
                ),
              ),
            );
            break;
          case AuthAction.EMAIL:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateEmailPage(
                  email: user!.email,
                ),
              ),
            );
            break;
          case AuthAction.TEL:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UpdateTelPage(
                  tel: user!.tel,
                ),
              ),
            );
            break;
          case AuthAction.SIGNOUT:
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) => confirm(context,
                  '确定要注销这个账号吗？在注销之前，请自行删除该账号所关联的发起或响应(详见本平台的隐私政策和帮助)，否则，这些信息将一直保留。'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                _signout(user!.id);
              }

              return;
            });
            break;
          case AuthAction.LOGOUT:
            Provider.of<UserService>(context, listen: false).logout();
            break;
          default:
            showToast('$selected', context);
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

  Widget _myAbility() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('我发起的能力变现交易'),
        leading: const Icon(
          Octicons.file,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '我发起的能力变现交易',
                path: '/ability/myAbility',
                params: {'uid': user!.id},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _myRespond() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('我响应的能力变现交易'),
        leading: const Icon(
          Octicons.file_symlink_file,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '我响应的能力变现交易',
                path: '/ability/myRespond',
                params: {'uid': user!.id},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _myFavorite() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('我收藏的能力变现交易'),
        leading: const Icon(
          Icons.favorite_border,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbilitysPage(
                title: '我收藏的能力变现交易',
                path: '/ability/myFavorite',
                params: {'uid': user!.id},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _myQuestion() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('我发起的能力知乎问题'),
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
                title: '我发起的能力知乎问题',
                path: '/question/myQuestion',
                params: {'uid': user!.id},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _myAnswer() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('我回答的能力知乎问题'),
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
                title: '我回答的能力知乎问题',
                path: '/question/myAnswer',
                params: {'uid': user!.id},
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _myFollow() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('我关注的用户'),
        leading: const Icon(
          SimpleLineIcons.user_follow,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FollowPage(uid: user!.id),
            ),
          );
        },
      ),
    );
  }

  Widget _myToken() {
    return Card(
      margin: const EdgeInsets.all(0),
      elevation: 0.0,
      child: ListTile(
        title: const Text('我的交易资金'),
        leading: const Icon(
          AntDesign.wallet,
          size: 21.0,
        ),
        trailing: const Icon(Icons.keyboard_arrow_right),
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TokenPage(uid: user!.id),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    user = context.watch<UserService>().user;
    if (user == null) {
      return anonymous(context, false);
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ListView(
          children: <Widget>[
            _header(),
            const SizedBox(
              height: 6.0,
            ),
            _myAbility(),
            const SizedBox(
              height: 6.0,
            ),
            _myRespond(),
            const SizedBox(
              height: 6.0,
            ),
            _myFavorite(),
            const SizedBox(
              height: 6.0,
            ),
            _myQuestion(),
            const SizedBox(
              height: 6.0,
            ),
            _myAnswer(),
            const SizedBox(
              height: 6.0,
            ),
            _myFollow(),
            const SizedBox(
              height: 6.0,
            ),
            _myToken(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
