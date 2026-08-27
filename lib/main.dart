// The workbench shell, running on its own - now with the whole family in one
// window. The platform chips along the top swap the active PlatformProfile:
// accent, tab set and in-game tools change; the widgets and metrics never do.
// Design a change here, watch it under every machine's skin, then copy the
// touched widget files verbatim into the apps.
import 'package:flutter/material.dart';

import 'profiles/platform_profile.dart';
import 'theme/workbench_theme.dart';
import 'widgets/media_card.dart';
import 'widgets/movable_control.dart';
import 'widgets/sidebar.dart';

void main() => runApp(const WorkbenchDemoApp());

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
  PlatformProfile _profile = platformProfiles.first;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = _profile.tabs;
    final tab = tabs[_tabIndex.clamp(0, tabs.length - 1)];
    return Scaffold(
      backgroundColor: WorkbenchColors.rootBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _platformBar(),
            Expanded(
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
                          for (final t in tabs)
                            SidebarDestination('${t.icon} ${t.title}',
                                group: t.group),
                        ],
                        selectedIndex: _tabIndex.clamp(0, tabs.length - 1),
                        onSelected: (i) => setState(() => _tabIndex = i),
                        style: _profile.sidebarStyle,
                        pinLastGroupToBottom: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                      child: _panel(tab),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The family in one strip: pick a machine, the shell wears its accent.
  Widget _platformBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final p in platformProfiles)
            ChoiceChip(
              label: Text(p.name),
              selected: p.id == _profile.id,
              selectedColor: p.accent.withValues(alpha: 0.25),
              side: BorderSide(
                  color: p.id == _profile.id
                      ? p.accent
                      : WorkbenchColors.panelStroke),
              onSelected: (_) => setState(() {
                _profile = p;
                _tabIndex = 0;
              }),
            ),
        ],
      ),
    );
  }

  Widget _panel(WorkbenchTabSpec tab) {
    if (tab.title == 'Games') return _libraryPanel();
    if (tab.title == 'Input') return _padPlayground();
    return _placeholder(tab);
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

  /// The in-game rail preview lives on Input: every tool this machine offers,
  /// canonical glyphs first, machine-specific ones marked - plus one movable
  /// control to feel the Layout mode.
  Widget _padPlayground() {
    // MovableControl positions itself: it must be a DIRECT child of the
    // Stack, so the LayoutBuilder wraps the Stack rather than the control.
    return LayoutBuilder(builder: (context, box) {
      return Stack(children: [
        Container(
          decoration: _panelBox(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('In-game tool rail — ${_profile.machine}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final t in _profile.tools)
                    Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: WorkbenchColors.selectedFill,
                          border: Border.all(
                              color: t.canonical
                                  ? WorkbenchColors.panelStroke
                                  : _profile.accent),
                        ),
                        child: Icon(t.icon, size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(t.label,
                          style: TextStyle(
                              fontSize: 9,
                              color: t.canonical
                                  ? WorkbenchColors.sidebarLabelIdle
                                  : _profile.accent)),
                    ]),
                ],
              ),
              const SizedBox(height: 8),
              const Text('accent border = machine-specific tool',
                  style: TextStyle(
                      fontSize: 11, color: WorkbenchColors.sidebarLabelIdle)),
            ],
          ),
        ),
        MovableControl(
          area: Size(box.maxWidth, box.maxHeight),
          fraction: const Offset(0.75, 0.75),
          editing: true,
          label: 'Fire',
          onMoved: (_) {},
          onMoveEnd: () {},
          child: const CircleAvatar(radius: 34, child: Text('A')),
        ),
      ]);
    });
  }

  BoxDecoration _panelBox() => BoxDecoration(
        color: WorkbenchColors.panelFill,
        border: Border.all(color: WorkbenchColors.panelStroke),
        borderRadius: BorderRadius.circular(10),
      );

  Widget _placeholder(WorkbenchTabSpec tab) {
    return Container(
      decoration: _panelBox(),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${tab.icon}  ${tab.title}',
              style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Text(
            tab.canonical
                ? 'Canonical: every machine carries this tab.'
                : 'Machine-specific to ${_profile.machine} — a recorded '
                    'exception, not the base set.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13,
                color: tab.canonical
                    ? WorkbenchColors.sidebarLabelIdle
                    : _profile.accent),
          ),
        ],
      ),
    );
  }
}
