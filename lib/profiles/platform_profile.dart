// platform_profile.dart - one machine, one profile.
//
// The family rule: the WIDGETS are identical everywhere and the metrics never
// change; a machine may only bring its accent, its tab set (the canonical
// vocabulary plus whatever that hardware honestly needs), and its in-game
// tools. Everything a platform is allowed to customise lives in this one
// object - if a difference cannot be expressed here, it is not a per-platform
// difference, it is drift.
import 'package:flutter/material.dart';

import '../theme/workbench_theme.dart';
import '../widgets/sidebar.dart';

class WorkbenchTabSpec {
  final String icon;
  final String title;
  final int group;

  /// Canonical tabs exist on every machine; a non-canonical one is a
  /// deliberate, recorded exception (Collections on the Amiga, Machine on
  /// the ST) - the demo marks them so nobody mistakes them for the base set.
  final bool canonical;

  const WorkbenchTabSpec(this.icon, this.title, this.group,
      {this.canonical = true});
}

class SessionToolSpec {
  final IconData icon;
  final String label;
  final bool canonical;

  const SessionToolSpec(this.icon, this.label, {this.canonical = true});
}

class PlatformProfile {
  final String id;
  final String name;
  final String machine;
  final Color accent;

  /// Selected-tab fill takes the accent at low opacity; everything else in
  /// the rail stays the family palette, which is what keeps six apps reading
  /// as one product with six accents rather than six products.
  final List<WorkbenchTabSpec> tabs;
  final List<SessionToolSpec> tools;

  const PlatformProfile({
    required this.id,
    required this.name,
    required this.machine,
    required this.accent,
    required this.tabs,
    required this.tools,
  });

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
}

// The canonical rail, one entry per job. Machines start from this and may
// only add - never rename. (The /sync page on the fleet dashboard scores the
// real apps against exactly this vocabulary.)
const canonicalTabs = <WorkbenchTabSpec>[
  WorkbenchTabSpec('\u{1F3AE}', 'Games', 0),
  WorkbenchTabSpec('\u{1F680}', 'Resume', 0),
  WorkbenchTabSpec('\u{1F4BE}', 'States', 0),
  WorkbenchTabSpec('\u{1F4FA}', 'Video', 1),
  WorkbenchTabSpec('\u{1F579}\u{FE0F}', 'Input', 1),
  WorkbenchTabSpec('\u{2699}\u{FE0F}', 'Core', 1),
  WorkbenchTabSpec('\u{1F4C2}', 'Paths', 1),
  WorkbenchTabSpec('\u{1F4DC}', 'History', 2),
  WorkbenchTabSpec('\u{2705}', 'Compliance', 2),
  WorkbenchTabSpec('\u{2139}\u{FE0F}', 'About', 2),
];

// The canonical in-game rail: the glyph vocabulary every machine shares.
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

List<WorkbenchTabSpec> _withExtras(List<WorkbenchTabSpec> extras) =>
    [...canonicalTabs, ...extras]..sort((a, b) => a.group - b.group);

List<SessionToolSpec> _withTools(List<SessionToolSpec> extras) =>
    [...canonicalTools, ...extras];

final platformProfiles = <PlatformProfile>[
  PlatformProfile(
    id: 'retro-amiga',
    name: 'Retro-Amiga',
    machine: 'Commodore Amiga',
    accent: const Color(0xFFFF6A00), // Boing-ball orange
    tabs: _withExtras(const [
      WorkbenchTabSpec('\u{1F5C2}\u{FE0F}', 'Collections', 2, canonical: false),
      WorkbenchTabSpec('\u{1F3B5}', 'Music', 2, canonical: false),
    ]),
    tools: _withTools(const []),
  ),
  PlatformProfile(
    id: 'retro-c64',
    name: 'Retro-64',
    machine: 'Commodore 64',
    accent: const Color(0xFF7C71DA), // VIC-II light blue-violet
    tabs: _withExtras(const [
      WorkbenchTabSpec('\u{1F3B5}', 'Music', 2, canonical: false), // SID
    ]),
    tools: _withTools(const []),
  ),
  PlatformProfile(
    id: 'retro-dosbox',
    name: 'Retro-Dosbox',
    machine: 'IBM PC compatible',
    accent: const Color(0xFF00FFCC), // phosphor teal
    tabs: _withExtras(const []),
    tools: _withTools(const [
      SessionToolSpec(Icons.mouse, 'Mouse', canonical: false),
    ]),
  ),
  PlatformProfile(
    id: 'retro-saturn',
    name: 'Retro-Saturn',
    machine: 'Sega Saturn',
    accent: const Color(0xFF3B6FE0), // Saturn blue
    tabs: _withExtras(const []),
    tools: _withTools(const [
      SessionToolSpec(Icons.usb, 'Ports', canonical: false),
    ]),
  ),
  PlatformProfile(
    id: 'retro-spectrum',
    name: 'Retro-Spectrum',
    machine: 'ZX Spectrum',
    accent: const Color(0xFFE03B3B), // rainbow-stripe red
    tabs: _withExtras(const [
      WorkbenchTabSpec('\u{1F50A}', 'Audio', 1, canonical: false),
    ]),
    tools: _withTools(const []),
  ),
  PlatformProfile(
    id: 'retro-atarist',
    name: 'Retro-AtariST',
    machine: 'Atari ST',
    accent: const Color(0xFF57B65B), // ST green desktop
    tabs: _withExtras(const [
      WorkbenchTabSpec('\u{1F5A5}\u{FE0F}', 'Machine', 1, canonical: false),
    ]),
    tools: _withTools(const [
      SessionToolSpec(Icons.restart_alt, 'Reset', canonical: false),
      SessionToolSpec(Icons.fit_screen, 'Fill', canonical: false),
    ]),
  ),
  PlatformProfile(
    id: 'retro-amiga-copperline',
    name: 'Retro-Amiga · Copperline',
    machine: 'Commodore Amiga (Copperline core)',
    accent: const Color(0xFFB87333), // copper
    tabs: _withExtras(const [
      WorkbenchTabSpec('\u{1F5C2}\u{FE0F}', 'Collections', 2, canonical: false),
    ]),
    tools: _withTools(const []),
  ),
];
