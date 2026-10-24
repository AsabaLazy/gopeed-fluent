import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:gopeed/core/get_fluent_app/get_fluent_app.dart';
import 'package:gopeed/theme/theme.dart';
import 'package:window_manager/window_manager.dart'; // Import the required packages

import '../../../../i18n/message.dart';
import '../../../../util/locale_manager.dart';
import '../../../../util/util.dart'; // Import the required packages
import '../../../routes/app_pages.dart';
import '../controllers/app_controller.dart';

class AppView extends GetView<AppController> {
  const AppView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = controller.downloaderConfig.value;
    final app = WithForegroundTask(
      child: GetFluentApp.router(
        useInheritedMediaQuery: true,
        debugShowCheckedModeBanner: false,
        theme: GopeedTheme.light,
        darkTheme: GopeedTheme.dark,
        themeMode: ThemeMode.values.byName(config.extra.themeMode),
        translations: messages,
        locale: toLocale(config.extra.locale),
        fallbackLocale: fallbackLocale,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: messages.keys.keys.map((e) => toLocale(e)).toList(),
        getPages: AppPages.routes,

        // Add listening to theme changes, set the title bar color according to the current system theme.
        builder: (context, child) {
          // if platform is desktop
          if (Util.isDesktop()) {
            // actual brightness of the UI
            Brightness brightness = FluentTheme.of(context).brightness;
            // Set the title bar to use the actual brightness of the UI
            windowManager.setBrightness(brightness);
          }
          // Fix for GetX Overlay issue with Flutter 3.38.1+
          // Reference: https://github.com/jonataslaw/getx/issues/3425
          return Overlay(
            initialEntries: [OverlayEntry(builder: (_) => child!)],
          );
        },
      ),
    );

    // The native window is frameless on Linux. Keep edge resizing available
    // without bringing back GTK's rounded CSD decoration.
    final framedApp = Util.isLinux()
        ? Directionality(
            textDirection: TextDirection.ltr,
            child: DragToResizeArea(resizeEdgeSize: 6, child: app),
          )
        : app;
    return _AppSizeGuard(child: framedApp);
  }
}

/// Keeps the app mounted once it has received a valid layout. The Linux view
/// can briefly report 1x1 during show/restore; replacing the whole router in
/// that case would discard navigation and form state.
class _AppSizeGuard extends StatefulWidget {
  const _AppSizeGuard({required this.child});

  final Widget child;

  @override
  State<_AppSizeGuard> createState() => _AppSizeGuardState();
}

class _AppSizeGuardState extends State<_AppSizeGuard> {
  bool _hasValidSize = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final valid = constraints.maxWidth > 1 && constraints.maxHeight > 1;
        if (valid) {
          _hasValidSize = true;
        }
        if (!_hasValidSize) {
          return const SizedBox.shrink();
        }
        // Always keep the app under the same ClipRect/OverflowBox pair. Moving
        // the child between different parents would recreate the router state
        // even though the child itself stays mounted. On a transient 1x1
        // surface, lay the app out at the minimum window size instead.
        final width = valid ? constraints.maxWidth : 500.0;
        final height = valid ? constraints.maxHeight : 300.0;
        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: width,
            maxWidth: width,
            minHeight: height,
            maxHeight: height,
            child: widget.child,
          ),
        );
      },
    );
  }
}
