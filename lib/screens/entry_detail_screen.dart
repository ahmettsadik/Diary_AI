import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diary_entry.dart';
import '../providers/diary_providers.dart';

class EntryDetailScreen extends ConsumerWidget {
  final DiaryEntry initialEntry;

  const EntryDetailScreen({super.key, required this.initialEntry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for the latest version of this entry in case it gets updated (e.g., AI insight completes)
    final entries = ref.watch(diaryEntriesProvider);
    final entry = entries.firstWhere((e) => e.id == initialEntry.id, orElse: () => initialEntry);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timestamp = entry.timestamp;
    final formattedDate =
        '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Entry'),
        actions: [
          if (entry.isEncrypted)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(Icons.lock, color: Colors.green),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formattedDate,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            if (entry.who != null && entry.who!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('With: ${entry.who}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (entry.where != null && entry.where!.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('At: ${entry.where}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if ((entry.who != null && entry.who!.isNotEmpty) || (entry.where != null && entry.where!.isNotEmpty))
              const Divider(height: 32),
            Text(
              entry.content,
              style: TextStyle(
                fontSize: 18.0, 
                height: 1.5,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 32),
            if (entry.aiInsight != null && entry.aiInsight!.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A302A) : const Color(0xFFEAECE8),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 24.0,
                      color: isDark ? const Color(0xFFA3BCA3) : const Color(0xFF164F16),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Text(
                        entry.aiInsight!,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFA3BCA3) : const Color(0xFF164F16),
                          fontStyle: FontStyle.italic,
                          fontSize: 16.0,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
