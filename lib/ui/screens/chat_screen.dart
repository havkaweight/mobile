import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:havka/constants/colors.dart';
import 'package:havka/model/user_data_model.dart';
import 'package:havka/ui/screens/authorization.dart';
import 'package:havka/ui/widgets/progress_indicator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../model/chat_message.dart';
import '../widgets/rounded_textfield.dart';

class ChatScreen extends StatefulWidget {
  final String? user;

  ChatScreen({
    this.user,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageTextController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  String? chatId;
  bool isChatExists = false;

  final ScrollController _chatScrollController = ScrollController();
  late final UserDataModel user;

  Future<void> checkExistingChat() async {
    final chat = await _firestore
        .collection("chats")
        .where("participants", arrayContains: user.user?.id).get();
    if (chat.docs.length == 1) {
      setState(() {
        isChatExists = true;
        chatId = chat.docs[0].id;
      });
    }
  }

  Future<String?> createChat() async {
    final chatsRef = _firestore.collection("chats");

    final newChat = await chatsRef.add({
      "name": widget.user,
      "participants": [user.user?.id, "admin"],
    });

    return newChat.id;
  }

  @override
  void initState() {
    super.initState();

    user = context.read<UserDataModel>();

    if(widget.user == null) {
      checkExistingChat();
    } else {
      isChatExists = true;
      chatId = widget.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: HavkaColors.cream,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: Offset(0.0, 2.0),
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(
                      width: 2,
                    ),
                    Container(
                      height: 45,
                      width: 45,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100.0),
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      child: Icon(widget.user == null ? Icons.support_agent : Icons.person),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.user ?? "Support",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          // Text(
                          //   "Online",
                          //   style: TextStyle(
                          //       color: Colors.grey.shade600, fontSize: 13),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Expanded(
                  child: !isChatExists
                    ? Center(
                      child: Text("No messages found")
                    )
                    : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("chats")
                        .doc(chatId)
                        .collection("messages")
                        .orderBy("createdAt", descending: true)
                        .limit(100)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: HavkaProgressIndicator(),
                        );
                      }
                      final messagesGroups = groupBy(snapshot.data!.docs, (el) => DateFormat("yyyy-MM-dd").format(DateTime.fromMillisecondsSinceEpoch(el["createdAt"].millisecondsSinceEpoch))).entries.map((entry) => {entry.key: entry.value}).toList();
                      return Scrollbar(
                        controller: _chatScrollController,
                        child: ListView.builder(
                          controller: _chatScrollController,
                          reverse: true,
                          itemCount: messagesGroups.length,
                          itemBuilder: (context, index) {
                            final messagesGroup = messagesGroups[index];
                            final String dateLabel = messagesGroup.keys.first;
                            final List items = messagesGroup.values.first;
                            return Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(vertical: 10.0),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                    vertical: 5.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.03),
                                    borderRadius: BorderRadius.circular(50.0),
                                  ),
                                  child: Text(
                                    dateLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                  reverse: true,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: items.length,
                                  itemBuilder: (BuildContext context, groupIndex) {
                                    return Message(
                                      text: items[groupIndex]["text"],
                                      timestamp: items[groupIndex]["createdAt"],
                                      messageType: items[groupIndex]["authorId"] == user.user?.id ? MessageType.outgoing : MessageType.incoming,
                                    );
                                  },
                                ),
                              ],
                            );
                          }
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: HavkaColors.cream,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: Offset(0.0, -2.0),
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: RoundedTextField(
                          controller: _messageTextController,
                          hintText: "Write a message...",
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (_messageTextController.text.isEmpty) {
                          return;
                        }
                        checkExistingChat();
                        if (chatId == null) {
                          chatId = await createChat();
                        }
                        final Map<String, dynamic> messageData = {
                          "authorId": user.user?.id,
                          "text": _messageTextController.text,
                          "createdAt": DateTime.now().toUtc(),
                        };

                        await FirebaseFirestore.instance
                            .collection("chats")
                            .doc(chatId)
                            .collection("messages")
                            .add(messageData);
                        _messageTextController.clear();
                      },
                      icon: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(HavkaColors.energy),
                      ),
                    ),
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
