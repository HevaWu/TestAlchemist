import 'package:alchemist/alchemist.dart';
import 'package:test_alchemist/main.dart';

void main() {
  goldenTest(
    'Golden Test',
    fileName: 'golden',
    pumpBeforeTest: precacheImages,
    builder: () => GoldenTestGroup(
      children: [
        GoldenTestScenario(
          name: 'normal',
          child: const IconWithText(),
        ),
      ],
    ),
  );
}
