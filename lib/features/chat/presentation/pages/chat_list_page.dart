import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../../common_widgets/app_bar.dart';
import '../../../../theme/app_theme.dart';
import '../controller/chat_controller.dart';
import 'chat_thread_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    
    final dt = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dt.year, dt.month, dt.day);
    
    if (messageDate == today) {
      return DateFormat('HH:mm').format(dt);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dt).inDays < 7) {
      return DateFormat('EEE').format(dt);
    } else {
      return DateFormat('MMM d').format(dt);
    }
  }

  void _showChatOptions(
    BuildContext context, {
    required String chatId,
    required String peerName,
    required bool isPinned,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final chatController = context.read<ChatController>();
        
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  peerName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ListTile(
                leading: Icon(
                  isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                title: Text(isPinned ? 'Unpin Chat' : 'Pin Chat'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await chatController.togglePinChat(chatId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isPinned ? 'Chat unpinned' : 'Chat pinned',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update chat'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.volume_off, 
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                ),
                title: const Text('Mute Notifications'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await chatController.muteChat(chatId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat muted'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to mute chat'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.archive_outlined, 
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)
                ),
                title: const Text('Archive Chat'),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await chatController.archiveChat(chatId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Chat archived'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to archive chat'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Chat',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, chatId, peerName, chatController);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String chatId,
    String peerName,
    ChatController chatController,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text(
          'Are you sure you want to delete your conversation with $peerName? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await chatController.deleteChat(chatId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chat deleted'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to delete chat'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatController = context.watch<ChatController>();

    return Scaffold(
      appBar: const CustomAppBar(
        text: 'Chats',
        showBackButton: true,
        usePremiumBackIcon: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatController.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, 
                    size: 64, 
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No chats yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation to see your chats here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          final chats = snapshot.data!.docs;
          
          // Sort chats: pinned first, then by timestamp
          final sortedChats = chats.toList()..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            
            final aPinned = aData['isPinned'] ?? false;
            final bPinned = bData['isPinned'] ?? false;
            
            if (aPinned && !bPinned) return -1;
            if (!aPinned && bPinned) return 1;
            
            final aTime = aData['lastMessageTime'] as Timestamp?;
            final bTime = bData['lastMessageTime'] as Timestamp?;
            
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            
            return bTime.compareTo(aTime);
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: sortedChats.length,
            itemBuilder: (_, i) {
              final chatDoc = sortedChats[i];
              final chatData = chatDoc.data() as Map<String, dynamic>;
              final chatId = chatDoc.id;
              final participants = List<String>.from(chatData['participants'] ?? []);
              final lastMessage = chatData['lastMessage'] ?? '';
              final timestamp = chatData['lastMessageTime'] as Timestamp?;
              final unreadCount = chatData['unreadCount']?[chatController.currentUserId] ?? 0;
              final isPinned = chatData['isPinned'] ?? false;

              final peerId = participants.firstWhere(
                (id) => id != chatController.currentUserId,
                orElse: () => '',
              );

              return FutureBuilder<Map<String, dynamic>?>(
                future: chatController.getUserData(peerId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingTile();
                  }

                  final peerData = userSnapshot.data ?? {};
                  final peerName = peerData['firstName'] ?? 'Unknown User';
                  final photoUrl = peerData['photoUrl'];
                  final timeText = _formatTimestamp(timestamp);

                  return InkWell(
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
                    onLongPress: () {
                      _showChatOptions(
                        context,
                        chatId: chatId,
                        peerName: peerName,
                        isPinned: isPinned,
                      );
                    },
                    child: Container(
                      color: isPinned 
                          ? (Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]?.withValues(alpha: 0.3)
                              : Colors.grey[100])
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                                backgroundImage: photoUrl != null
                                    ? NetworkImage(photoUrl)
                                    : null,
                                child: photoUrl == null
                                    ? Text(
                                        peerName.isNotEmpty 
                                            ? peerName[0].toUpperCase() 
                                            : '?',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          
                          // Chat info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (isPinned) ...[
                                      const Icon(
                                        Icons.push_pin,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Expanded(
                                      child: Text(
                                        peerName,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: unreadCount > 0 
                                              ? FontWeight.w600 
                                              : FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (timeText.isNotEmpty)
                                      Text(
                                        timeText,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: unreadCount > 0
                                              ? AppColors.primary
                                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                                          fontWeight: unreadCount > 0
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lastMessage.isEmpty 
                                            ? 'No messages yet' 
                                            : lastMessage,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: unreadCount > 0
                                              ? Theme.of(context).colorScheme.onSurface
                                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                          fontWeight: unreadCount > 0
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (unreadCount > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 20,
                                          minHeight: 20,
                                        ),
                                        child: Text(
                                          unreadCount > 99 ? '99+' : '$unreadCount',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Icon(Icons.person, color: AppColors.primary.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}