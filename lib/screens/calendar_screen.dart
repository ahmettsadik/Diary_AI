import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/diary_providers.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(diaryEntriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dayEntries = allEntries.where((e) {
      if (_selectedDay == null) return false;
      return isSameDay(e.timestamp, _selectedDay);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_calendar),
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: _focusedDay,
                firstDate: DateTime.utc(2000, 1, 1),
                lastDate: DateTime.utc(2100, 12, 31),
              );

              if (selectedDate != null) {
                if (!mounted) return;
                setState(() {
                  _focusedDay = selectedDate;
                  _selectedDay = selectedDate;
                });
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          if (dayEntries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No entries for this day.',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: dayEntries.length,
                    itemBuilder: (context, index) {
                      final entry = dayEntries[index];
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                            if (entry.aiInsight != null &&
                                entry.aiInsight!.isNotEmpty)
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
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
                              ).animate().fade(duration: 500.ms).slideY(
                                  begin: 0.1, end: 0),
                          ],
                        ),
                      );
                    },
                  ),
        ],
      ),
    );
  }
}
