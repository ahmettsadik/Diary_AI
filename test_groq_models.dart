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

  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse('https://api.groq.com/openai/v1/models'));
    request.headers.set('Authorization', 'Bearer $apiKey');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      final models = (data['data'] as List).map((m) => m['id']).toList();
      print('Available models: $models');
    } else {
      print('Error Body: $responseBody');
    }
  } catch (e) {
    print('Exception: $e');
  } finally {
    client.close();
  }
}
