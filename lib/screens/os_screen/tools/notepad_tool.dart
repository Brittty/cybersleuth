import 'package:cyber_sleuth/providers/notepad_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotepadTool extends ConsumerStatefulWidget {
  const NotepadTool({super.key, required this.caseId});

  final String caseId;

  @override
  ConsumerState<NotepadTool> createState() => _NotepadToolState();
}

class _NotepadToolState extends ConsumerState<NotepadTool> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(notepadProvider(widget.caseId)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: colors.primary, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Notepad',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Icon(
                Icons.favorite_border_rounded,
                size: 16,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9E8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE3D8B8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBC2C4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'Little notes, useful clues.',
                                style: TextStyle(
                                  color: Color(0xFF74644A),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFE3D8B8)),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
                          child: TextField(
                            key: const Key('notepad-editor'),
                            controller: _controller,
                            onChanged: (text) =>
                                ref
                                        .read(
                                          notepadProvider(widget.caseId)
                                              .notifier,
                                        )
                                        .state =
                                    text,
                            expands: true,
                            minLines: null,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textAlignVertical: TextAlignVertical.top,
                            cursorColor: const Color(0xFF187347),
                            style: const TextStyle(
                              color: Color(0xFF3E392F),
                              fontSize: 15,
                              height: 1.8,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Names, timestamps, a theory to check…',
                              hintStyle: TextStyle(color: Color(0xFF786B55)),
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Notes stay with this case until the app closes.',
            style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
