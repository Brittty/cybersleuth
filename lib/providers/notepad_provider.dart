import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Scratch notes are kept separately for each case during the app session.
final notepadProvider = StateProvider.family<String, String>(
  (ref, caseId) => '',
);
