import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_providers.dart';
import '../providers/theme_provider.dart';
import 'write_entry_screen.dart'; // Assuming this screen will be created
import 'entry_detail_screen.dart';
import 'insights_screen.dart';
import 'chat_screen.dart';
import 'calendar_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(diaryEntriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligent Diary'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  isDark ? ThemeMode.light : ThemeMode.dark;
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text(
                'No entries yet. Start writing!',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];

                // Format the timestamp manually since intl package is not used
                final timestamp = entry.timestamp;
                final formattedDate =
                    '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')} '
                    '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntryDetailScreen(initialEntry: entry),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                      // Main Content Section
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  formattedDate,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                if (entry.isEncrypted)
                                  const Icon(
                                    Icons.lock_outline,
                                    size: 16.0,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12.0),
                            Text(
                              entry.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16.0,
                                height: 1.4,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // AI Contextual Question Section
                      if (entry.aiInsight != null && entry.aiInsight!.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2A302A) : const Color(0xFFEAECE8),
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 18.0,
                                color: isDark ? const Color(0xFFA3BCA3) : const Color(0xFF164F16),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Text(
                                  entry.aiInsight!,
                                  style: TextStyle(
                                    color: isDark ? const Color(0xFFA3BCA3) : const Color(0xFF164F16),
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const WriteEntryScreen(),
            ),
          );
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
