import 'package:flutter_riverpod/flutter_riverpod.dart';

final timerProvider = StreamProvider<int>((ref) {
  return Stream.periodic(const Duration(milliseconds: 500), (x) => x);
});
