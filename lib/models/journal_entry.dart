import 'package:cloud_firestore/cloud_firestore.dart';

class Attachment {
  final String url;
  final String name;
  final String type; 
  final String? base64Data;

  Attachment({
    required this.url,
    required this.name,
    required this.type,
    this.base64Data,
  });

  factory Attachment.fromMap(Map<String, dynamic> map) {
    return Attachment(
      url: map['url'] as String,
      name: map['name'] as String,
      type: map['type'] as String,
      base64Data: map['data'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final m = <String, dynamic>{
      'url': url,
      'name': name,
      'type': type,
    };
    if (base64Data != null) {
      m['data'] = base64Data;
    }
    return m;
  }
}

class JournalEntry {
  final String id;
  final String userId;
  final String title;
  final String content;
  final DateTime timestamp;
  final List<Attachment> attachments;
  final String sentiment;
  final String mood;
  final List<String> suggestions;
  final String analysis;

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
    this.analysis = '',
  });

  /// Create from Firestore document
  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
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
      analysis: data['analysis'] as String? ?? '',
    );
  }

  /// Serialize for Firestore
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'content': content,
        'timestamp': Timestamp.fromDate(timestamp),
        'attachments': attachments.map((a) => a.toMap()).toList(),
        'sentiment': sentiment,
        'mood': mood,
        'suggestions': suggestions,
        'analysis': analysis,
      };

  /// JSON serialization for caching
  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'attachments': attachments.map((a) => a.toMap()).toList(),
        'sentiment': sentiment,
        'mood': mood,
        'suggestions': suggestions,
        'analysis': analysis,
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) =>
                  Attachment.fromMap(Map<String, dynamic>.from(a as Map)))
              .toList() ??
          [],
      sentiment: json['sentiment'] as String? ?? '',
      mood: json['mood'] as String? ?? '',
      suggestions:
          List<String>.from(json['suggestions'] as List<dynamic>? ?? []),
      analysis: json['analysis'] as String? ?? '',
    );
  }

  JournalEntry copyWith({
    String? title,
    String? content,
    List<Attachment>? attachments,
    String? sentiment,
    String? mood,
    List<String>? suggestions,
    String? analysis,
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
      analysis: analysis ?? this.analysis,
    );
  }
}
