// lib/services/quote_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class Quote {
  final String text;
  final String author;

  Quote({
    required this.text,
    required this.author,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => Quote(
        text: json['q'] as String,
        author: json['a'] as String,
      );
}

class QuoteService {
  /// Fetches today’s quote from zenquotes.io
  static Future<Quote> fetchTodayQuote() async {
    final resp = await http.get(Uri.parse('https://zenquotes.io/api/today'));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load quote (${resp.statusCode})');
    }

    // ZenQuotes returns a List of Map, e.g. [ { "q": "...", "a": "...", ... } ]
    final data = jsonDecode(resp.body);
    if (data is! List || data.isEmpty) {
      throw Exception('Unexpected response format from quote API');
    }

    final first = data.first;
    if (first is! Map<String, dynamic>) {
      throw Exception('Unexpected item type in quote API response');
    }

    return Quote.fromJson(first);
  }
}
