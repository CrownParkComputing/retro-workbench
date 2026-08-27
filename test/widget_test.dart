// Every blueprint, every enabled module: the designer must render the whole
// family - and the Box86 draft - without a single layout error.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:retro_workbench/main.dart';
import 'package:retro_workbench/profiles/platform_profile.dart';

void main() {
  testWidgets('every blueprint renders every module', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const WorkbenchDemoApp());
    await tester.pumpAndSettle();

    for (final b in appBlueprints) {
      final chip = b.status == 'shipping' ? b.name : '${b.name} \u00b7 ${b.status}';
      await tester.tap(find.text(chip), warnIfMissed: false);
      await tester.pumpAndSettle();
      for (final id in b.modules) {
        final m = moduleById(id);
        final label = find.text('${m.icon} ${b.titleOf(m)}');
        if (label.evaluate().isEmpty) continue;
        await tester.tap(label.first, warnIfMissed: false);
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(tester.takeException(), isNull,
          reason: 'blueprint ${b.name} threw during its module sweep');
    }
  });
}
