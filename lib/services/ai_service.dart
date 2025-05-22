import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIResult {
  final String sentiment;
  final String mood;
  final String song;
  final String movie;
  final String analysis; // ← New field

  AIResult({
    required this.sentiment,
    required this.mood,
    required this.song,
    required this.movie,
    required this.analysis,
  });

  List<String> get suggestions => [song, movie];
}

class AIService {
  // Eight one-word personalities you can toggle:
  final bool calm;
  final bool cheerful;
  final bool empathetic;
  final bool gentle;
  final bool supportive;
  final bool humorous;
  final bool mindful;
  final bool optimistic;

  AIService({
    this.calm = false,
    this.cheerful = false,
    this.empathetic = false,
    this.gentle = false,
    this.supportive = true, // ← default must pick at least one
    this.humorous = false,
    this.mindful = false,
    this.optimistic = false,
  }) : assert(
          calm ||
              cheerful ||
              empathetic ||
              gentle ||
              supportive ||
              humorous ||
              mindful ||
              optimistic,
          'At least one personality must be true',
        );

  final String _apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama3-8b-8192';

  Future<AIResult> analyzeEntry(String content) async {
    if (_apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not set in .env');
    }

    // Build list of selected personalities
    final names = <String>[];
    if (calm) names.add('calm');
    if (cheerful) names.add('cheerful');
    if (empathetic) names.add('empathetic');
    if (gentle) names.add('gentle');
    if (supportive) names.add('supportive');
    if (humorous) names.add('humorous');
    if (mindful) names.add('mindful');
    if (optimistic) names.add('optimistic');
    final pList = names.join(', ');

    final systemPrompt = '''
You are a $pList assistant acting as a friendly, amateur psychiatrist. 
Analyze the following journal entry and return strict JSON with:
- "sentiment": Positive, Negative, or Neutral
- "mood": one of: Happy, Excited, Calm, Grateful, Loving, Confident, Sad, Angry, Anxious, Lonely, Guilty, Jealous, Confused, Surprised, Bored, Restless, Inspired, Distracted
- "song": one song recommendation for the mood
- "movie": one movie recommendation for the mood
- "analysis": a 2–3 line soothing comment or suggestion as if you were a caring friend

Example:
{"sentiment":"Positive","mood":"Calm","song":"Weightless by Marconi Union","movie":"The Secret Life of Walter Mitty","analysis":"It sounds like you’re finding peace in small moments—keep nurturing this calm by taking a few deep breaths when things feel overwhelming. Remember, every step forward, no matter how gentle, is progress. Feel free to revisit this exercise whenever you need a moment of quiet."}

Only return strict JSON. No extra text.
''';

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      {'role': 'user', 'content': content},
    ];

    final body = {'model': _model, 'messages': messages, 'temperature': 0.3};

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
    final raw = decoded['choices'][0]['message']['content'] as String;

    try {
      log(pList);
      final jsonText = _extractJson(raw);
      final data = jsonDecode(jsonText);
      return AIResult(
        sentiment: data['sentiment'] ?? 'Neutral',
        mood: data['mood'] ?? 'Calm',
        song: data['song'] ?? 'No suggestion',
        movie: data['movie'] ?? 'No suggestion',
        analysis: data['analysis'] ?? '',
      );
    } catch (e) {
      print('⚠️ Failed to parse JSON:\n$raw\nError: $e');
      return AIResult(
        sentiment: 'Neutral',
        mood: 'Calm',
        song: 'Weightless by Marconi Union',
        movie: 'The Secret Life of Walter Mitty',
        analysis:
            'I’m here to listen—remember to take slow, deep breaths and be gentle with yourself. You’re doing your best, and that’s enough.',
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
