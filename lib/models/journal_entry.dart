import 'package:cloud_firestore/cloud_firestore.dart';

class Attachment {
  final String url;
  final String name;
  final String type; // e.g., 'image', 'pdf', 'doc'

  Attachment({required this.url, required this.name, required this.type});

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      url: map['url'],
      name: map['name'],
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'name': name,
      'type': type,
    };
  }
}

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<Attachment> attachments;

  JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
    this.attachments = const [],
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      content: data['content'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      attachments: (data['attachments'] as List<dynamic>? ?? [])
          .map((a) => Attachment.fromMap(a))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'attachments': attachments.map((a) => a.toMap()).toList(),
    };
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    List<Attachment>? attachments,
  }) {
    return JournalEntry(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp,
      attachments: attachments ?? this.attachments,
    );
  }
}
