import 'package:flutter/foundation.dart';

import '../model/chat.model.dart';

class ChatService with ChangeNotifier {
  final List<Chat> _chats = [];
  List<Chat> get chats => _chats;

  ChatService() {
    //
  }

  Future emitChat(Map<String, dynamic> chat) async {
    _chats.insert(
      0,
      Chat.fromJson(chat),
    );

    notifyListeners();
  }
}
