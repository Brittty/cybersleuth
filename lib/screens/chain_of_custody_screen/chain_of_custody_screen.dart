import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChainOfCustodyScreen extends ConsumerStatefulWidget {
  const ChainOfCustodyScreen({super.key});

  @override
  ConsumerState<ChainOfCustodyScreen> createState() =>
      _ChainOfCustodyScreenState();
}

class _ChainOfCustodyScreenState extends ConsumerState<ChainOfCustodyScreen> {
  final _examiner = TextEditingController();
  bool _processing = false;
  String _feedback = '';

  ChainOfCustodyNotifier get _custody =>
      ref.read(chainOfCustodyProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final disks = ref.read(activeContractProvider).caseData!.diskImages;
      _custody.initializeWithDisks(disks);
      ref.read(investigationProvider.notifier).selectDisk(disks.first.diskId);
    });
  }

  @override
  void dispose() {
    _examiner.dispose();
    super.dispose();
  }

  void _tell(String message) => setState(() => _feedback = message);

  Future<void> _run(String label, bool Function() action) async {
    setState(() {
      _processing = true;
      _feedback = label;
    });
    // Short simulation keeps the exercise usable in a classroom demonstration.
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    final success = action();
    setState(() {
      _processing = false;
      _feedback = success
          ? 'Recorded in the custody log.'
          : 'Check the prerequisites before continuing.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chainOfCustodyProvider);
    if (state.disks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final theme = Theme.of(context);
    const labels = [
      'Receive',
      'Hash originals',
      'Compare hashes',
      'Create clones',
      'Compare clones',
      'Ready',
    ];
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text('Chain of Custody', style: theme.textTheme.headlineMedium),
                if (kDebugMode)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('debug-skip-custody'),
                      onPressed: _processing
                          ? null
                          : () {
                              if (!kDebugMode) return;
                              ref
                                  .read(globalStateProvider.notifier)
                                  .setScreen(AppScreen.os);
                            },
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Skip custody (debug)'),
                    ),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Training simulation. Preserve the originals and examine verified working copies.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < labels.length; i++)
                      Chip(
                        avatar: Icon(
                          i < state.currentStep.index
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 18,
                        ),
                        label: Text('${i + 1}. ${labels[i]}'),
                        backgroundColor: i == state.currentStep.index
                            ? theme.colorScheme.primaryContainer
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_processing) const LinearProgressIndicator(),
                if (_feedback.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _feedback,
                      key: const Key('custody-feedback'),
                      semanticsLabel: _feedback,
                    ),
                  ),
                ..._stepContent(state),
                const SizedBox(height: 24),
                ExpansionTile(
                  key: const PageStorageKey('custody-log'),
                  title: Text(
                    'Custody activity log (${state.activityLog.length})',
                  ),
                  subtitle: Text(
                    state.examiner.isEmpty
                        ? 'Actions appear here as you work.'
                        : 'Examiner: ${state.examiner}',
                  ),
                  children: [
                    for (var i = 0; i < state.activityLog.length; i++)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.history, size: 18),
                        title: SelectableText(
                          state.activityLog[i],
                          // Keep text scroll offsets separate from the tile's
                          // persisted expanded/collapsed state.
                          key: PageStorageKey('custody-log-entry-$i'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _heading(String title, String explanation) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(explanation),
      ],
    ),
  );

  Widget _disk(DiskImage disk, List<Widget> children) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            disk.diskId,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Text('${disk.ownerName} (${disk.ownerRole})'),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    ),
  );

  Widget _button(String label, String key, VoidCallback? action) =>
      FilledButton.tonal(
        key: Key(key),
        onPressed: _processing ? null : action,
        child: Text(label),
      );

  List<Widget> _comparison(
    DiskImage disk,
    ChainOfCustodyState state, {
    required bool clone,
  }) {
    final verified =
        (clone ? state.cloneHashVerified : state.hashVerified)[disk.diskId] ==
        true;
    return [
      SelectableText(
        'Reference: ${clone ? state.computedHashes[disk.diskId] : disk.originalHash}',
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
      const SizedBox(height: 8),
      SelectableText(
        'Computed:  ${clone ? state.cloneHashes[disk.diskId] : state.computedHashes[disk.diskId]}',
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
      ),
      const SizedBox(height: 12),
      if (verified)
        const Text('✓ Match confirmed')
      else if (clone && state.rejectedClones.contains(disk.diskId)) ...[
        const Text(
          'Clone quarantined. Create a fresh working copy from the protected original.',
        ),
        _button(
          'Re-image safely',
          'retry-${disk.diskId}',
          () => _run(
            'Creating replacement image…',
            () => _custody.completeDiskClone(disk.diskId),
          ),
        ),
      ] else
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final matches in [true, false])
              _button(
                matches ? 'Hashes match' : 'Hashes differ',
                '${clone ? 'clone' : 'original'}-${disk.diskId}-$matches',
                () {
                  final correct = clone
                      ? _custody.verifyCloneHash(disk.diskId, matches: matches)
                      : _custody.verifyHash(disk.diskId, matches: matches);
                  _tell(
                    correct
                        ? (matches
                              ? 'Correct. Integrity verified.'
                              : 'Correct. Reject this clone and re-image it safely.')
                        : 'Look closely: compare every character in both hashes. Nothing has been approved.',
                  );
                },
              ),
          ],
        ),
    ];
  }

  List<Widget> _stepContent(ChainOfCustodyState state) {
    switch (state.currentStep) {
      case CustodyStep.receive:
        return [
          _heading(
            'Check the evidence intake',
            'Match each disk label to the manifest and inspect its seal before signing. All packages in this simulation arrived sealed.',
          ),
          TextField(
            controller: _examiner,
            decoration: const InputDecoration(
              labelText: 'Examiner name',
              hintText: 'Enter your name',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          for (final disk in state.disks)
            _disk(disk, [
              Text(
                'Manifest: ${disk.diskId}\nPackage label: ${disk.diskId}\nSeal: intact',
              ),
              CheckboxListTile(
                key: Key('inspect-${disk.diskId}'),
                contentPadding: EdgeInsets.zero,
                title: const Text('I checked the label and intact seal'),
                value: state.inspectedDisks.contains(disk.diskId),
                onChanged: (value) =>
                    _custody.inspectDisk(disk.diskId, value ?? false),
              ),
            ]),
          _button(
            'Sign Chain of Custody Receipt',
            'sign-receipt',
            _examiner.text.trim().isNotEmpty &&
                    state.inspectedDisks.length == state.disks.length
                ? () {
                    _custody.signReceipt(examiner: _examiner.text);
                    _tell(
                      'Receipt signed. Now establish the integrity of each original.',
                    );
                  }
                : null,
          ),
        ];
      case CustodyStep.computeHash:
        return [
          _heading(
            'Compute original hashes',
            'A hash is a fingerprint of the disk contents. Compute each value, then compare it with the intake manifest. Hashing here is simulated using the case fixtures.',
          ),
          for (final disk in state.disks)
            _disk(disk, [
              if (state.computedHashes.containsKey(disk.diskId))
                SelectableText('Computed: ${state.computedHashes[disk.diskId]}')
              else
                _button(
                  'Compute hash',
                  'compute-${disk.diskId}',
                  () => _run(
                    'Computing original hash…',
                    () => _custody.computeHash(disk.diskId, disk.originalHash),
                  ),
                ),
            ]),
          _button(
            'Proceed to Verification',
            'begin-verification',
            state.computedHashes.length == state.disks.length
                ? () {
                    _custody.beginVerification();
                    _tell(
                      'Compare the reference and computed values for each disk.',
                    );
                  }
                : null,
          ),
        ];
      case CustodyStep.verifyHash:
        return [
          _heading(
            'Verify original integrity',
            'Compare every character. A mismatch means you must stop and request a new acquisition; a matching hash means the image agrees with the manifest.',
          ),
          for (final disk in state.disks)
            _disk(disk, _comparison(disk, state, clone: false)),
        ];
      case CustodyStep.cloneDrive:
        return [
          _heading(
            'Protect originals and create working copies',
            'Enable the write blocker before imaging. It prevents accidental changes to source evidence. A copy may contain errors. Verify each clone before analysis.',
          ),
          SwitchListTile(
            key: const Key('write-blocker'),
            title: const Text('Enable write blocker'),
            subtitle: const Text(
              'Keep source evidence read-only during acquisition.',
            ),
            value: state.writeBlockerEnabled,
            onChanged: _processing ? null : _custody.enableWriteBlocker,
          ),
          for (final disk in state.disks)
            _disk(disk, [
              Text('Source: ${disk.diskId} → Working copy: ${disk.diskId}.img'),
              if (state.cloneComplete[disk.diskId] == true)
                const Text('✓ Working copy created')
              else
                _button(
                  'Create clone',
                  'copy-${disk.diskId}',
                  state.writeBlockerEnabled
                      ? () => _run(
                          'Creating working copy…',
                          () => _custody.completeDiskClone(disk.diskId),
                        )
                      : null,
                ),
            ]),
        ];
      case CustodyStep.verifyClone:
        return [
          _heading(
            'Verify working copies',
            'These are the simulated post-copy hash results. Compare them with the originals. Reject and re-image any damaged copy; correcting an error preserves your custody bonus.',
          ),
          for (final disk in state.disks)
            _disk(disk, _comparison(disk, state, clone: true)),
        ];
      case CustodyStep.complete:
        return [
          _heading(
            'Chain of Custody Complete',
            'All ${state.disks.length} working copies match their originals. ${state.examiner} has completed the intake and integrity checks.',
          ),
          const Text(
            'Originals retained as evidence. Verified copies released for analysis.',
          ),
          const SizedBox(height: 16),
          _button(
            'Begin Investigation',
            'begin-investigation',
            () =>
                ref.read(globalStateProvider.notifier).setScreen(AppScreen.os),
          ),
        ];
    }
  }
}
