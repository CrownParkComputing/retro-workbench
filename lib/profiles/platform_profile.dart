// platform_profile.dart - the blueprint model.
//
// retro-workbench is ONE frontend. It does not belong to any emulator: a new
// app is a BLUEPRINT - which core plugs in underneath (Amiberry, VICE,
// Box86, anything with a bridge), which modules the rail carries, what the
// accent is. The module CATALOGUE below is the full menu of what this
// frontend knows how to be; a blueprint picks from it and may rename the two
// context-dependent ones (Collections, Games). Compliance and About are not
// removable - every app of this family ships reviewer-facing evidence.
import 'package:flutter/material.dart';

import '../theme/workbench_theme.dart';
import '../widgets/sidebar.dart';

/// One thing the rail can offer. The catalogue is the contract: a new
/// feature enters here first, apps opt in via their blueprint.
class WorkbenchModule {
  final String id;
  final String icon;
  final String title;
  final int group; // 0 = what you play, 1 = machine setup, 2 = reference
  final String purpose;
  final bool removable;

  const WorkbenchModule(this.id, this.icon, this.title, this.group,
      this.purpose, {this.removable = true});
}

const moduleCatalogue = <WorkbenchModule>[
  WorkbenchModule('games', '\u{1F3AE}', 'Games', 0,
      'The library grid: scan, search, launch.', removable: false),
  WorkbenchModule('resume', '\u{1F680}', 'Resume', 0,
      'Jump back into the last session.'),
  WorkbenchModule('states', '\u{1F4BE}', 'States', 0,
      'Save-state slots with thumbnails.'),
  WorkbenchModule('collections', '\u{1F5C2}\u{FE0F}', 'Collections', 0,
      'Curated groups - game series, packs, whole distributions. '
      'Rename per app: "Series" for a PC frontend, "Collections" on the '
      'Amiga.'),
  WorkbenchModule('wizard', '\u{1FA84}', 'Setup', 1,
      'The first-run wizard, re-runnable from the rail rather than buried '
      'in About.'),
  WorkbenchModule('video', '\u{1F4FA}', 'Video', 1,
      'Display: aspect, shader, bezel, fill.'),
  WorkbenchModule('audio', '\u{1F50A}', 'Audio', 1,
      'Sound: volume, driver, latency.'),
  WorkbenchModule('input', '\u{1F579}\u{FE0F}', 'Input', 1,
      'Pads, keys, on-screen layout.'),
  WorkbenchModule('core', '\u{2699}\u{FE0F}', 'Core', 1,
      "The plugged-in emulator's own options."),
  WorkbenchModule('paths', '\u{1F4C2}', 'Paths', 1,
      'Where the library, BIOS and saves live.'),
  WorkbenchModule('music', '\u{1F3B5}', 'Music', 2,
      'A machine-music player (SID, MODs). Most apps leave this OFF.'),
  WorkbenchModule('history', '\u{1F4DC}', 'History', 2,
      'What ran, when, for how long.'),
  WorkbenchModule('logs', '\u{1F9FE}', 'Logs', 2,
      'The live app log, its own rail item instead of a corner of About.'),
  WorkbenchModule('compliance', '\u{2705}', 'Compliance', 2,
      'Reviewer-facing evidence page + compliance mode (bundled free '
      'content only).', removable: false),
  WorkbenchModule('about', '\u{2139}\u{FE0F}', 'About', 2,
      'Version, credits, help.', removable: false),
];

WorkbenchModule moduleById(String id) =>
    moduleCatalogue.firstWhere((m) => m.id == id);

class SessionToolSpec {
  final IconData icon;
  final String label;
  final bool canonical;

  const SessionToolSpec(this.icon, this.label, {this.canonical = true});
}

/// The canonical in-game rail: the glyph vocabulary every core shares.
const canonicalTools = <SessionToolSpec>[
  SessionToolSpec(Icons.keyboard, 'Keys'),
  SessionToolSpec(Icons.videogame_asset, 'Pad'),
  SessionToolSpec(Icons.open_with, 'Layout'),
  SessionToolSpec(Icons.save_outlined, 'Save state'),
  SessionToolSpec(Icons.album, 'Swap disk'),
  SessionToolSpec(Icons.aspect_ratio, 'Screen shape'),
  SessionToolSpec(Icons.bookmark_add_outlined, 'Save and exit'),
  SessionToolSpec(Icons.close, 'Close'),
];

/// Which emulator plugs in underneath, and how.
class CoreSpec {
  final String name;
  final String? upstream; // owner/repo on GitHub
  final String bridge;    // how the frontend drives it

  const CoreSpec(this.name, {this.upstream, required this.bridge});
}

/// A whole app, on one page: core underneath, modules on the rail, accent on
/// top. Building a new frontend = writing one of these, then the bridge.
class AppBlueprint {
  final String id;
  final String name;
  final CoreSpec core;
  final Color accent;
  final List<String> modules;           // ids from the catalogue, rail order
  final Map<String, String> renames;    // module id -> app-specific title
  final List<SessionToolSpec> extraTools;
  final String status;                  // shipping | experimental | draft

  const AppBlueprint({
    required this.id,
    required this.name,
    required this.core,
    required this.accent,
    required this.modules,
    this.renames = const {},
    this.extraTools = const [],
    this.status = 'shipping',
  });

  String titleOf(WorkbenchModule m) => renames[m.id] ?? m.title;

  List<SessionToolSpec> get tools => [...canonicalTools, ...extraTools];

