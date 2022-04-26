import 'package:flutter/material.dart';
import 'package:azlistview/azlistview.dart';
import 'package:provider/provider.dart';
import 'package:lpinyin/lpinyin.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';
import '../../model/favorite.model.dart';

import '../../service/user.service.dart';
import '../../service/favorite.service.dart';

import 'other.page.dart';

class FollowPage extends StatefulWidget {
  final int? uid;
  const FollowPage({Key? key, this.uid}) : super(key: key);

  @override
  FollowPageState createState() => FollowPageState();
}

class FollowPageState extends State<FollowPage> {
  User? user;
  late Offset tapPos;

  List<Favorite>? follows = [];
  Future<List<Favorite>?>? futureFollows;

  Future<List<Favorite>?> _getData() async {
    final response =
        await context.read<FavoriteService>().findAll(1, widget.uid!);

    if (response != null && response?.statusCode == 200) {
      return response.favorites;
    } else {
      throw Exception(response?.statusMessage);
    }
  }

  @override
  void initState() {
    super.initState();

    futureFollows = _getData();
  }

  Future _deleteFavorite(int code, int peer) async {
    var response = await Provider.of<FavoriteService>(context, listen: false)
        .deleteFavorite(code, peer);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，因为之前没有关注此用户。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _updateMemo(int favoriteid, String? memo) async {
    var response = await Provider.of<FavoriteService>(context, listen: false)
        .updateMemo(favoriteid, memo);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      showToast('提交成功。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  _showMenu(BuildContext context, Offset tapPos, Favorite favorite) {
    final RenderBox overlay = context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromLTRB(tapPos.dx, tapPos.dy,
        overlay.size.width - tapPos.dx, overlay.size.height - tapPos.dy);
    showMenu<UserAction>(
        context: context,
        position: position,
        items: <PopupMenuItem<UserAction>>[
          const PopupMenuItem(
            child: Text('取消关注'),
            value: UserAction.FOLLOW,
          ),
          const PopupMenuItem(
            child: Text('设置备注'),
            value: UserAction.MEMO,
          ),
        ]).then((UserAction? selected) async {
      switch (selected) {
        case UserAction.FOLLOW:
          showDialog<ConfirmDialogAction>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                confirm(context, '确定要取消关注这个用户吗？'),
          ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
            if (value == ConfirmDialogAction.OK) {
              _deleteFavorite(1, favorite.peer).then((value) => setState(() {
                    futureFollows = _getData();
                  }));
            }
            return;
          });

          break;
        case UserAction.MEMO:
          showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                memo(context, favorite.memo ?? ''),
          ).then((value) async {
            if (value != null) {
              favorite.memo = value;
              _updateMemo(favorite.id!, favorite.memo);
            }

            return;
          });

          break;

        default:
          break;
      }
    });
  }

  Widget _follows() {
    return AzListView(
      data: follows!,
      itemCount: follows!.length,
      indexBarOptions: const IndexBarOptions(
        textStyle: TextStyle(
          color: Colors.grey,
        ),
      ),
      itemBuilder: (BuildContext context, int index) {
        Favorite follow = follows![index];
        Widget other = ListTile(
          leading: getAvatar(follow.profile['avatar']),
          title: GestureDetector(
            onTapDown: (TapDownDetails details) {
              tapPos = details.globalPosition;
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => OtherPage(
                    uid: follow.peer,
                    profile: follow.profile,
                  ),
                ),
              );
            },
            onLongPress: () {
              _showMenu(context, tapPos, follow);
            },
            child: Text(follow.profile['displayName']),
          ),
          subtitle: Text(follow.memo ?? ''),
        );

        if (index < follows!.length - 1) {
          return Column(children: <Widget>[other]);
        }

        Widget total = Container(
          height: 36.0,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            border: Border(
              top: BorderSide(
                color: Colors.grey.withOpacity(0.3),
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: Center(
            child: Text("共 " + follows!.length.toString() + " 位联系人"),
          ),
        );
        return Column(children: <Widget>[other, total]);
      },
      physics: const BouncingScrollPhysics(),
      susItemBuilder: (BuildContext context, int index) {
        Favorite follow = follows![index];
        if ('↑' == follow.getSuspensionTag()) {
          return Container();
        }
        return Container(
          height: 30,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 15.0),
          alignment: Alignment.centerLeft,
          color: Colors.grey.withOpacity(0.3),
          child: Text(
            follow.getSuspensionTag(),
          ),
        );
      },
      indexBarData: const ['↑', ...kIndexBarData],
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;
    if (user == null) {
      return anonymous(context, true);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("我关注的用户"),
      ),
      resizeToAvoidBottomInset: false,
      body: FutureBuilder<List<Favorite>?>(
        future: futureFollows,
        builder:
            (BuildContext context, AsyncSnapshot<List<Favorite>?> snapshot) {
          if (snapshot.hasData) {
            follows = snapshot.data!.map((item) {
              item.namePinyin =
                  PinyinHelper.getPinyinE(item.profile['displayName']);
              String tag = item.namePinyin!.substring(0, 1).toUpperCase();
              if (RegExp("[A-Z]").hasMatch(tag)) {
                item.nameIndex = tag;
              } else {
                item.nameIndex = "#";
              }

              return item;
            }).toList();

            SuspensionUtil.sortListBySuspensionTag(follows);
            SuspensionUtil.setShowSuspensionStatus(follows);

            return _follows();
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
