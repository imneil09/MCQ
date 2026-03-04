import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/env.dart';
import '../core/database/models.dart';

class GeminiService {
  Future<List<MCQModel>> convertTextToMCQ(String textChunk) async {
    return await _attemptConversion(textChunk, retry: true);
  }

  Future<List<MCQModel>> _attemptConversion(String textChunk, {required bool retry}) async {
    const String url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${Env.geminiApiKey}';

    const String promptText = "Convert the following exam text into structured MCQ JSON array.\n"
        "Each object must contain:\n"
        "{\n"
        "  id: string,\n"
        "  question: string,\n"
        "  options: array of 4 strings,\n"
        "  correctIndex: integer (0-3),\n"
        "  topic: string,\n"
        "  difficulty: easy/medium/hard\n"
        "}\n"
        "Return ONLY valid JSON array. No explanation.\n\nText:\n";

    final Map<String, dynamic> body = {
      "contents": [
        {
          "parts": [
            {"text": promptText + textChunk}
          ]
        }
      ]
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String rawText = data['candidates'][0]['content']['parts'][0]['text'];
        final String jsonString = _extractJsonArray(rawText);
        final List<dynamic> jsonList = jsonDecode(jsonString);

        return jsonList.map((e) {
          final model = MCQModel()
            ..id = e['id']?.toString() ?? const Uuid().v4()
            ..question = e['question'] ?? ''
            ..options = List<String>.from(e['options'] ?? [])
            ..correctIndex = e['correctIndex'] ?? 0
            ..topic = e['topic'] ?? 'General'
            ..difficulty = e['difficulty'] ?? 'medium';
          return model;
        }).toList();
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (retry) {
        return await _attemptConversion(textChunk, retry: false);
      }
      throw Exception('Failed to convert text to MCQ: $e');
    }
  }

  String _extractJsonArray(String raw) {
    int start = raw.indexOf('[');
    int end = raw.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      return raw.substring(start, end + 1);
    }
    return '[]';
  }
}