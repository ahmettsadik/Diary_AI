import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../database/database_helper.dart';
import 'llm_service.dart';
import '../models/diary_entry.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'generateWeeklyInsights') {
      try {
        await dotenv.load();
        
        final dbHelper = DatabaseHelper();
        final llmService = LLMService();
        
        // Fetch all entries where is_encrypted = 0 AND analyzed_for_patterns = 0
        final entries = await dbHelper.getEntriesForAnalysis();
        
        if (entries.isEmpty) {
          return Future.value(true);
        }
        
        // Pass them to LLMService.generateWeeklyInsights
        final insightText = await llmService.generateWeeklyInsights(entries);
        
        if (insightText != null && insightText.isNotEmpty) {
          final db = await dbHelper.database;
          
          // Ensure Insights table exists
          await db.execute('''
            CREATE TABLE IF NOT EXISTS insights (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              insight_text TEXT,
              timestamp TEXT
            )
          ''');
          
          // Save the resulting text into a new 'Insights' table in the database
          await db.insert('insights', {
            'insight_text': insightText,
            'timestamp': DateTime.now().toIso8601String(),
          });
          
          // Update the analyzed entries to set analyzedForPatterns = 1
          for (var entry in entries) {
            final updatedEntry = DiaryEntry(
              id: entry.id,
              content: entry.content,
              timestamp: entry.timestamp,
              isEncrypted: entry.isEncrypted,
              analyzedForPatterns: true,
              entryType: entry.entryType,
              aiInsight: entry.aiInsight,
            );
            await dbHelper.updateEntry(updatedEntry);
          }
        }
      } catch (e) {
        // Handle error or simply return false
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}
