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

    print('[ChatListPage] Building chat list page for user: ${chatController.currentUserId}');

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
          print('[StreamBuilder] Connection state: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('[StreamBuilder] Waiting for chat stream...');
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('[StreamBuilder] Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            print('[StreamBuilder] No chat documents found.');
            return const Center(child: Text('No chats yet.'));
          }

          final chats = snapshot.data!.docs;
          print('[StreamBuilder] Chats fetched: ${chats.length}');
          for (var doc in chats) {
            print('  -> Chat ID: ${doc.id}, data: ${doc.data()}');
          }

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

              print('[ListItem] Chat: $chatId');
              print('  participants: $participants');
              print('  lastMessage: $lastMessage');
              print('  lastMessageTime: $timestamp');

              final peerId = participants.firstWhere(
                (id) => id != chatController.currentUserId,
                orElse: () => '',
              );

              print('  resolved peerId: $peerId');

              return FutureBuilder<Map<String, dynamic>?>(
                future: chatController.getUserData(peerId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    print('[FutureBuilder] Fetching user data for $peerId...');
                    return const ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('Loading...'),
                    );
                  }

                  if (userSnapshot.hasError) {
                    print('[FutureBuilder] Error fetching user data for $peerId: ${userSnapshot.error}');
                  }

                  final peerData = userSnapshot.data ?? {};
                  print('[FutureBuilder] Peer data for $peerId: $peerData');

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
                      print('[onTap] Opening chat thread for: $peerId in chat $chatId');
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
