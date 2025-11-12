import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../theme/app_theme.dart';
import '../../../../common_widgets/app_bar.dart';
import '../controller/chat_controller.dart';

class ChatThreadPage extends StatefulWidget {
  const ChatThreadPage({
    super.key,
    required this.chatId,
    required this.peerId,
    required this.peerName,
  });

  final String chatId;
  final String peerId;
  final String peerName;

  @override
  State<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends State<ChatThreadPage> {
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mark all messages as read when opening chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatController = context.read<ChatController>();
      chatController.markMessagesAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final chatController = context.read<ChatController>();
    await chatController.sendMessage(
      chatId: widget.chatId,
      message: text,
      receiverId: widget.peerId,
    );
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = context.watch<ChatController>();

    return Scaffold(
      appBar: CustomAppBar(
        text: widget.peerName,
        sideIcon: Icons.videocam_outlined,
        usePremiumBackIcon: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatController.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msgData = messages[i].data() as Map<String, dynamic>;
                    final senderId = msgData['senderId'] ?? '';
                    final text = msgData['message'] ?? '';
                    final timestamp = msgData['timestamp'] as Timestamp?;
                    final isMe = senderId == chatController.currentUserId;

                    // Format timestamp nicely
                    String time = '';
                    if (timestamp != null) {
                      final dt = timestamp.toDate();
                      time = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                    }

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe
                              ? AppColors.primary.withValues(alpha: 0.12)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              time,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: const InputDecoration(
                      hintText: 'Message...',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
