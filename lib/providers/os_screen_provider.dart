import 'package:cyber_sleuth/models/os_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OsScreenState {
  final OsTool? activeTool;

  const OsScreenState({
    this.activeTool,
  });

  OsScreenState copyWith({
    OsTool? activeTool,
  }) {
    return OsScreenState(
      // Allow setting to null if needed, though copyWith typically only overrides if non-null.
      // To properly handle nullable updates in copyWith, we can do:
      activeTool: activeTool,
    );
  }
}

class OsScreenNotifier extends Notifier<OsScreenState> {
  @override
  OsScreenState build() {
    return const OsScreenState();
  }

  void setActiveTool(OsTool? tool) {
    // If we want to allow setting to null, we'd need to create a new state
    // directly instead of relying solely on the simple copyWith, but we can 
    // just pass it to the constructor.
    state = OsScreenState(
      activeTool: tool,
    );
  }
}

final osScreenProvider = NotifierProvider<OsScreenNotifier, OsScreenState>(() {
  return OsScreenNotifier();
});

