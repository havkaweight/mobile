import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '/core/constants/colors.dart';
import '/presentation/screens/authorization.dart';
import '/presentation/widgets/progress_indicator.dart';
import 'package:intl/intl.dart';

import '/core/constants/utils.dart';
import '../widgets/chat_message.dart';
import '/presentation/widgets/rounded_textfield.dart';

class ChatsListScreen extends StatefulWidget {
  @override
  _ChatsListScreenState createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {

  final ScrollController _chatListController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Chats",
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
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("chats")
                      .where("participants", arrayContains: "admin")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> chatsSnapshot) {
                    if (!chatsSnapshot.hasData) {
                      return Center(
                        child: HavkaProgressIndicator(),
                      );
                    }
                    final chats = chatsSnapshot.data!.docs;
                    return Scrollbar(
                      controller: _chatListController,
                      child: ListView.builder(
                        controller: _chatListController,
                        shrinkWrap: true,
                        itemCount: chats.length,
                        itemBuilder: (BuildContext context, index) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  context.push("/profile/chats/chat", extra: chats[index].id);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                                  height: 70,
                                  alignment: AlignmentDirectional.centerStart,
                                  child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection("chats")
                                          .doc(chats[index].id)
                                          .collection("messages")
                                          .where("text", isNotEqualTo: null)
                                          .orderBy("createdAt", descending: true)
                                          .limit(1)
                                          .snapshots(),
                                      builder: (context,
                                          AsyncSnapshot<QuerySnapshot>
                                              messagesSnapshot) {
                                        if (!messagesSnapshot.hasData) {
                                          return Center(
                                            child: HavkaProgressIndicator(),
                                          );
                                        }
                                        final messages =
                                            messagesSnapshot.data!.docs;
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  chats[index].id,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  Utils().cutString(
                                                      messages.first["text"]
                                                          .toString()
                                                          .split("\n")
                                                          .first,
                                                      30),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                                DateFormat("HH:mm").format(DateTime.fromMillisecondsSinceEpoch(messages.first["createdAt"].millisecondsSinceEpoch)),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ),
                              Divider(
                                height: 1.0,
                                color: Colors.black.withOpacity(0.05),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
