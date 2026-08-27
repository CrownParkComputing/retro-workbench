// The workbench shell, running on its own: the family's canonical sidebar
// vocabulary down the left, the shared media-card grid in the panel, and a
// movable-control playground - so GUI changes are designed HERE, seen
// running, then copied verbatim into the apps.
import 'package:flutter/material.dart';

import 'theme/workbench_theme.dart';
import 'widgets/media_card.dart';
import 'widgets/movable_control.dart';
import 'widgets/sidebar.dart';
import 'widgets/sidebar_style.dart';

void main() => runApp(const WorkbenchDemoApp());

/// The family's canonical rail, one entry per job, in the canonical order.
/// Band 0 = what you play, band 1 = how the machine is set up, band 2 = the
/// reference-y things pinned to the bottom.
enum DemoTab {
  games('\u{1F3AE}', 'Games', 0),
  resume('\u{1F680}', 'Resume', 0),
  states('\u{1F4BE}', 'States', 0),
  video('\u{1F4FA}', 'Video', 1),
  input('\u{1F579}\u{FE0F}', 'Input', 1),
  core('\u{2699}\u{FE0F}', 'Core', 1),
  paths('\u{1F4C2}', 'Paths', 1),
  compliance('\u{2705}', 'Compliance', 2),
  about('\u{2139}\u{FE0F}', 'About', 2);

  final String icon;
  final String title;
  final int group;
  const DemoTab(this.icon, this.title, this.group);
}

class WorkbenchDemoApp extends StatelessWidget {
  const WorkbenchDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'retro-workbench',
      debugShowCheckedModeBanner: false,
      // No global fontFamily on purpose: the sidebar measures its own labels,
      // and a global override renders text wider than the measurement.
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const WorkbenchDemoScreen(),
    );
  }
}

class WorkbenchDemoScreen extends StatefulWidget {
  const WorkbenchDemoScreen({super.key});

  @override
  State<WorkbenchDemoScreen> createState() => _WorkbenchDemoScreenState();
}

class _WorkbenchDemoScreenState extends State<WorkbenchDemoScreen> {
  DemoTab _tab = DemoTab.games;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkbenchColors.rootBackground,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: WorkbenchMetrics.sidebarMaxWidth(
                      MediaQuery.sizeOf(context).width),
                ),
                child: Sidebar(
                  destinations: [
                    for (final t in DemoTab.values)
                      SidebarDestination('${t.icon} ${t.title}',
                          group: t.group),
                  ],
                  selectedIndex: DemoTab.values.indexOf(_tab),
                  onSelected: (i) =>
                      setState(() => _tab = DemoTab.values[i]),
                  style: workbenchSidebarStyle,
                  pinLastGroupToBottom: true,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                child: _panel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel() {
    switch (_tab) {
      case DemoTab.games:
        return _libraryPanel();
      case DemoTab.input:
        return _padPlayground();
      default:
        return _placeholder();
    }
  }

  Widget _libraryPanel() {
    const samples = [
      ('Turrican II', 'disk'),
      ('Lotus Esprit Turbo Challenge', 'disk'),
      ('Speedball 2', 'disk'),
      ('The Chaos Engine', 'cd'),
      ('SWIV', 'disk'),
      ('Stunt Car Racer', 'tape'),
    ];
    return LayoutBuilder(builder: (context, box) {
      final columns =
          (box.maxWidth / WorkbenchMetrics.mediaCardCell).floor().clamp(1, 12);
      return GridView.count(
        crossAxisCount: columns,
        childAspectRatio:
            WorkbenchMetrics.mediaCardWidth / WorkbenchMetrics.mediaCardHeight,
        children: [
          for (final (title, kind) in samples)
            Padding(
              padding: const EdgeInsets.all(6),
              child: MediaCard(
                title: title,
                kindLabel: kind,
                onTap: () {},
              ),
            ),
        ],
      );
    });
  }

  Widget _padPlayground() {
    return Stack(children: [
      _placeholder(),
      LayoutBuilder(builder: (context, box) {
        return MovableControl(
          area: Size(box.maxWidth, box.maxHeight),
          fraction: const Offset(0.15, 0.7),
          editing: true,
          label: 'Fire',
          onMoved: (_) {},
          onMoveEnd: () {},
          child: const CircleAvatar(radius: 34, child: Text('A')),
        );
      }),
    ]);
  }

  Widget _placeholder() {
    return Container(
      decoration: BoxDecoration(
        color: WorkbenchColors.panelFill,
        border: Border.all(color: WorkbenchColors.panelStroke),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        '${_tab.icon}  ${_tab.title}\n\nDesign the family look here;\ncopy verbatim into the apps.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, height: 1.6),
      ),
    );
  }
}
