
class NoteItem {
  final String id;
  final String title;
  final String subject;
  final String seller;
  final double price; 
  final double rating;
  final int pages;
  final List<String> tags;
  
  const NoteItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.seller,
    required this.price,
    required this.rating,
    required this.pages,
    required this.tags,
  });
}

final dummyNotes = [
  const NoteItem(
    id: 'n1',
    title: 'Data Structures: Exam Cheatsheet',
    subject: 'CS - Data Structures',
    seller: 'Ananya Sharma',
    price: 59.0,
    rating: 4.7,
    pages: 18,
    tags: ['cs', 'dsa', 'semester-4'],
  ),
  const NoteItem(
    id: 'n2',
    title: 'Microeconomics Quick Revision',
    subject: 'Economics',
    seller: 'Rohit Verma',
    price: 39.0,
    rating: 4.4,
    pages: 12,
    tags: ['eco', 'first-year'],
  ),
  const NoteItem(
    id: 'n3',
    title: 'Discrete Math Problem Set + Keys',
    subject: 'Math',
    seller: 'Ishita Rao',
    price: 79.0,
    rating: 4.8,
    pages: 26,
    tags: ['math', 'dm', 'semester-3'],
  ),
];

class Message {
  final String id;
  final String sender; // "me" or name
  final String text;
  final DateTime time;
  
  const Message({
    required this.id,
    required this.sender,
    required this.text,
    required this.time,
  });
}

final dummyThreads = [
  {
    'peer': 'Ananya Sharma',
    'last': 'Sure, it covers trees and graphs.',
    'time': '10:24',
    'unread': 2,
  },
  {
    'peer': 'Rohit Verma',
    'last': 'I can share a preview.',
    'time': 'Yesterday',
    'unread': 0,
  },
];

final dummyMessages = <Message>[
  Message(
    id: 'm1',
    sender: 'Ananya',
    text: 'Hi! These cover graphs?',
    time: DateTime(2025, 1, 1, 10, 12),
  ),
  Message(
    id: 'm2',
    sender: 'me',
    text: 'Yes, plus trees & heaps.',
    time: DateTime(2025, 1, 1, 10, 15),
  ),
  Message(
    id: 'm3',
    sender: 'Ananya',
    text: 'Great! Price negotiable?',
    time: DateTime(2025, 1, 1, 10, 18),
  ),
];

class PurchaseItem {
  final String id;
  final String title;
  final String subject;
  final DateTime date;
  final double amount;
  
  const PurchaseItem({
    required this.id,
    required this.title,
    required this.subject,
    required this.date,
    required this.amount,
  });
}

final dummyPurchases = [
  PurchaseItem(
    id: 'p1',
    title: 'Data Structures: Exam Cheatsheet ',
    subject: 'CS - Data Structures',
    date: DateTime(2025, 1, 2),
    amount: 59,
  ),
  PurchaseItem(
    id: 'p2',
    title: 'Microeconomics Quick Revision',
    subject: 'Economics',
    date: DateTime(2025, 1, 5),
    amount: 39,
  ),
];
