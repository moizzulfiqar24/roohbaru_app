import 'package:cloud_firestore/cloud_firestore.dart';

class Attachment {
  final String url;
  final String name;
  final String type; // e.g., 'image', 'pdf', 'doc'

  Attachment({required this.url, required this.name, required this.type});

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      url: map['url'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
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

  // NEW:
  final String sentiment;
  final String mood;
  final List<String> suggestions;

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.timestamp,
    this.attachments = const [],
    this.sentiment = '',
    this.mood = '',
    this.suggestions = const [],
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      userId: data['userId'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      attachments: (data['attachments'] as List<dynamic>? ?? [])
          .map((a) => Attachment.fromMap(a as Map<String, dynamic>))
          .toList(),
      sentiment: data['sentiment'] as String? ?? '',
      mood: data['mood'] as String? ?? '',
      suggestions:
          List<String>.from(data['suggestions'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'sentiment': sentiment,
      'mood': mood,
      'suggestions': suggestions,
    };
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    List<Attachment>? attachments,
    String? sentiment,
    String? mood,
    List<String>? suggestions,
  }) {
    return JournalEntry(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp,
      attachments: attachments ?? this.attachments,
      sentiment: sentiment ?? this.sentiment,
      mood: mood ?? this.mood,
      suggestions: suggestions ?? this.suggestions,
    );
  }
}
