import 'dart:convert';
import 'dart:io';

void main() async {
  final envFile = File('.env');
  final lines = await envFile.readAsLines();
  String? apiKey;
  for (var line in lines) {
    if (line.startsWith('GROQ_API_KEY')) {
      apiKey = line.split('=')[1].trim();
      break;
    }
  }

  final modelsToTest = ['groq/compound', 'qwen/qwen3.6-27b', 'openai/gpt-oss-20b', 'openai/gpt-oss-120b'];
  final client = HttpClient();
  
  for (var model in modelsToTest) {
    final request = await client.postUrl(Uri.parse('https://api.groq.com/openai/v1/chat/completions'));
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer $apiKey');
    
    final payload = jsonEncode({
      'model': model,
      'messages': [
        {'role': 'user', 'content': 'Say exactly "working"'}
      ]
    });
    
    request.write(payload);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      print('Success for $model');
    } else {
      print('Failed for $model: $responseBody');
    }
  }
  client.close();
}
