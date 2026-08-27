import 'sidebar.dart';
import '../theme/workbench_theme.dart';

/// The DOSBox front end's rail palette. This adapter is the only per-app part
/// of the side nav -- widgets/sidebar.dart itself is identical in every
/// Retro-* app, so a fix there lands everywhere instead of once.
const SidebarStyle workbenchSidebarStyle = SidebarStyle(
  panelFill: WorkbenchColors.panelFill,
  panelStroke: WorkbenchColors.panelStroke,
  selectedFill: WorkbenchColors.selectedFill,
  selectedStroke: WorkbenchColors.selectedStroke,
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
