import 'package:fluent_ui/fluent_ui.dart' hide FluentIcons;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:gopeed/app/views/app_logo.dart';
import 'package:gopeed/app/views/window_buttons.dart';
import 'package:window_manager/window_manager.dart';

import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';

const showLogoRoutes = [
  Routes.ROOT,
  Routes.HOME,
  Routes.TASK,
  Routes.TASK_DONE,
  Routes.EXTENSION,
  Routes.SETTING,
];

/// Detects a title-bar double click without putting a gesture recognizer in
/// the arena for the caption buttons. A Listener observes the pointer events
/// but does not consume them, so minimize/maximize/close stay single-click
/// responsive.
class _TitleBarDoubleClickArea extends StatefulWidget {
  const _TitleBarDoubleClickArea({
    required this.child,
    required this.onDoubleClick,
    this.excludeLeft = 0,
    this.excludeRight = 140,
  });

  final Widget child;
  final VoidCallback onDoubleClick;
  final double excludeLeft;
  final double excludeRight;

  @override
  State<_TitleBarDoubleClickArea> createState() =>
      _TitleBarDoubleClickAreaState();
}

class _TitleBarDoubleClickAreaState extends State<_TitleBarDoubleClickArea> {
  DateTime? _lastTapTime;
  Offset? _lastTapPosition;
  Offset? _downPosition;

  void _onPointerDown(PointerDownEvent event) {
    _downPosition = event.position;
  }

  void _onPointerUp(PointerUpEvent event) {
    final downPosition = _downPosition;
    _downPosition = null;
    if (downPosition != null &&
        (event.position - downPosition).distance > 8) {
      _lastTapTime = null;
      _lastTapPosition = null;
      return;
    }

    final width = MediaQuery.sizeOf(context).width;
    if (event.position.dx < widget.excludeLeft ||
        event.position.dx > width - widget.excludeRight) {
      _lastTapTime = null;
      _lastTapPosition = null;
      return;
    }

    final now = DateTime.now();
    final lastTime = _lastTapTime;
    final lastPosition = _lastTapPosition;
    if (lastTime != null &&
        lastPosition != null &&
        now.difference(lastTime) <= const Duration(milliseconds: 350) &&
        (event.position - lastPosition).distance <= 6) {
      _lastTapTime = null;
      _lastTapPosition = null;
      widget.onDoubleClick();
    } else {
      _lastTapTime = now;
      _lastTapPosition = event.position;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: (_) {
        _downPosition = null;
        _lastTapTime = null;
        _lastTapPosition = null;
      },
      child: widget.child,
    );
  }
}

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetRouterOutlet.builder(
      builder: (context, delegate, currentRoute) {
        switch (currentRoute?.uri.path) {
          case Routes.TASK_DONE:
            controller.currentIndex.value = 1;
            break;
          case Routes.EXTENSION:
            controller.currentIndex.value = 2;
            break;
          case Routes.SETTING:
            controller.currentIndex.value = 3;
            break;
          default:
            controller.currentIndex.value = 0;
            break;
        }

        final showLogo = showLogoRoutes.contains(currentRoute?.uri.path);
        final theme = FluentTheme.of(context);
        final toggleMaximized = () async {
          if (await windowManager.isMaximized()) {
            await windowManager.unmaximize();
          } else {
            await windowManager.maximize();
          }
        };
        return FluentTheme(
          data: theme.copyWith(
            // Compact pane items are 38px wide. Match their height so the
            // selected tile is a square instead of a wide rectangle.
            visualDensity: theme.visualDensity.copyWith(vertical: -0.5),
          ),
          child: NavigationPaneTheme(
            data: NavigationPaneTheme.of(context).merge(
              NavigationPaneThemeData(
                tileColor: WidgetStateProperty.resolveWith((states) {
                  if (states.isPressed) {
                    return theme.accentColor.withValues(alpha: 0.20);
                  }
                  if (states.isHovered) {
                    return theme.accentColor.withValues(alpha: 0.14);
                  }
                  return Colors.transparent;
                }),
              ),
            ),
            child: NavigationView(
              titleBar: _TitleBarDoubleClickArea(
                onDoubleClick: toggleMaximized,
                excludeLeft: showLogo ? 0 : 50,
                excludeRight: 140,
                child: TitleBar(
                  isBackButtonVisible: !showLogo,
                  onBackRequested: showLogo ? null : delegate.popRoute,
                  onDragStarted: () => windowManager.startDragging(),
                  icon: showLogo
                      ? const Padding(
                          padding: EdgeInsetsDirectional.only(start: 12),
                          child: AppLogo(size: 25),
                        )
                      : null,
                  title: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('appNameMod'.tr),
                  ),
                  captionControls: const WindowButtons(),
                ),
              ),
              paneBodyBuilder: (item, c) {
                return FluentTheme(
                  data: FluentTheme.of(
                    context,
                  ).copyWith(visualDensity: theme.visualDensity),
                  child: GetRouterOutlet(
                    initialRoute: Routes.TASK,
                    // anchorRoute: '/',
                    // filterPages: (afterAnchor) {
                    //   logger.w(afterAnchor);
                    //   logger.w(afterAnchor.take(1));
                    //   return afterAnchor.take(1);
                    // },
                  ),
                );
              },
              pane: NavigationPane(
                selected: controller.currentIndex.value,
                // The pane is always compact; there is no expand gesture or
                // overlay animation.
                toggleButton: null,
                // Item height is 38px after the square-button density adjustment;
                // 13px padding keeps the library's 12px-tall indicator.
                indicator: const StickyNavigationIndicator(
                  leftPadding: 13,
                  duration: Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                ),
                onItemPressed: (value) {
                  final currentPath = currentRoute?.uri.path;
                  switch (value) {
                    case 0:
                      if (currentPath != Routes.TASK)
                        delegate.offAndToNamed(Routes.TASK);
                      break;
                    case 1:
                      if (currentPath != Routes.TASK_DONE)
                        delegate.offAndToNamed(Routes.TASK_DONE);
                      break;
                    case 2:
                      if (currentPath != Routes.EXTENSION)
                        delegate.offAndToNamed(Routes.EXTENSION);
                      break;
                    case 3:
                      if (currentPath != Routes.SETTING)
                        delegate.offAndToNamed(Routes.SETTING);
                      break;
                  }
                },
                displayMode: PaneDisplayMode.compact,
                items: [
                  PaneItem(
                    icon: const Icon(FluentIcons.cloud_arrow_down_32_regular),
                    title: Text('task'.tr),
                    body: const SizedBox.shrink(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.cloud_archive_32_regular),
                    title: Text('taskDone'.tr),
                    body: const SizedBox.shrink(),
                  ),
                  PaneItem(
                    icon: const Icon(FluentIcons.wrench_screwdriver_32_regular),
                    title: Text('extensions'.tr),
                    body: const SizedBox.shrink(),
                  ),
                ],
                footerItems: [
                  PaneItem(
                    icon: const Icon(FluentIcons.settings_32_regular),
                    title: Text('setting'.tr),
                    body: const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
