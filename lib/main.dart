import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const String appName = "FriendlyChat";

void main() => runApp(const FriendlyChatApp());

final ThemeData kIOSTheme = ThemeData(
  primarySwatch: Colors.green,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);

final ThemeData kDefaultTheme = ThemeData(
  primarySwatch: Colors.purple,
  // accentColor: Colors.orangeAccent[400],
);

//一番外側のwidget
class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appName,
        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? kIOSTheme
            : kDefaultTheme,
        home: const ChatScreen());
  }
}

// チャットの一つ一つのコメントのwidget
class ChatMessage extends StatelessWidget {
  const ChatMessage(
      {Key? key, required this.text, required this.animationController})
      : super(key: key);
  final _name = 'Taro';
  final String text;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor:
          CurvedAnimation(parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name, style: Theme.of(context).textTheme.headline6),
                  Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: Text(text),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// StatefulWidget
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

// チャット欄とテキスト入力蘭のwidget
class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  // チャット欄
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(appName),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
      ),
      body: Container(
          child: Column(
            children: [
              Flexible(
                child: ListView.builder(
                  // メッセージが全て表示される
                  padding: const EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) =>
                      _messages[index], // 関数と添字が引数（今回関数は，_で無し）
                  itemCount: _messages.length,
                ),
              ),
              const Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(), // テキスト入力欄
              )
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[200]!),
                  ),
                )
              : null),
    );
  }

  // テキスト入力欄
  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration:
                  const InputDecoration.collapsed(hintText: 'Send a message.'),
              focusNode: _focusNode,
              onChanged: (String text) {
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
            ),
          ),
          IconTheme(
            data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text('send'),
                      onPressed: () => _isComposing
                          ? _handleSubmitted(_textController.text)
                          : null,
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _isComposing
                          ? _handleSubmitted(_textController.text)
                          : null,
                    ),
            ),
          )
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    var message = ChatMessage(
        text: text,
        animationController: AnimationController(
          duration: const Duration(milliseconds: 100),
          vsync: this,
        ));

    setState(() {
      _messages.insert(0, message);
    });

    _focusNode.requestFocus();
    message.animationController.forward();
  }

  @override
  void dispose() {
    for (var message in _messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }
}
