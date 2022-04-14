import 'dart:ui' as ui;

import 'package:alchemist/src/pumps.dart';
import 'package:alchemist/src/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alchemist/src/golden_test_adapter.dart';

class MyGoldenTestAdapter extends GoldenTestAdapter {
  /// Create a new [MyGoldenTestAdapter].
  const MyGoldenTestAdapter() : super();

  /// Key for the root of the golden test.
  static final rootKey = UniqueKey();

  /// Key for the child container in the golden test.
  static final childKey = UniqueKey();

  @override
  Future<T> withForceUpdateGoldenFiles<T>({
    bool forceUpdate = false,
    required MatchesGoldenFileInvocation<T> callback,
  }) async {
    if (!forceUpdate) {
      return await callback();
    }

    final originalValue = autoUpdateGoldenFiles;
    autoUpdateGoldenFiles = true;
    try {
      return await callback();
    } finally {
      autoUpdateGoldenFiles = originalValue;
    }
  }

  @override
  TestLifecycleFn get setUp => setUpFn;
  @override
  TestLifecycleFn get tearDown => tearDownFn;
  @override
  TestWidgetsFn get testWidgets => testWidgetsFn;
  @override
  GoldenFileExpectation get goldenFileExpectation => goldenFileExpectationFn;

  @override
  Future<void> pumpGoldenTest({
    Key? rootKey,
    required WidgetTester tester,
    required double textScaleFactor,
    required BoxConstraints constraints,
    required ThemeData theme,
    required Widget widget,
    required PumpAction pumpBeforeTest,
    required PumpWidget pumpWidget,
  }) async {
    final initialSize = Size(
      constraints.hasBoundedWidth ? constraints.maxWidth : 2000,
      constraints.hasBoundedHeight ? constraints.maxHeight : 2000,
    );
    await tester.binding.setSurfaceSize(initialSize);
    tester.binding.window.physicalSizeTestValue = initialSize;

    tester.binding.window.devicePixelRatioTestValue = 1.0;
    tester.binding.window.textScaleFactorTestValue = textScaleFactor;

    await pumpWidget(
      tester,
      MaterialApp(
        key: rootKey,
        theme: theme.stripTextPackages(),
        debugShowCheckedModeBanner: false,
        supportedLocales: const [Locale('en')],

        /// My Changes:
        home: DefaultAssetBundle(
          bundle: TestAssetBundle(),
          child: Material(
            type: MaterialType.transparency,
            child: Align(
              alignment: Alignment.topLeft,
              child: ColoredBox(
                color: theme.colorScheme.background,
                child: Padding(
                  key: childKey,
                  padding: const EdgeInsets.all(8),
                  child: widget,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final shouldTryResize = !constraints.isTight;

    await pumpBeforeTest(tester);

    if (shouldTryResize) {
      final childSize = tester.getSize(find.byKey(childKey));
      final newSize = Size(
        childSize.width.clamp(constraints.minWidth, constraints.maxWidth),
        childSize.height.clamp(constraints.minHeight, constraints.maxHeight),
      );
      if (newSize != initialSize) {
        await tester.binding.setSurfaceSize(newSize);
        tester.binding.window.physicalSizeTestValue = newSize;
      }
    }

    await tester.pump();
  }

  @override
  Future<ui.Image> getBlockedTextImage({
    required Finder finder,
    required WidgetTester tester,
  }) async {
    var renderObject = tester.renderObject(finder);
    while (!renderObject.isRepaintBoundary) {
      renderObject = renderObject.parent! as RenderObject;
    }
    final layer = renderObject.debugLayer! as OffsetLayer;
    paintingContextBuilder(
      layer,
      renderObject.paintBounds,
    ).paintSingleChild(renderObject);

    return layer.toImage(renderObject.paintBounds);
  }
}
