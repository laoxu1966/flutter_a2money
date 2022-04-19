import 'dart:typed_data';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../common/ui.dart';
import '../../common/constant.dart';

import '../../model/user.model.dart';
import '../../model/chat.model.dart';
import '../../model/favorite.model.dart';

import '../../service/chat.service.dart';
import '../../service/user.service.dart';

import '../my/other.page.dart';

class ChatPage extends StatefulWidget {
  final String? room;
  final List<Favorite>? follows;
  const ChatPage({Key? key, this.room, this.follows}) : super(key: key);

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  User? user;

  bool isComposing = false;
  TextEditingController textInputController = TextEditingController();

  late io.Socket socket;

  createSocketConnection() {
    socket = io.io(endPoint, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.on("connect", (_) {
      socket.emit('join', [widget.room]);
    });

    socket.on("disconnect", (_) {
      socket.emit('leave', [widget.room]);
    });

    socket.on("chat", (_) async {
      await Provider.of<ChatService>(context, listen: false).emitChat(_);
    });
  }

  @override
  void initState() {
    super.initState();

    createSocketConnection();
  }

  @override
  void dispose() {
    textInputController.dispose();

    super.dispose();
  }

  Future _submit(String message) async {
    textInputController.clear();

    if (message.startsWith("data:image/png;base64")) {
      showToast('正在发送图片，请稍后。', context);
    }

    if (!socket.connected) socket.connect();

    socket.emit('chat', [
      {
        "room": widget.room,
        "message": message,
        "uid": user!.id,
        "profile": jsonEncode(
          {
            "avatar": user!.profile!['avatar'],
            "displayName": user!.profile!['displayName'],
          },
        ),
        "created": DateTime.now().toString()
      }
    ]);

    isComposing = false;
  }

  _message(Chat chat) {
    DateFormat formatter = DateFormat('HH:mm:ss');
    
    Widget message;
    if (chat.message.startsWith("data:image/png;base64")) {
      message = LimitedBox(
        maxWidth: MediaQuery.of(context).size.width - 60,
        child: getPicture(chat.message),
      );
    } else {
      message = LimitedBox(
        maxWidth: MediaQuery.of(context).size.width - 60,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Text(
              chat.message,
              style: TextStyle(
                color: chat.message.contains('@')
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      );
    }

    return SizeTransition(
      sizeFactor: CurvedAnimation(
          parent: chat.animationController!, curve: Curves.easeInOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 9.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              child: getAvatar(chat.profile!['avatar']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => OtherPage(
                      uid: chat.uid,
                      profile: chat.profile!,
                    ),
                  ),
                );
              },
              onLongPress: () {
                final initStr = textInputController.text +
                    '@' +
                    chat.profile!['displayName'] +
                    ' ';
                textInputController = TextEditingController.fromValue(
                  TextEditingValue(
                    text: initStr,
                    selection: TextSelection.fromPosition(
                      TextPosition(
                        affinity: TextAffinity.downstream,
                        offset: initStr.length,
                      ),
                    ),
                  ),
                );
                setState(() {
                  //
                });
              },
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: chat.profile!['displayName'] + ' ',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        TextSpan(
                          text: formatter.format(chat.created!) + ' ',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  message,
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  _pickButton() {
    return PopupMenuButton(
      icon: const Icon(
        Icons.photo_camera,
        color: Colors.grey,
      ),
      itemBuilder: (BuildContext context) {
        return <PopupMenuItem<ImageAction>>[
          PopupMenuItem(
            enabled: user != null,
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.photo_album,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '从相册选择图片',
                )
              ],
            ),
            value: ImageAction.GALLERY_IMAGE,
          ),
          PopupMenuItem(
            enabled: user != null,
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.photo_camera,
                  size: 21,
                ),
                Container(width: 15),
                const Text(
                  '用相机拍摄照片',
                )
              ],
            ),
            value: ImageAction.CAMERA_IMAGE,
          ),
          
        ];
      },
      onSelected: (ImageAction selected) async {
        switch (selected) {
          case ImageAction.GALLERY_IMAGE:
            final ImagePicker _picker = ImagePicker();
            final XFile? file = await _picker.pickImage(
              source: ImageSource.gallery,
              maxHeight: 1800,
              maxWidth: 600,
            );
            if (file != null) {
              Uint8List imageBytes = await file.readAsBytes();
              _submit('data:image/png;base64,' + base64Encode(imageBytes));
            }

            break;

          case ImageAction.CAMERA_IMAGE:
            final ImagePicker _picker = ImagePicker();
            final XFile? file = await _picker.pickImage(
              source: ImageSource.camera,
              maxHeight: 1800,
              maxWidth: 600,
            );
            if (file != null) {
              Uint8List imageBytes = await file.readAsBytes();
              _submit('data:image/png;base64,' + base64Encode(imageBytes));
            }
            break;

          default:
            showToast(selected.toString(), context);
            break;
        }
      },
    );
  }

  _input() {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 99,
      child: TextField(
        autofocus: true,
        controller: textInputController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: '发言...',
        ),
        onChanged: (String val) {
          isComposing = val.isNotEmpty;
        },
        onSubmitted: (val) {
          if (isComposing) {
            _submit(val);
          }
        },
      ),
    );
  }

  _sendButton() {
    return IconButton(
      icon: const Icon(
        Icons.send,
        color: Colors.grey,
      ),
      onPressed: () {
        if (isComposing) {
          _submit(textInputController.text);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    user = context.watch<UserService>().user;
    if (user == null) {
      return anonymous(context, true);
    } else if (user!.role! == -1) {
      return blocked(context, true);
    } else if ((user!.tel ?? '').isEmpty || (user!.email ?? '').isEmpty) {
      return verificationEmail(context, true);
    }

    List<Chat> chats = context.watch<ChatService>().chats;
    chats = chats.where((element) => element.room == widget.room).toList();
    for (var chat in chats) {
      chat.animationController ??= AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: this,
        );
      chat.animationController!.forward();
    }

    return WillPopScope(
      onWillPop: () {
        socket.disconnect();
        return Future(() => true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('交流 > ${widget.room}'),
        ),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              ListView.builder(
                itemCount: chats.length,
                reverse: true,
                padding: const EdgeInsets.only(right: 9, bottom: 60, left: 9),
                itemBuilder: (context, index) {
                  return _message(chats[index]);
                },
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: Row(
                  children: <Widget>[
                    _pickButton(),
                    _input(),
                    _sendButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
