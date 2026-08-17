import 'dart:convert';
import 'dart:io';

void main() async {
  // Read .env file directly
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('GROQ_API_KEY')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('Error: API key is empty or not found');
    return;
  }
  
  print('Testing Groq API...');
  
  final client = HttpClient();
  try {
    final request = await client.postUrl(Uri.parse('https://api.groq.com/openai/v1/chat/completions'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $apiKey');
    
    final payload = jsonEncode({
      'model': 'llama-3.3-70b-versatile',
      'messages': [
        {'role': 'user', 'content': 'Hello, are you working?'}
      ]
    });
    
    request.write(payload);
    final response = await request.close();
    
    print('Status: ${response.statusCode}');
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('Response: ${data['choices'][0]['message']['content']}');
    } else {
      print('Error Body: $responseBody');
    }
  } catch (e) {
    print('Exception: $e');
  } finally {
    client.close();
  }
}
