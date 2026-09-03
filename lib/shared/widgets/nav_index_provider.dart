import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Index of the active destination (Home, Collections, Search, Settings)
/// shared across bottom nav / rail / sidebar so screens (e.g. the Home
/// search field) can programmatically switch tabs.
final navIndexProvider = StateProvider<int>((ref) => 0);
