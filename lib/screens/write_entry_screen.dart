import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/diary_providers.dart';

class WriteEntryScreen extends ConsumerStatefulWidget {
  const WriteEntryScreen({super.key});

  @override
  ConsumerState<WriteEntryScreen> createState() => _WriteEntryScreenState();
}

class _WriteEntryScreenState extends ConsumerState<WriteEntryScreen> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _whoController = TextEditingController();
  final TextEditingController _whereController = TextEditingController();
  bool _isEncrypted = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _contentController.dispose();
    _whoController.dispose();
    _whereController.dispose();
    super.dispose();
  }

  void _saveEntry() async {
    final text = _contentController.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _isSaving = true;
    });

    await ref
        .read(diaryEntriesProvider.notifier)
        .addEntryAndGetInsight(
          text,
          _isEncrypted,
          who: _whoController.text.trim().isEmpty ? null : _whoController.text.trim(),
          where: _whereController.text.trim().isEmpty ? null : _whereController.text.trim(),
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              _isEncrypted ? Icons.lock : Icons.lock_open,
              color: _isEncrypted ? Colors.green : Colors.grey,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isEncrypted = !_isEncrypted;
              });
            },
          ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveEntry,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _whoController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person),
                      hintText: 'Who was there?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _whereController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.location_on),
                      hintText: 'Where are you?',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Write your thoughts here...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
