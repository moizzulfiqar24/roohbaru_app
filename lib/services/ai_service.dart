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

      final sentiment = map['sentiment']?.toString() ?? 'Neutral';
      final mood = map['mood']?.toString() ?? 'Calm';
      final suggestions = (map['suggestions'] as List?)
              ?.map((s) => s.toString())
              .toList() ??
          ['Take a deep breath', 'Stay present', 'Try a 5-minute meditation'];

      return AIResult(
        sentiment: sentiment,
        mood: mood,
        suggestions: suggestions,
      );
    } catch (e) {
      // Log the issue and fall back to default safe values
      print(
          '⚠️ Failed to parse JSON:\n$jsonText\n\nraw was:\n$raw\n\nError: $e');

      return AIResult(
        sentiment: 'Neutral',
        mood: 'Calm',
        suggestions: [
          'Take a walk in nature',
          'Reflect with a journal prompt',
          'Do a short breathing exercise',
        ],
      );
    }
  }

  // 🛠 Fix common formatting issues like unquoted values or extra notes
  String _sanitizeJsonLikeText(String input) {
    String cleaned = input;

    // Replace smart quotes and weird characters
    cleaned = cleaned
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('â', '"')
        .replaceAll('â', '"');

    // Remove all non-JSON content before first { and after last }
    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start >= 0 && end > start) {
      cleaned = cleaned.substring(start, end + 1);
    }

    // Ensure keys are wrapped in double quotes
    cleaned = cleaned.replaceAllMapped(
      RegExp(r'(\w+)\s*:'),
      (match) => '"${match[1]}":',
    );

    // Fix suggestions array (even if broken or unquoted)
    final suggestionsPattern =
        RegExp(r'"suggestions"\s*:\s*\[(.*?)\]', dotAll: true);
    final match = suggestionsPattern.firstMatch(cleaned);

    if (match != null) {
      final rawSuggestions = match.group(1)!;
      final parts = <String>[];
      final buffer = StringBuffer();
      bool insideQuotes = false;

      for (int i = 0; i < rawSuggestions.length; i++) {
        final char = rawSuggestions[i];
        if (char == '"' && (i == 0 || rawSuggestions[i - 1] != '\\')) {
          insideQuotes = !insideQuotes;
        }
        if (char == ',' && !insideQuotes) {
          parts.add(buffer.toString().trim());
          buffer.clear();
        } else {
          buffer.write(char);
        }
      }
      if (buffer.isNotEmpty) parts.add(buffer.toString().trim());

      final fixedSuggestions = parts.map((s) {
        String fixed = s.trim();

        if (fixed.startsWith('"')) fixed = fixed.substring(1);
        if (fixed.endsWith('"')) fixed = fixed.substring(0, fixed.length - 1);

        fixed = fixed.replaceAll(r'"', r'\"');
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
