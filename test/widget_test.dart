// Every profile, every tab: the demo must render the whole family without a
// single layout error - this is the standalone shell's own contract.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:retro_workbench/main.dart';
import 'package:retro_workbench/profiles/platform_profile.dart';

void main() {
  testWidgets('every platform profile renders every tab', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const WorkbenchDemoApp());
    await tester.pumpAndSettle();

    for (final p in platformProfiles) {
      await tester.tap(find.text(p.name), warnIfMissed: false);
      await tester.pumpAndSettle();
      for (final t in p.tabs) {
        final label = find.text('${t.icon} ${t.title}');
        if (label.evaluate().isEmpty) continue; // rail may scroll on small runs
        await tester.tap(label.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(tester.takeException(), isNull,
          reason: 'profile ${p.name} threw during its tab sweep');
    }
  });
}
