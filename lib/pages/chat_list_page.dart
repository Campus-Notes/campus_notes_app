import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import 'chat_thread_page.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: dummyThreads.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final t = dummyThreads[i];
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(t['peer'] as String),
            subtitle: Text(t['last'] as String, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t['time'] as String),
                const SizedBox(height: 4),
                if ((t['unread'] as int) > 0)
                  CircleAvatar(radius: 10, backgroundColor: Colors.red, child: Text('${t['unread']}', style: const TextStyle(color: Colors.white, fontSize: 12))),
              ],
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatThreadPage(peerName: 'Ananya Sharma'))),
          );
        },
      ),
    );
  }
}
