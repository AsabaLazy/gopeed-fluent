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
              titleBar: TitleBar(
                isBackButtonVisible: !showLogo,
                onBackRequested: showLogo ? null : delegate.popRoute,
                onDragStarted: () => windowManager.startDragging(),
                // Keep the double-tap recognizer off the title bar root.
                // Otherwise its timeout delays every child button
                // (caption buttons) by ~300ms.
                icon: showLogo
                    ? const Padding(
                        padding: EdgeInsetsDirectional.only(start: 12),
                        child: AppLogo(size: 25),
                      )
                    : null,
                title: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onDoubleTap: toggleMaximized,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text('appNameMod'.tr),
                  ),
                ),
                captionControls: const WindowButtons(),
              ),
              paneBodyBuilder: (item, c) {
                return GetRouterOutlet(
                  initialRoute: Routes.TASK,
                  // anchorRoute: '/',
                  // filterPages: (afterAnchor) {
                  //   logger.w(afterAnchor);
                  //   logger.w(afterAnchor.take(1));
                  //   return afterAnchor.take(1);
                  // },
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
