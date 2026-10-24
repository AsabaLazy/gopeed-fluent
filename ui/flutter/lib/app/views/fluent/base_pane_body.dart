import 'package:fluent_ui/fluent_ui.dart';
import 'package:gopeed/app/views/fluent/universal_scroll_view.dart';

class BasePaneBody extends StatelessWidget {
  final String? title;
  final List<Widget>? titleActions;
  final Widget? body;

  const BasePaneBody({super.key, this.title, this.titleActions, this.body});

  BasePaneBody.scrollable({
    super.key,
    this.title,
    this.titleActions,
    ScrollController? scrollController,
    double spacing = 0,
    bool lazy = false,
    required List<Widget> children,
  }) : body = UniversalScrollView(controller: scrollController, spacing: spacing, lazy: lazy, children: children);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    return ScaffoldPage(
      header: title != null || titleActions != null
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Row(
                children: [
                  if (title != null) Expanded(child: Text(title!, style: theme.typography.title)),
                  if (titleActions != null) ...titleActions!,
                ],
              ),
            )
          : null,
      content: body != null ? body! : const SizedBox.shrink(),
    );
  }
}
