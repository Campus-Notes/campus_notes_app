import 'package:flutter/material.dart';
import '../../../../data/dummy_data.dart';

class ChatController extends ChangeNotifier {
  List<Map<String, dynamic>> _threads = [];
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  String? _currentThreadId;
  
  List<Map<String, dynamic>> get threads => _threads;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentThreadId => _currentThreadId;
  
  ChatController() {
    _loadThreads();
  }
  
  void _loadThreads() {
    _threads = List.from(dummyThreads);
    notifyListeners();
  }
  
  void openThread(String threadId, String peerName) {
    _currentThreadId = threadId;
    _loadMessages(threadId);
  }
  
  void _loadMessages(String threadId) {
    _isLoading = true;
    notifyListeners();
    
    // Simulate loading messages
    Future.delayed(const Duration(milliseconds: 500), () {
      _messages = List.from(dummyMessages);
      _isLoading = false;
      notifyListeners();
    });
  }
  
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    final newMessage = Message(
      id: 'm${DateTime.now().millisecondsSinceEpoch}',
      sender: 'me',
      text: text.trim(),
      time: DateTime.now(),
    );
    
    _messages.add(newMessage);
    notifyListeners();
    
    // Simulate receiving a response
    Future.delayed(const Duration(seconds: 2), () {
      final responses = [
        'That sounds great!',
        'I agree with you.',
        'Thanks for sharing!',
        'Interesting point.',
        'Let me think about it.',
      ];
      
      final response = Message(
        id: 'm${DateTime.now().millisecondsSinceEpoch}',
        sender: 'Other User',
        text: responses[DateTime.now().millisecond % responses.length],
        time: DateTime.now(),
      );
      
      _messages.add(response);
      notifyListeners();
    });
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}