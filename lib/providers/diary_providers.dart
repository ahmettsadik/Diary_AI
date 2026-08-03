import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_entry.dart';
import '../database/database_helper.dart';
import '../services/llm_service.dart';

final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

final llmServiceProvider = Provider<LLMService>((ref) {
  return LLMService();
});

class DiaryEntriesNotifier extends StateNotifier<List<DiaryEntry>> {
  final DatabaseHelper _dbHelper;
  final LLMService _llmService;

  DiaryEntriesNotifier(this._dbHelper, this._llmService) : super([]) {
    loadEntries();
  }

  Future<void> loadEntries() async {
    state = await _dbHelper.getAllEntries();
  }

  Future<void> addEntryAndGetInsight(String content, bool isEncrypted, {String? who, String? where}) async {
    // 1. Create a new DiaryEntry
    var newEntry = DiaryEntry(
      content: content,
      timestamp: DateTime.now(),
      isEncrypted: isEncrypted,
      who: who,
      where: where,
    );

    // 2. Insert it into the database via the database helper.
    final id = await _dbHelper.insertEntry(newEntry);
    
    // Create an updated instance with the assigned ID so we can update it later
    newEntry = DiaryEntry(
      id: id,
      content: newEntry.content,
      timestamp: newEntry.timestamp,
      isEncrypted: newEntry.isEncrypted,
      analyzedForPatterns: newEntry.analyzedForPatterns,
      entryType: newEntry.entryType,
      aiInsight: newEntry.aiInsight,
      who: newEntry.who,
      where: newEntry.where,
    );

    // 3. Update the state list so the UI reflects the new entry immediately.
    // Assuming a descending order (newest first) since getAllEntries uses timestamp DESC
    state = [newEntry, ...state];

    // 4. If isEncrypted is false, call generateContextualQuestion from the LLM service.
    if (!isEncrypted) {
      final insight = await _llmService.generateContextualQuestion(newEntry);
      
      // 5. When the LLM returns a question, update the specific entry in the database with this new insight
      if (insight != null) {
        final updatedEntry = DiaryEntry(
          id: newEntry.id,
          content: newEntry.content,
          timestamp: newEntry.timestamp,
          isEncrypted: newEntry.isEncrypted,
          analyzedForPatterns: newEntry.analyzedForPatterns,
          entryType: newEntry.entryType,
          aiInsight: insight, // Storing the AI's question/insight here
          who: newEntry.who,
          where: newEntry.where,
        );
        
        await _dbHelper.updateEntry(updatedEntry);
        
        // Update the state again so the UI shows the AI's response
        state = [
          for (final entry in state)
            if (entry.id == updatedEntry.id) updatedEntry else entry
        ];
      }
    }
  }
}

final diaryEntriesProvider = StateNotifierProvider<DiaryEntriesNotifier, List<DiaryEntry>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  final llmService = ref.watch(llmServiceProvider);
  return DiaryEntriesNotifier(dbHelper, llmService);
});

class ChatMessage {
  final String role; // 'user', 'ai', or 'loading'
  final String text;

  ChatMessage({required this.role, required this.text});
}

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  final DatabaseHelper _dbHelper;
  final LLMService _llmService;

  ChatNotifier(this._dbHelper, this._llmService) : super([]);

  Future<void> sendMessage(String question) async {
    // Add the user's question to the state.
    state = [...state, ChatMessage(role: 'user', text: question)];
    
    // Add a temporary loading message to the state
    state = [...state, ChatMessage(role: 'loading', text: '')];

    // Call DatabaseHelper to search for entries matching the question.
    final retrievedEntries = await _dbHelper.searchUnencryptedEntries(question);

    // Call LLMService.chatWithPast with the question and the retrieved entries.
    final responseText = await _llmService.chatWithPast(question, retrievedEntries);

    // Remove the loading message and add the AI's response to the state.
    final filteredState = state.where((msg) => msg.role != 'loading').toList();
    state = [
      ...filteredState,
      ChatMessage(role: 'ai', text: responseText ?? "Sorry, I encountered an error while thinking.")
    ];
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  final llmService = ref.watch(llmServiceProvider);
  return ChatNotifier(dbHelper, llmService);
});

class InsightsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final DatabaseHelper _dbHelper;

  InsightsNotifier(this._dbHelper) : super([]) {
    loadInsights();
  }

  Future<void> loadInsights() async {
    state = await _dbHelper.getInsights();
  }
}

final insightsProvider = StateNotifierProvider<InsightsNotifier, List<Map<String, dynamic>>>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return InsightsNotifier(dbHelper);
});
