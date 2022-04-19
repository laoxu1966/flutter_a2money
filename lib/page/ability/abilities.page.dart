import 'dart:core';

import 'package:intl/intl.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:expandable/expandable.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../common/ui.dart';
import '../../common/constant.dart';
import '../../common/carousel.dart';

import '../../model/ability.model.dart';
import '../../model/user.model.dart';

import '../../service/ability.service.dart';
import '../../service/user.service.dart';
import '../../service/favorite.service.dart';

import '../my/other.page.dart';

import 'create_ability.page.dart';
import 'ability_detail.page.dart';

class AbilitysPage extends StatefulWidget {
  final String? title;
  final String? path;
  final Map<String, dynamic>? params;
  @override
  const AbilitysPage({Key? key, this.title, this.path, this.params})
      : super(key: key);

  @override
  AbilitysPageState createState() => AbilitysPageState();
}

class AbilitysPageState extends State<AbilitysPage>
    with AutomaticKeepAliveClientMixin {
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
      showToast('提交失败，因为之前已收藏此交易。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  Future _deleteFavorite(int code, int peer) async {
    var response = await Provider.of<FavoriteService>(context, listen: false)
        .deleteFavorite(code, peer);

    if (response?.statusCode == 200 || response?.statusCode == 201) {
      _pagingController.refresh();
      showToast('提交成功。', context);
    } else if (response?.statusCode == 404) {
      showToast('提交失败，之前没有收藏此交易。', context);
    } else {
      showToast(response?.statusMessage, context);
    }
  }

  final PagingController<int, Ability> _pagingController =
      PagingController(firstPageKey: 0);

  Future<void> _fetchPage(int pageKey) async {
    try {
      final response =
          await Provider.of<AbilityService>(context, listen: false).findAll(
        widget.path!,
        widget.params!,
        pageKey,
      );
      if (response != null && response?.statusCode == 200) {
        final List<Ability> newItems = response.abilities;

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

  Future qr2Image() async {
    try {
      final byteData = await QrPainter(
        data: 'https://www.a2money.com:3000/download',
        version: QrVersions.auto,
        color: Colors.white,
      ).toImageData(210);

      final imageBytes = byteData?.buffer.asUint8List();
      final result =
          await ImageGallerySaver.saveImage(imageBytes!, name: "ability");

      if (result['isSuccess']) {
        showToast('二维码已经保存到相册。', context);
      }
    } catch (e) {
      rethrow;
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

  Widget _leading(Ability ability) {
    DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    Widget _leading = Badge(
      showBadge: ability.status == 0 ? true : false,
      badgeContent: const Text(""),
      child: getAvatar(ability.profile!['avatar']),
    );

    Widget _title = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        GestureDetector(
          child: Text(
            ability.profile!['displayName'],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => OtherPage(
                  uid: ability.uid,
                  profile: ability.profile,
                ),
              ),
            );
          },
        ),
        Text(
          formatter.format(ability.created!),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );

    Widget _trailing = PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 21),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<AbilityAction>>[
          if (widget.path!.contains('myFavorite') == false)
            PopupMenuItem(
              enabled: user != null,
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.favorite_border,
                    size: 21,
                  ),
                  Container(width: 15),
                  const Text(
                    '收藏此交易',
                  )
                ],
              ),
              value: AbilityAction.FAVORITE,
            ),
          if (widget.path!.contains('myFavorite') == true)
            PopupMenuItem(
              enabled: user != null,
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.favorite_border,
                    size: 21,
                  ),
                  Container(width: 15),
                  const Text(
                    '取消收藏此交易',
                  )
                ],
              ),
              value: AbilityAction.CANCEL_FAVORITE,
            ),
          PopupMenuItem(
            enabled: user != null,
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.sharealt,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '分享此交易(文字)',
                )
              ],
            ),
            value: AbilityAction.SHARE,
          ),
          PopupMenuItem(
            enabled: user != null,
            child: Row(
              children: <Widget>[
                const Icon(
                  AntDesign.qrcode,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '分享此交易(二维码)',
                )
              ],
            ),
            value: AbilityAction.SHARE_QR,
          ),
        ];
      },
      onSelected: (AbilityAction selected) {
        switch (selected) {
          case AbilityAction.FAVORITE:
            _createFavorite(0, ability.id!, {});

            break;
          case AbilityAction.CANCEL_FAVORITE:
            showDialog<ConfirmDialogAction>(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) =>
                  confirm(context, '确定要删除这个收藏吗？'),
            ).then<ConfirmDialogAction?>((ConfirmDialogAction? value) async {
              if (value == ConfirmDialogAction.OK) {
                _deleteFavorite(0, ability.id!);
              }
              return;
            });

            break;
          case AbilityAction.SHARE:
            Share.share(
              '来自“能力变现平台”的交易，欢迎你来参与。\r\n主题：${ability.title}\r\n正文：${ability.des}\r\n如果想要安装“能力变现平台”，你可以到阿里（PP助手、豌豆荚）、360、百度、华为、小米、OPPO、Google Play、APKPure等应用商店(市场)搜索“能力变现平台”。\r\n也可以点击(或复制)以下链接：\r\nhttps://www.a2money.com:3000/download',
              subject: ability.title,
            );
            break;

          case AbilityAction.SHARE_QR:
            qr2Image();
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

  Widget _title(Ability ability) {
    Widget titleWidget = Text(
      ability.title,
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
        ability.title,
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
            builder: (context) => AbilityDetailPage(
              id: ability.id,
            ),
          ),
        );
      },
      child: Container(
        child: titleWidget,
      ),
    );
  }

  Widget _des(Ability ability) {
    List<InlineSpan> desWidget = [
      TextSpan(
        text: ability.des,
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
        ability.des,
        terms,
        const TextStyle(
          color: Colors.grey,
        ),
        const TextStyle(
          color: Colors.red,
        ),
      );
    }

    if (ability.files == null ||
        ability.files!.isEmpty ||
        ability.files![0] == '') {
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
                ability.files![0],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarouselPage(ability.files!, 0),
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
                ability.files![0],
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CarouselPage(ability.files!, 0),
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

  Widget _respond(Ability ability) {
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(
            text: '响应截止: ',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: '${ability.respondDate}  ${ability.respondTime}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
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
                    builder: (context) =>
                        CreateAbilityPage(paying: widget.params!['paying']),
                  ),
                );
              },
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => Future.sync(
          () => _pagingController.refresh(),
        ),
        child: PagedListView<int, Ability>.separated(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<Ability>(
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
                  widget.path!.contains('myAbility') == false &&
                  widget.path!.contains('myRespond') == false) {
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
                      _respond(item),
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