  SidebarStyle get sidebarStyle => SidebarStyle(
        panelFill: WorkbenchColors.panelFill,
        panelStroke: WorkbenchColors.panelStroke,
        selectedFill: Color.alphaBlend(
            accent.withValues(alpha: 0.22), WorkbenchColors.selectedFill),
        selectedStroke: accent.withValues(alpha: 0.65),
        labelIdle: WorkbenchColors.sidebarLabelIdle,
        labelSelected: WorkbenchColors.sidebarLabelSelected,
        minWidth: WorkbenchMetrics.sidebarMinWidth,
        buttonHeight: WorkbenchMetrics.sidebarButtonHeight,
        buttonTextSize: WorkbenchMetrics.sidebarButtonTextSize,
        buttonBottomMargin: WorkbenchMetrics.sidebarButtonBottomMargin,
        buttonSidePadding: WorkbenchMetrics.sidebarButtonSidePadding,
        buttonVerticalPadding: WorkbenchMetrics.sidebarButtonVerticalPadding,
        navPadding: WorkbenchMetrics.sideNavPadding,
        maxWidth: WorkbenchMetrics.sidebarMaxWidth,
      );

  /// The blueprint as data - paste this into a new app to seed it.
  String export() {
    final b = StringBuffer()
      ..writeln('{')
      ..writeln('  "id": "$id",')
      ..writeln('  "name": "$name",')
      ..writeln('  "core": {"name": "${core.name}", '
          '"upstream": ${core.upstream == null ? 'null' : '"${core.upstream}"'}, '
          '"bridge": "${core.bridge}"},')
      ..writeln('  "modules": [${modules.map((m) => '"$m"').join(', ')}],')
      ..writeln('  "renames": {${renames.entries.map((e) => '"${e.key}": "${e.value}"').join(', ')}},')
      ..writeln('  "status": "$status"')
      ..writeln('}');
    return b.toString();
  }
}

final appBlueprints = <AppBlueprint>[
  const AppBlueprint(
    id: 'box86',
    name: 'Retro-PC (Box86)',
    core: CoreSpec('Box64/Box86', upstream: 'ptitSeb/box64',
        bridge: 'process host: launch x86 titles under box64, capture the '
            'window, drive it with the session rail'),
    accent: Color(0xFFE8B100),
    // No Music. Wizard on the rail. Logs split out. Collections = series.
    modules: ['games', 'resume', 'states', 'collections', 'wizard', 'video',
        'input', 'core', 'paths', 'logs', 'compliance', 'about'],
    renames: {'collections': 'Series', 'core': 'Box64'},
    status: 'draft',
  ),
  const AppBlueprint(
    id: 'retro-amiga',
    name: 'Retro-Amiga',
    core: CoreSpec('Amiberry', upstream: 'BlitterStudio/amiberry',
        bridge: 'JNI + prebuilt core'),
    accent: Color(0xFFFF6A00),
    modules: ['games', 'resume', 'collections', 'video', 'input', 'core',
        'paths', 'music', 'history', 'compliance', 'about'],
  ),
  const AppBlueprint(
    id: 'retro-c64',
    name: 'Retro-64',
    core: CoreSpec('VICE', upstream: 'VICE-Team/svn-mirror',
        bridge: 'FFI + prebuilt libvicecore'),
    accent: Color(0xFF7C71DA),
    modules: ['games', 'resume', 'video', 'input', 'core', 'paths', 'music',
        'history', 'compliance', 'about'],
  ),
  const AppBlueprint(
    id: 'retro-dosbox',
    name: 'Retro-Dosbox',
    core: CoreSpec('DOSBox-X', upstream: 'joncampbell123/dosbox-x',
        bridge: 'vendored core, shared framebuffer'),
    accent: Color(0xFF00FFCC),
    modules: ['games', 'resume', 'states', 'video', 'input', 'core', 'paths',
        'compliance', 'about'],
    renames: {'core': 'Engine'},
    extraTools: [SessionToolSpec(Icons.mouse, 'Mouse', canonical: false)],
  ),
  const AppBlueprint(
    id: 'retro-saturn',
    name: 'Retro-Saturn',
    core: CoreSpec('Ymir', upstream: 'StrikerX3/Ymir',
        bridge: 'FFI over vendored tree'),
    accent: Color(0xFF3B6FE0),
    modules: ['games', 'states', 'video', 'core', 'paths', 'history',
        'compliance', 'about'],
    renames: {'history': 'Memories'},
    extraTools: [SessionToolSpec(Icons.usb, 'Ports', canonical: false)],
  ),
  const AppBlueprint(
    id: 'retro-spectrum',
    name: 'Retro-Spectrum',
    core: CoreSpec('speccy_core', bridge: 'in-house FFI'),
    accent: Color(0xFFE03B3B),
    modules: ['games', 'resume', 'audio', 'input', 'paths', 'history',
        'compliance', 'about'],
    renames: {'history': 'Memories'},
  ),
  const AppBlueprint(
    id: 'retro-atarist',
    name: 'Retro-AtariST',
    core: CoreSpec('Hatari', upstream: 'hatari/hatari',
        bridge: 'submodule + FFI'),
    accent: Color(0xFF57B65B),
    modules: ['games', 'resume', 'states', 'video', 'input', 'core', 'paths',
        'compliance', 'about'],
    renames: {'core': 'Machine'},
    extraTools: [
      SessionToolSpec(Icons.restart_alt, 'Reset', canonical: false),
      SessionToolSpec(Icons.fit_screen, 'Fill', canonical: false),
    ],
  ),
  const AppBlueprint(
    id: 'retro-amiga-copperline',
    name: 'Retro-Amiga · Copperline',
    core: CoreSpec('Copperline', upstream: 'LinuxJedi/Copperline',
        bridge: 'Rust cdylib (planned)'),
    accent: Color(0xFFB87333),
    modules: ['games', 'resume', 'collections', 'video', 'input', 'core',
        'paths', 'compliance', 'about'],
    status: 'experimental',
  ),
];
