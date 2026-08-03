import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_providers.dart';
import '../database/database_helper.dart';
import '../services/llm_service.dart';
import '../models/diary_entry.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(insightsProvider.notifier).loadInsights());
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(insightsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Patterns'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final dbHelper = DatabaseHelper();
          final llmService = LLMService();

          final entries = await dbHelper.getEntriesForAnalysis();
          if (entries.isEmpty) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No entries to analyze')),
              );
            }
            return;
          }

          final insightText = await llmService.generateWeeklyInsights(entries);
          if (insightText != null && insightText.isNotEmpty) {
            await dbHelper.insertInsight(insightText);

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

            if (context.mounted) {
              ref.read(insightsProvider.notifier).loadInsights();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Insight generated manually')),
              );
            }
          }
        },
        tooltip: 'Generate Insight',
        child: const Icon(Icons.analytics),
      ),
      body: insights.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'Keep journaling. Your first weekly pattern insight will appear here soon.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: insights.length,
              itemBuilder: (context, index) {
                final insight = insights[index];
                final dateStr = insight['date_generated'] ?? '';
                final content = insight['content'] ?? '';

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.blueAccent),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(dateStr),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          content,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
