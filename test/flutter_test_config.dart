import 'dart:async';

import 'my_golden_test_adapter.dart';
import 'package:alchemist/src/golden_test_runner.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  goldenTestAdapter = const MyGoldenTestAdapter();
  return testMain();
}
