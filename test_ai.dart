import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  await dotenv.load(fileName: ".env");
  final apiKey = dotenv.env['GROQ_API_KEY'];
  
  if (apiKey == null || apiKey.isEmpty) {
    print('Error: API key is empty or not found');
    return;
  }
  
  print('Testing Groq API...');
  
  try {
    final response = await http.post(
      Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'llama-3.3-70b-versatile',
        'messages': [
          {'role': 'user', 'content': 'Hello, are you working?'}
        ]
      }),
    );
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Response: ${data['choices'][0]['message']['content']}');
    } else {
      print('Error Body: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
