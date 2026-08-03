import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/diary_entry.dart';

class LLMService {
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _model = 'llama-3.3-70b-versatile';

  Future<String?> generateContextualQuestion(DiaryEntry entry) async {
    if (entry.isEncrypted) {
      return null;
    }

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an empathetic journaling assistant. Based on the user\'s diary entry, generate one brief, thoughtful follow-up reflection question.'
            },
            {
              'role': 'user',
              'content': entry.content,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> generateWeeklyInsights(List<DiaryEntry> entries) async {
    // Filter out encrypted entries to ensure privacy
    final List<DiaryEntry> processableEntries =
        entries.where((e) => !e.isEncrypted).toList();

    if (processableEntries.isEmpty) {
      return null;
    }

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final combinedContent = processableEntries
          .map((e) => 'Entry from ${e.timestamp.toIso8601String()}:\n${e.content}')
          .join('\n\n');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are an insightful journaling assistant. Analyze the following diary entries and identify 3 recurring emotional themes or patterns. Be concise and empathetic.'
            },
            {
              'role': 'user',
              'content': combinedContent,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> chatWithPast(String question, List<DiaryEntry> retrievedEntries) async {
    if (retrievedEntries.isEmpty) {
      return 'I couldn\'t find any public entries matching your question.';
    }

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return null;
      }

      final combinedContent = retrievedEntries
          .map((e) => 'Entry from ${e.timestamp.toIso8601String()}:\n${e.content}')
          .join('\n\n');

      final systemPrompt = 'You are a personal diary assistant. Your job is to answer the user\'s question based ONLY on the provided diary entries below. Do not make up information. If the answer is not in the entries, say so.\n\n$combinedContent';

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt
            },
            {
              'role': 'user',
              'content': question,
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content']?.trim();
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
