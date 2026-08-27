// retro-workbench: ONE frontend, designed core-agnostically. Pick a
// blueprint along the top (or start from any and toggle modules in the
// Designer), watch the rail rebuild live, then Export the blueprint to seed
// the new app. The widgets and metrics never change per app - a blueprint
// only chooses the core, the modules, the names and the accent.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      // No global fontFamily: the sidebar measures its own labels.
      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      home: const WorkbenchDesigner(),
    );
  }
}

class WorkbenchDesigner extends StatefulWidget {
  const WorkbenchDesigner({super.key});

  @override
  State<WorkbenchDesigner> createState() => _WorkbenchDesignerState();
}

class _WorkbenchDesignerState extends State<WorkbenchDesigner> {
  AppBlueprint _blueprint = appBlueprints.first;

  /// The working copy the Designer edits - starts as the chosen blueprint.
  late List<String> _modules = List.of(_blueprint.modules);
  int _tabIndex = 0;
  bool _designing = false;

  List<WorkbenchModule> get _rail =>
      [for (final id in _modules) moduleById(id)]
        ..sort((a, b) => a.group - b.group);

  void _pick(AppBlueprint b) => setState(() {
        _blueprint = b;
        _modules = List.of(b.modules);
        _tabIndex = 0;
      });

  @override
  Widget build(BuildContext context) {
    final rail = _rail;
    final tab = rail[_tabIndex.clamp(0, rail.length - 1)];
    return Scaffold(
      backgroundColor: WorkbenchColors.rootBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _blueprintBar(),
            _coreLine(),
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
                          for (final m in rail)
                            SidebarDestination(
                                '${m.icon} ${_blueprint.titleOf(m)}',
                                group: m.group),
                        ],
                        selectedIndex: _tabIndex.clamp(0, rail.length - 1),
                        onSelected: (i) => setState(() => _tabIndex = i),
                        style: _blueprint.sidebarStyle,
                        pinLastGroupToBottom: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                      child: _designing ? _designerPanel() : _panel(tab),
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

  Widget _blueprintBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final b in appBlueprints)
            ChoiceChip(
              label: Text(b.status == 'shipping'
                  ? b.name
                  : '${b.name} · ${b.status}'),
              selected: b.id == _blueprint.id,
              selectedColor: b.accent.withValues(alpha: 0.25),
              side: BorderSide(
                  color: b.id == _blueprint.id
                      ? b.accent
                      : WorkbenchColors.panelStroke),
              onSelected: (_) => _pick(b),
            ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('🛠 Designer'),
            selected: _designing,
            selectedColor: _blueprint.accent.withValues(alpha: 0.25),
            onSelected: (v) => setState(() => _designing = v),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.copy, size: 15),
            label: const Text('Export blueprint'),
            onPressed: _export,
          ),
        ],
      ),
    );
  }

  Widget _coreLine() {
    final c = _blueprint.core;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Text(
        'core: ${c.name}'
        '${c.upstream != null ? '  ·  github.com/${c.upstream}' : ''}'
        '  ·  bridge: ${c.bridge}',
        style: TextStyle(
            fontSize: 12, color: WorkbenchColors.sidebarLabelIdle),
      ),
    );
  }

  // ------------------------------------------------------------- designer

  /// The whole catalogue with switches: what this app carries, what it
  /// deliberately leaves out. Non-removable modules say so.
  Widget _designerPanel() {
    return Container(
      decoration: _panelBox(),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Module catalogue - everything this frontend knows how to be. '
              'Toggle what ${_blueprint.name} carries; the rail rebuilds '
              'live.',
              style: TextStyle(
                  fontSize: 13, color: WorkbenchColors.sidebarLabelIdle),
            ),
          ),
          for (final m in moduleCatalogue)
            SwitchListTile(
              dense: true,
              activeTrackColor: _blueprint.accent.withValues(alpha: 0.5),
              title: Text('${m.icon}  ${_blueprint.titleOf(m)}'
                  '${_blueprint.renames.containsKey(m.id) ? '  (catalogue: ${m.title})' : ''}'),
              subtitle: Text(
                  m.removable ? m.purpose : '${m.purpose}  - not removable',
                  style: const TextStyle(fontSize: 11)),
              value: _modules.contains(m.id),
              onChanged: m.removable
                  ? (on) => setState(() {
                        on ? _modules.add(m.id) : _modules.remove(m.id);
                        _tabIndex = 0;
                      })
                  : null,
            ),
        ],
      ),
    );
  }

  Future<void> _export() async {
    final working = AppBlueprint(
      id: _blueprint.id,
      name: _blueprint.name,
      core: _blueprint.core,
      accent: _blueprint.accent,
      modules: _modules,
      renames: _blueprint.renames,
      status: _blueprint.status,
    );
    final text = working.export();
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_blueprint.name} - blueprint (copied)'),
        content: SelectableText(text,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- panels

  Widget _panel(WorkbenchModule tab) {
    switch (tab.id) {
      case 'games':
        return _libraryPanel();
      case 'input':
        return _padPlayground();
      case 'collections':
        return _collectionsPanel();
      default:
        return _placeholder(tab);
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
              child: MediaCard(title: title, kindLabel: kind, onTap: () {}),
            ),
        ],
      );
    });
  }

  /// Collections mean different things per app - series on a PC frontend,
  /// whole distributions on the Amiga - so the sample rows follow the name.
  Widget _collectionsPanel() {
    final isSeries = _blueprint.renames['collections'] == 'Series';
    final rows = isSeries
        ? const ['Need for Speed (7 titles)', 'Command & Conquer (5 titles)',
            'Wing Commander (4 titles)']
        : const ['AGS Mega Pack', 'AmigaVision 2024', 'PiMiga 3'];
    return Container(
      decoration: _panelBox(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_blueprint.titleOf(moduleById('collections')),
              style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 10),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Icon(Icons.folder_special,
                    size: 18, color: _blueprint.accent),
                const SizedBox(width: 8),
                Text(r),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _padPlayground() {
    return LayoutBuilder(builder: (context, box) {
      return Stack(children: [
        Container(
          decoration: _panelBox(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('In-game tool rail - ${_blueprint.core.name}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final t in _blueprint.tools)
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
                                  : _blueprint.accent),
                        ),
                        child: Icon(t.icon, size: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(t.label,
                          style: TextStyle(
                              fontSize: 9,
                              color: t.canonical
                                  ? WorkbenchColors.sidebarLabelIdle
                                  : _blueprint.accent)),
                    ]),
                ],
              ),
              const SizedBox(height: 8),
              const Text('accent border = app-specific tool',
                  style: TextStyle(
                      fontSize: 11,
                      color: WorkbenchColors.sidebarLabelIdle)),
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

  Widget _placeholder(WorkbenchModule tab) {
    return Container(
      decoration: _panelBox(),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${tab.icon}  ${_blueprint.titleOf(tab)}',
              style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 10),
          Text(tab.purpose,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: WorkbenchColors.sidebarLabelIdle)),
        ],
      ),
    );
  }
}
