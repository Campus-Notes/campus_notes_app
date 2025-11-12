import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common_widgets/app_bar.dart';
import '../controller/chat_controller.dart';
import 'chat_thread_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = context.watch<ChatController>();


    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Chats',
        sideIcon: Icons.edit_outlined,
        showBackButton: false,
        usePremiumBackIcon: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatController.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chats yet.'));
          }

          final chats = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final chatDoc = chats[i];
              final chatData = chatDoc.data() as Map<String, dynamic>;
              final chatId = chatDoc.id;
              final participants = List<String>.from(chatData['participants'] ?? []);
              final lastMessage = chatData['lastMessage'] ?? '';
              final timestamp = chatData['lastMessageTime'];


              final peerId = participants.firstWhere(
                (id) => id != chatController.currentUserId,
                orElse: () => '',
              );


              return FutureBuilder<Map<String, dynamic>?>(
                future: chatController.getUserData(peerId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading...'),
                    );
                  }

                  if (userSnapshot.hasError) {
                  }

                  final peerData = userSnapshot.data ?? {};

                  final peerName = peerData['name'] ?? peerData['email'] ?? 'Unknown User';
                  String timeText = '';
                  if (timestamp != null && timestamp is Timestamp) {
                    final dt = timestamp.toDate();
                    timeText = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: peerData['photoUrl'] != null
                          ? NetworkImage(peerData['photoUrl'])
                          : null,
                      child: peerData['photoUrl'] == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(peerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(timeText),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatThreadPage(
                            chatId: chatId,
                            peerId: peerId,
                            peerName: peerName,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
