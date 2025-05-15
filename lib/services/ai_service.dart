import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIResult {
  final String sentiment;
  final String mood;
  final String song;
  final String movie;

  AIResult({
    required this.sentiment,
    required this.mood,
    required this.song,
    required this.movie,
  });

  List<String> get suggestions => [song, movie];
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
You are a helpful assistant. Analyze the following journal entry and return JSON with:
- "sentiment": Positive, Negative, or Neutral
- "mood": one of: Happy, Excited, Calm, Grateful, Loving, Confident, Sad, Angry, Anxious, Lonely, Guilty, Jealous, Confused, Surprised, Bored, Restless, Inspired, Distracted
- "song": one song recommendation for the mood
- "movie": one movie recommendation for the mood

Example:
{"sentiment": "Positive", "mood": "Calm", "song": "Weightless by Marconi Union", "movie": "The Secret Life of Walter Mitty"}

Only return strict JSON. No commentary or explanations.
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
      'temperature': 0.3,
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Groq API error ${response.statusCode}: ${response.body}');
    }

    final decoded = jsonDecode(response.body);
    final rawContent = decoded['choices'][0]['message']['content'];

    try {
      final jsonText = _extractJson(rawContent);
      final data = jsonDecode(jsonText);

      return AIResult(
        sentiment: data['sentiment'] ?? 'Neutral',
        mood: data['mood'] ?? 'Calm',
        song: data['song'] ?? 'No suggestion',
        movie: data['movie'] ?? 'No suggestion',
      );
    } catch (e) {
      print('⚠️ Failed to parse JSON:\n$rawContent\n\nError: $e');
      return AIResult(
        sentiment: 'Neutral',
        mood: 'Calm',
        song: 'Weightless by Marconi Union',
        movie: 'The Secret Life of Walter Mitty',
      );
    }
  }

  String _extractJson(String raw) {
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start < 0 || end <= start) {
      throw FormatException('No valid JSON object found.');
    }
    return raw.substring(start, end + 1);
  }
}
