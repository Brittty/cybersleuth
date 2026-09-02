import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmailViewerTool extends ConsumerStatefulWidget {
  final List<EmailRecord> emails;
  final String diskId;

  const EmailViewerTool({
    super.key,
    required this.emails,
    required this.diskId,
  });

  @override
  ConsumerState<EmailViewerTool> createState() => _EmailViewerToolState();
}

class _EmailViewerToolState extends ConsumerState<EmailViewerTool> {
  EmailRecord? _selectedEmail;
  bool _showRawHeaders = false;

  @override
  void didUpdateWidget(EmailViewerTool oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.diskId != widget.diskId) {
      setState(() {
        _selectedEmail = null;
        _showRawHeaders = false;
      });
    }
  }

  bool _isExternalRecipient(String email) {
    return !email.endsWith('@novatech.com');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final investigationState = ref.watch(investigationProvider);

    return Row(
      children: [
        // Email list panel
        SizedBox(
          width: 340,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: colorScheme.outline.withAlpha(40)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.email_outlined,
                          color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Inbox',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.emails.length} messages',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colorScheme.outline.withAlpha(40)),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.emails.length,
                    itemBuilder: (context, index) {
                      final email = widget.emails[index];
                      final isSelected = _selectedEmail?.id == email.id;
                      final isMarked = investigationState.isMarked(email.id);
                      final hasExternalRecipient =
                          _isExternalRecipient(email.to);

                      return InkWell(
                        onTap: () => setState(() {
                          _selectedEmail = email;
                          _showRawHeaders = false;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withAlpha(20)
                                : Colors.transparent,
                            border: Border(
                              bottom: BorderSide(
                                  color: colorScheme.outline.withAlpha(20)),
                              left: isMarked
                                  ? BorderSide(
                                      color: colorScheme.primary, width: 3)
                                  : BorderSide.none,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      email.from.split('@')[0],
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: colorScheme.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    email.timestamp.split(' ')[0],
                                    style: TextStyle(
                                      fontSize: 10,
                                      color:
                                          colorScheme.onSurface.withAlpha(120),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                email.subject,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withAlpha(200),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (hasExternalRecipient)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 1),
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: colorScheme.error.withAlpha(30),
                                        borderRadius:
                                            BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        'EXTERNAL',
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.error,
                                        ),
                                      ),
                                    ),
                                  if (email.attachments.isNotEmpty)
                                    Icon(Icons.attach_file,
                                        size: 12,
                                        color: colorScheme.onSurface
                                            .withAlpha(120)),
                                  if (email.attachments.isNotEmpty)
                                    Text(
                                      ' ${email.attachments.length}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: colorScheme.onSurface
                                            .withAlpha(120),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Email detail panel
        Expanded(
          child: _selectedEmail == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email_outlined,
                          size: 48,
                          color: colorScheme.onSurface.withAlpha(60)),
                      const SizedBox(height: 12),
                      Text(
                        'Select an email to view',
                        style: TextStyle(
                          color: colorScheme.onSurface.withAlpha(100),
                        ),
                      ),
                    ],
                  ),
                )
              : _buildEmailDetail(
                  _selectedEmail!, colorScheme, investigationState),
        ),
      ],
    );
  }

  Widget _buildEmailDetail(
      EmailRecord email, ColorScheme colorScheme, InvestigationState investigationState) {
    final isMarked = investigationState.isMarked(email.id);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject & evidence button
          Row(
            children: [
              Expanded(
                child: Text(
                  email.subject,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              FilledButton.icon(
                onPressed: () {
                  ref.read(investigationProvider.notifier).toggleEvidence(
                        MarkedEvidence(
                          id: email.id,
                          diskId: widget.diskId,
                          category: 'email',
                          title: 'Email: "${email.subject}"',
                          description:
                              'From: ${email.from} → To: ${email.to}\n${email.attachments.isNotEmpty ? "Attachments: ${email.attachments.join(", ")}" : "No attachments"}',
                        ),
                      );
                },
                icon: Icon(
                    isMarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 18),
                label: Text(isMarked ? 'Marked' : 'Mark Evidence'),
                style: FilledButton.styleFrom(
                  backgroundColor: isMarked
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  foregroundColor:
                      isMarked ? colorScheme.onPrimary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // From / To / Date
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _emailFieldRow('From', email.from, colorScheme),
                _emailFieldRow('To', email.to, colorScheme,
                    highlight: _isExternalRecipient(email.to)),
                _emailFieldRow('Date', email.timestamp, colorScheme),
                if (email.attachments.isNotEmpty)
                  _emailFieldRow(
                      'Attachments', email.attachments.join(', '), colorScheme,
                      highlight: true),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Raw headers toggle
          InkWell(
            onTap: () => setState(() => _showRawHeaders = !_showRawHeaders),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    _showRawHeaders
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _showRawHeaders
                        ? 'Hide Raw Headers'
                        : 'View Raw Headers',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Raw headers
          if (_showRawHeaders)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                email.headers.entries
                    .map((e) => '${e.key}: ${e.value}')
                    .join('\n'),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFFE6EDF3),
                  height: 1.5,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Body
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  email.body.isEmpty ? '(No body content)' : email.body,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emailFieldRow(String label, String value, ColorScheme colorScheme,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withAlpha(150),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: highlight
                    ? colorScheme.error
                    : colorScheme.onSurface,
                fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
