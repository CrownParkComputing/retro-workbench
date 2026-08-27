# retro-workbench

The shared workbench GUI every CrownParkComputing Retro-* app inherits, kept
as a standalone project so the shape has one home instead of six drifting
copies. The reference implementation that feeds this repo is **Retro-Dosbox**
(branch `flutter-rewrite`); the live inheritance matrix is published at
<https://www.crownparkcomputing.com/workbench>.

## The shape

- **Sidebar rail** (`lib/widgets/sidebar.dart`) — tabs down the left, content
  panel beside it, status bar underneath. Tabs swap inside the panel, never
  pushed as routes. Group 2 pins to the rail's bottom. The rail measures its
  own labels — never set a global `fontFamily` in the MaterialApp theme, or
  labels clip.
- **SidebarStyle** (`lib/widgets/sidebar_style.dart`) — the per-app accent
  arrives through this, so no theme import leaks into the shared widget.
- **Movable pad controls** (`lib/widgets/movable_control.dart`) — the C64
  layout model: fraction-of-play-area positions in the
  `on_screen_control_positions` pref, editable only in the rail's Layout mode.
- **Media card** (`lib/widgets/media_card.dart`) — the library grid cell;
  grids size as `floor(width / mediaCardCell)` columns.
- **Session screen grammar** (pattern, per app): machines never render inside
  the workbench panel. Full-screen `MaterialPageRoute(fullscreenDialog: true)`
  returning `SessionExit { paused, closed }`; corner ☰/▶ handle; real pause
  menu; 52px labelled tool rail down the RIGHT edge; 6s chrome auto-hide;
  immersiveSticky owned by the session screen, edgeToEdge restored in dispose.
  Rail glyphs are canonical: Keys=keyboard, Pad=videogame_asset,
  Layout=open_with/check, Mouse=mouse, Disk=album, Fill=fit_screen.

## The contract

`sidebar.dart` and `movable_control.dart` are **copy verbatim**: a fix here is
meant to land in every app unchanged. The rest of the family shape (workbench
screen, session screen, compliance screen, wizard primer, library grid) is a
pattern each machine implements in its own accent.

## Keeping the family honest

`tool/check-sync.mjs` compares this repo's verbatim files against every app in
the family by blob hash and prints who has drifted:

    GITHUB_TOKEN=$(gh auth token) node tool/check-sync.mjs

To land a shared fix: change it here first, then copy the file verbatim into
each app (`app/lib/widgets/` in Retro-Amiga, `flutter_app/lib/widgets/`
elsewhere) and run the check until every row says `verbatim`.

## One frontend, any core

This is not a viewer of the existing apps - it is THE frontend, designed
core-agnostically. Building a new app is three steps:

1. **Pick the core** - Amiberry, VICE, Box64/Box86, anything. Get the core
   and content building on its own.
2. **Write the blueprint** (`lib/profiles/platform_profile.dart`): which
   modules from the catalogue the rail carries (no Music for a PC frontend;
   Setup wizard as a rail item; Logs split out), what the context-dependent
   ones mean there (Collections becomes "Series" - Need for Speed, Wing
   Commander), and the accent. Compliance and About are not removable: every
   app of this family ships reviewer-facing evidence and a compliance mode.
3. **Build the bridge** - the layer that lets this GUI boot the core, hand it
   content, capture its screen and drive it from the session tool rail.

The **Designer** (🛠 chip in the running app) toggles catalogue modules live
against any blueprint and **Export blueprint** copies the result as JSON to
seed the new app. The Box86 blueprint ships as the worked example draft.

## Run it

This repo IS a Flutter app now — the shell running on its own, with the
canonical rail vocabulary, the media-card grid and a movable-control
playground:

```sh
flutter run -d linux        # or any device
```

Design changes here, see them running, then copy the touched widget files
verbatim into the apps and watch the fleet's /sync page go green.
