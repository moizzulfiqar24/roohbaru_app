// lib/services/ai_service.dart

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
1) Determine overall sentiment (Positive/Negative/Neutral).
2) Pick exactly one mood from: Happy, Excited, Calm, Grateful, Loving, Confident, Sad, Angry, Anxious, Lonely, Guilty, Jealous, Confused, Surprised, Bored, Restless, Inspired, Distracted.
3) Provide three decisive suggestions (music, quote, meditation) based on that mood.

OUTPUT ONLY a JSON object with keys "sentiment", "mood", and "suggestions" (an array of 3 strings), with no extra commentary.
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

    // locate the JSON object
    final start = raw.indexOf('{');
    if (start < 0) {
      throw FormatException('Couldn’t find JSON start in Groq response: $raw');
    }

    // try to find the last closing brace
    int end = raw.lastIndexOf('}');
    // if there is no trailing '}', but there is a closing ']',
    // assume JSON ended at that array and append '}'
    if (end < 0) {
      final arrayEnd = raw.lastIndexOf(']');
      if (arrayEnd < 0 || arrayEnd <= start) {
        throw FormatException('Couldn’t find JSON end in Groq response: $raw');
      }
      // include the ']' then add the missing '}'
      final jsonText = raw.substring(start, arrayEnd + 1) + '}';
      return _parseJson(jsonText, raw);
    }

    // normal case: we have both braces
    final jsonText = raw.substring(start, end + 1);
    return _parseJson(jsonText, raw);
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
}
