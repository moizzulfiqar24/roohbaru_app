import 'package:cloud_firestore/cloud_firestore.dart';

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime timestamp;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  JournalEntry copyWith({String? title, String? content}) {
    return JournalEntry(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp,
    );
  }
}
