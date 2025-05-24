import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.room,
  });

  final types.Room room;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        }
      }
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _handleSendPressed(types.PartialText message) {
    FirebaseChatCore.instance.sendMessage(
      message,
      widget.room.id,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFB4914B)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    AssetImage('assets/profile.jpg'), // Profile image
              ),
              SizedBox(width: 10),
              Text('Username', style: TextStyle(color: Color(0xFFB4914B))),
            ],
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/bg.jpg', // Add your background image here
                fit: BoxFit.cover,
              ),
            ),
            StreamBuilder<types.Room>(
              initialData: widget.room,
              stream: FirebaseChatCore.instance.room(widget.room.id),
              builder: (context, snapshot) =>
                  StreamBuilder<List<types.Message>>(
                initialData: const [],
                stream: FirebaseChatCore.instance.messages(snapshot.data!),
                builder: (context, snapshot) => Chat(
                  messages: snapshot.data ?? [],
                  onMessageTap: _handleMessageTap,
                  onPreviewDataFetched: _handlePreviewDataFetched,
                  onSendPressed: _handleSendPressed,
                  showUserAvatars: true,
                  user: types.User(
                    id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                  ),
                  theme: DefaultChatTheme(
                    backgroundColor: Colors.transparent,
                    primaryColor: Colors.black,
                    secondaryColor: Colors.black,
                    messageInsetsVertical: 10,
                    messageInsetsHorizontal: 16,
                    messageBorderRadius: 10,
                    userAvatarNameColors: const [Colors.blue, Colors.red],
                    userAvatarTextStyle: const TextStyle(color: Colors.white),
                    receivedMessageBodyTextStyle:
                        const TextStyle(color: Color(0xFFB4914B)),
                    sentMessageBodyTextStyle:
                        const TextStyle(color: Color(0xFFB4914B)),
                    // receivedMessageBorderColor: Color(0xFFB4914B),
                    // sentMessageBorderColor: Color(0xFFB4914B),
                    inputTextColor: Colors.white,
                    inputBackgroundColor: Colors.black,
                    inputBorderRadius: BorderRadius.circular(10),
                    inputTextStyle: const TextStyle(color: Colors.white),
                    // inputButtonIcon: Icon(Icons.send, color: Color(0xFFB4914B)),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
