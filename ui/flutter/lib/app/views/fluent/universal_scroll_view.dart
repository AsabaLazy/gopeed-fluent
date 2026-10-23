import 'package:fluent_ui/fluent_ui.dart';

class UniversalScrollView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final double spacing;
  final bool lazy;
  const UniversalScrollView({super.key, this.controller, this.spacing = 0, this.lazy = false, required this.children});

  @override
  Widget build(BuildContext context) {
    if (lazy) {
      return SizedBox.expand(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1024),
            child: ListView.separated(
              controller: controller,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
              itemCount: children.length,
              separatorBuilder: (context, index) => SizedBox(height: spacing),
              itemBuilder: (context, index) => children[index],
            ),
          ),
        ),
      );
    }
    return SizedBox.expand(
      child: SingleChildScrollView(
        controller: controller,
        physics: const BouncingScrollPhysics(),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1024),
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: spacing, children: children),
          ),
        ),
      ),
    );
  }
}


