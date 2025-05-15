import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIResult {
  final String sentiment;
  final String mood;
  final List<String> suggestions;

  AIResult({
    required this.sentiment,
    required this.mood,
    required this.suggestions,
  });
}

class AIService {
  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';

  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama3-8b-8192';

  Future<AIResult> analyzeEntry(String content) async {
    if (_apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not set in .env');
    }

    final messages = [
      {
        'role': 'system',
        'content': '''
You are a helpful assistant. Analyze the following journal entry and:
1) Determine overall sentiment (Positive, Negative, or Neutral).
2) Pick exactly one mood from this list: Happy, Excited, Calm, Grateful, Loving, Confident, Sad, Angry, Anxious, Lonely, Guilty, Jealous, Confused, Surprised, Bored, Restless, Inspired, Distracted.
3) Return three suggestions (music, quote, and meditation) suitable for the mood.

Return only a strict JSON object using double quotes for all keys and values, like:
{"sentiment": "...", "mood": "...", "suggestions": ["...", "...", "..."]}
Do not include any commentary or explanation.
'''
      },
      {
        'role': 'user',
        'content': content,
      }
    ];

    final body = {
      'model': _model,
      'messages': messages,
      'temperature': 0.2,
    };

    final resp = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode != 200) {
      throw Exception('Groq API error ${resp.statusCode}: ${resp.body}');
    }

    final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
    final raw =
        (decoded['choices'] as List).first['message']['content'] as String;

    final start = raw.indexOf('{');
    if (start < 0) {
      throw FormatException('Couldn’t find JSON start in Groq response: $raw');
    }

    int end = raw.lastIndexOf('}');
    if (end < 0) {
      final arrayEnd = raw.lastIndexOf(']');
      if (arrayEnd < 0 || arrayEnd <= start) {
        throw FormatException('Couldn’t find JSON end in Groq response: $raw');
      }
      final jsonText = raw.substring(start, arrayEnd + 1) + '}';
      return _parseJson(_sanitizeJsonLikeText(jsonText), raw);
    }

    final jsonText = raw.substring(start, end + 1);
    return _parseJson(_sanitizeJsonLikeText(jsonText), raw);
  }

  AIResult _parseJson(String jsonText, String raw) {
    try {
      final map = jsonDecode(jsonText) as Map<String, dynamic>;
      return AIResult(
        sentiment: map['sentiment'] as String,
        mood: map['mood'] as String,
        suggestions: List<String>.from(map['suggestions'] as List),
      );
    } catch (e) {
      throw FormatException(
          'Invalid JSON from Groq:\n$jsonText\n\nraw was:\n$raw');
    }
  }

  // 🛠 Fix common formatting issues like unquoted values or extra notes
  String _sanitizeJsonLikeText(String input) {
    String cleaned = input;

    // Fix encoding issues like smart quotes or UTF-8 junk
    cleaned = cleaned
        .replaceAll('â', '"')
        .replaceAll('â', '"')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'");

    // Ensure all keys have double quotes
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(\w+)\s*:'),
      (match) => '"${match[1]}":',
    );

    // Rebuild suggestions array if broken
    final suggestionsPattern =
        RegExp(r'"suggestions"\s*:\s*\[(.*?)\]', dotAll: true);
    final match = suggestionsPattern.firstMatch(cleaned);
    if (match != null) {
      final rawSuggestions = match.group(1)!;

      // Split suggestions on comma, but avoid splitting inside quotes
      final parts = rawSuggestions.split(RegExp(r',(?![^"]*"\s*,\s*[^"]*")'));

      final fixedSuggestions = parts.map((s) {
        // Clean outer and inner quotes
        String fixed = s.trim();

        // Remove leading/trailing quotes
        if (fixed.startsWith('"')) fixed = fixed.substring(1);
        if (fixed.endsWith('"')) fixed = fixed.substring(0, fixed.length - 1);

        // Escape quotes inside string
        fixed = fixed.replaceAll('"', r'\"');

        return '"$fixed"';
      }).join(', ');

      cleaned = cleaned.replaceRange(
        match.start,
        match.end,
        '"suggestions": [$fixedSuggestions]',
      );
    }

    return cleaned;
  }
}
