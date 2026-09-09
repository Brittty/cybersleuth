import 'package:cyber_sleuth/models/os_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OsScreenState {
  final OsTool? activeTool;

  const OsScreenState({this.activeTool});

  OsScreenState copyWith({OsTool? activeTool}) {
    return OsScreenState(activeTool: activeTool);
  }
}

class OsScreenNotifier extends Notifier<OsScreenState> {
  @override
  OsScreenState build() {
    return const OsScreenState();
  }

  void setActiveTool(OsTool? tool) {
    state = OsScreenState(activeTool: tool);
  }
}

final osScreenProvider = NotifierProvider<OsScreenNotifier, OsScreenState>(() {
  return OsScreenNotifier();
});

/// The investigation tools available on the OS screen
const osToolsList = [
  OsTool(id: 1, name: 'File Explorer', iconData: Icons.folder_outlined),
  OsTool(id: 2, name: 'Hex Editor', iconData: Icons.data_array),
  OsTool(id: 3, name: 'Network\nAnalyzer', iconData: Icons.lan_outlined),
  OsTool(id: 4, name: 'Access\nLogs', iconData: Icons.history),
  OsTool(id: 5, name: 'Email\nViewer', iconData: Icons.email_outlined),
  OsTool(id: 6, name: 'Notepad', iconData: Icons.edit_note_rounded),
];
