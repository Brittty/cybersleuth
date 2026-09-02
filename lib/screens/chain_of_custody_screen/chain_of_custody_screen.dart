import 'dart:async';
import 'package:cyber_sleuth/assets/contracts/contract_01.dart';
import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChainOfCustodyScreen extends ConsumerStatefulWidget {
  const ChainOfCustodyScreen({super.key});

  @override
  ConsumerState<ChainOfCustodyScreen> createState() =>
      _ChainOfCustodyScreenState();
}

class _ChainOfCustodyScreenState extends ConsumerState<ChainOfCustodyScreen> {
  bool _initialized = false;
  bool _isProcessing = false;
  double _progress = 0.0;
  String _processingLabel = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_initialized) {
        final contract = InsiderThreatContract();
        final disks = contract.caseData!.diskImages;
        ref.read(chainOfCustodyProvider.notifier).initializeWithDisks(disks);
        ref.read(investigationProvider.notifier).selectDisk(disks.first.diskId);
        _initialized = true;
      }
    });
  }

  Future<void> _simulateProcess(String label, Duration duration) async {
    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _processingLabel = label;
    });
    const steps = 20;
    final stepDuration = Duration(
        milliseconds: duration.inMilliseconds ~/ steps);
    for (int i = 0; i <= steps; i++) {
      await Future.delayed(stepDuration);
      if (mounted) {
        setState(() => _progress = i / steps);
      }
    }
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final custodyState = ref.watch(chainOfCustodyProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (custodyState.disks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.security, color: colorScheme.primary, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Chain of Custody',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Process incoming evidence and create forensic clones for investigation.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 24),

                // Step indicators
                _buildStepIndicators(custodyState, colorScheme),
                const SizedBox(height: 32),

                // Main content
                Expanded(
                  child: _buildStepContent(custodyState, colorScheme, theme),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicators(
      ChainOfCustodyState state, ColorScheme colorScheme) {
    final steps = [
      ('Sign Receipt', CustodyStep.receive),
      ('Compute Hashes', CustodyStep.computeHash),
      ('Verify Integrity', CustodyStep.verifyHash),
      ('Clone Drives', CustodyStep.cloneDrive),
      ('Verify Clones', CustodyStep.verifyClone),
    ];

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _stepChip(
            steps[i].$1,
            i,
            state.currentStep.index > steps[i].$2.index,
            state.currentStep == steps[i].$2,
            colorScheme,
          ),
          if (i < steps.length - 1)
            Expanded(
              child: Container(
                height: 2,
                color: state.currentStep.index > steps[i].$2.index
                    ? colorScheme.primary
                    : colorScheme.outline.withAlpha(60),
              ),
            ),
        ],
      ],
    );
  }

  Widget _stepChip(String label, int index, bool completed, bool active,
      ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: completed
                ? colorScheme.primary
                : active
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
            border: active
                ? Border.all(color: colorScheme.primary, width: 2)
                : null,
          ),
          child: Center(
            child: completed
                ? Icon(Icons.check, size: 18, color: colorScheme.onPrimary)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: active
                          ? colorScheme.primary
                          : colorScheme.onSurface.withAlpha(150),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: active
                ? colorScheme.primary
                : colorScheme.onSurface.withAlpha(150),
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(
      ChainOfCustodyState state, ColorScheme colorScheme, ThemeData theme) {
    switch (state.currentStep) {
      case CustodyStep.receive:
        return _buildReceiveStep(state, colorScheme, theme);
      case CustodyStep.computeHash:
        return _buildComputeHashStep(state, colorScheme, theme);
      case CustodyStep.verifyHash:
        return _buildVerifyHashStep(state, colorScheme, theme);
      case CustodyStep.cloneDrive:
        return _buildCloneStep(state, colorScheme, theme);
      case CustodyStep.verifyClone:
        return _buildVerifyCloneStep(state, colorScheme, theme);
      case CustodyStep.complete:
        return _buildCompleteStep(colorScheme, theme);
    }
  }

  Widget _buildDiskCard(DiskImage disk, ColorScheme colorScheme,
      {Widget? trailing, Widget? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(Icons.sd_storage, color: colorScheme.primary, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disk.diskId,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${disk.ownerName} — ${disk.ownerRole}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withAlpha(180),
                  ),
                ),
                if (subtitle != null) ...[const SizedBox(height: 4), subtitle],
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  // ── Step: Receive ──────────────────────────────────────────

  Widget _buildReceiveStep(
      ChainOfCustodyState state, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evidence Received',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'The following disk images have been delivered. Sign the receipt to begin processing.',
          style: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: state.disks
                .map((d) => _buildDiskCard(d, colorScheme,
                    trailing: Icon(Icons.verified_user_outlined,
                        color: colorScheme.outline.withAlpha(100))))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        _actionButton('Sign Chain of Custody Receipt', () {
          ref.read(chainOfCustodyProvider.notifier).signReceipt();
        }),
      ],
    );
  }

  // ── Step: Compute Hash ─────────────────────────────────────

  Widget _buildComputeHashStep(
      ChainOfCustodyState state, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compute SHA-256 Hashes',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Compute SHA-256 hashes of each original drive.',
          style: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
        ),
        const SizedBox(height: 24),
        if (_isProcessing) _buildProgressBar(colorScheme),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: state.disks.map((disk) {
              final hasHash = state.computedHashes.containsKey(disk.diskId);
              return _buildDiskCard(
                disk,
                colorScheme,
                subtitle: hasHash
                    ? SelectableText(
                        'SHA-256: ${state.computedHashes[disk.diskId]}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: colorScheme.primary,
                        ),
                      )
                    : null,
                trailing: hasHash
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : FilledButton.tonal(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                await _simulateProcess(
                                  'Computing SHA-256 for ${disk.diskId}...',
                                  const Duration(seconds: 2),
                                );
                                ref
                                    .read(chainOfCustodyProvider.notifier)
                                    .computeHash(
                                        disk.diskId, disk.originalHash);
                              },
                        child: const Text('Compute'),
                      ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (state.computedHashes.length == state.disks.length)
          _actionButton('Proceed to Verification', () {
            // Move all to verified state for simplicity
            for (final disk in state.disks) {
              ref.read(chainOfCustodyProvider.notifier).verifyHash(disk.diskId);
            }
          }),
      ],
    );
  }

  // ── Step: Verify Hash ──────────────────────────────────────

  Widget _buildVerifyHashStep(
      ChainOfCustodyState state, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Hash Integrity',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Compare computed hashes against the provided values.',
          style: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView(
            children: state.disks.map((disk) {
              final computed = state.computedHashes[disk.diskId] ?? '';
              final verified = state.hashVerified[disk.diskId] == true;
              return _buildDiskCard(
                disk,
                colorScheme,
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Computed:  $computed',
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: colorScheme.onSurface.withAlpha(180))),
                    Text('Provided:  ${disk.originalHash}',
                        style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: colorScheme.onSurface.withAlpha(180))),
                  ],
                ),
                trailing: verified
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text('MATCH',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ],
                        ),
                      )
                    : FilledButton.tonal(
                        onPressed: () {
                          ref
                              .read(chainOfCustodyProvider.notifier)
                              .verifyHash(disk.diskId);
                        },
                        child: const Text('Verify'),
                      ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Step: Clone ────────────────────────────────────────────

  Widget _buildCloneStep(
      ChainOfCustodyState state, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create Forensic Clones',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Create bit-for-bit clones of each drive using dd.',
          style: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
        ),
        const SizedBox(height: 24),
        if (_isProcessing) _buildProgressBar(colorScheme),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: state.disks.map((disk) {
              final cloned = state.cloneComplete[disk.diskId] == true;
              return _buildDiskCard(
                disk,
                colorScheme,
                subtitle: cloned
                    ? Text(
                        'dd if=/dev/evidence/${disk.diskId} of=/forensic/clone/${disk.diskId}.img bs=4M status=progress',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                          color: colorScheme.primary,
                        ),
                      )
                    : null,
                trailing: cloned
                    ? Icon(Icons.check_circle, color: colorScheme.primary)
                    : FilledButton.tonal(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                await _simulateProcess(
                                  'Cloning ${disk.diskId} (dd bs=4M)...',
                                  const Duration(seconds: 3),
                                );
                                ref
                                    .read(chainOfCustodyProvider.notifier)
                                    .completeDiskClone(disk.diskId);
                              },
                        child: const Text('Clone'),
                      ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Step: Verify Clone ─────────────────────────────────────

  Widget _buildVerifyCloneStep(
      ChainOfCustodyState state, ColorScheme colorScheme, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verify Clone Integrity',
          style: theme.textTheme.titleLarge
              ?.copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          'Hash each clone and confirm it matches the original drive hash.',
          style: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
        ),
        const SizedBox(height: 24),
        if (_isProcessing) _buildProgressBar(colorScheme),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: state.disks.map((disk) {
              final verified = state.cloneHashVerified[disk.diskId] == true;
              return _buildDiskCard(
                disk,
                colorScheme,
                subtitle: verified
                    ? Text(
                        'Clone hash matches original ✓',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
                trailing: verified
                    ? Icon(Icons.verified, color: colorScheme.primary)
                    : FilledButton.tonal(
                        onPressed: _isProcessing
                            ? null
                            : () async {
                                await _simulateProcess(
                                  'Verifying clone of ${disk.diskId}...',
                                  const Duration(seconds: 2),
                                );
                                ref
                                    .read(chainOfCustodyProvider.notifier)
                                    .verifyCloneHash(disk.diskId);
                              },
                        child: const Text('Verify Clone'),
                      ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Step: Complete ─────────────────────────────────────────

  Widget _buildCompleteStep(ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 72, color: colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Chain of Custody Complete',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Processing complete.\nYou may now proceed to investigation.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withAlpha(180)),
          ),
          const SizedBox(height: 32),
          _actionButton('Begin Investigation', () {
            ref
                .read(globalStateProvider.notifier)
                .setScreen(AppScreen.os);
          }),
        ],
      ),
    );
  }

  // ── Shared Widgets ─────────────────────────────────────────

  Widget _buildProgressBar(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _processingLabel,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(colorScheme.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(_progress * 100).toInt()}%',
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            color: colorScheme.onSurface.withAlpha(150),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.arrow_forward),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
