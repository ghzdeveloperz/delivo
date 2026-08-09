
import 'package:delivo/app/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DelivoThemeSwitch extends ConsumerWidget {
  const DelivoThemeSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final systemBrightness =
        MediaQuery.platformBrightnessOf(context);

    final isDark = switch (themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system =>
        systemBrightness == Brightness.dark,
    };

    return Semantics(
      button: true,
      toggled: isDark,
      label: isDark
          ? 'Tema escuro. Toque para usar o tema claro.'
          : 'Tema claro. Toque para usar o tema escuro.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          ref
              .read(themeModeProvider.notifier)
              .toggle(
                Theme.of(context).brightness,
              );
        },
        child: _ThemeSwitchVisual(
          isDark: isDark,
        ),
      ),
    );
  }
}

class _ThemeSwitchVisual extends StatelessWidget {
  const _ThemeSwitchVisual({
    required this.isDark,
  });

  final bool isDark;

  static const double _width = 60;
  static const double _height = 34;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      width: _width,
      height: _height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isDark
            ? const Color(0xFF20262C)
            : const Color(0xFF5494DE),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic,
            left: isDark ? 7 : 29,
            top: 5,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: isDark
                  ? const _Moon(
                      key: ValueKey<String>('moon'),
                    )
                  : const _Sun(
                      key: ValueKey<String>('sun'),
                    ),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: isDark ? 1 : 0,
            child: const _Stars(),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 350),
            opacity: isDark ? 0 : 1,
            child: const _Clouds(),
          ),
        ],
      ),
    );
  }
}

class _Moon extends StatelessWidget {
  const _Moon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFECECD9),
            boxShadow: [
              BoxShadow(
                color: Color(0x55DADADA),
                offset: Offset(-2, 1),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        Positioned(
          left: 7,
          top: -2,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF20262C),
            ),
          ),
        ),
      ],
    );
  }
}

class _Sun extends StatelessWidget {
  const _Sun({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFEFDF2B),
        boxShadow: [
          BoxShadow(
            color: Color(0x88EFDF2B),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        _Star(left: 42, top: 7),
        _Star(left: 50, top: 15),
        _Star(left: 38, top: 21),
        _Star(left: 47, top: 27),
        _Star(left: 54, top: 8),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({
    required this.left,
    required this.top,
  });

  final double left;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 2.5,
        height: 2.5,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE5F041),
          boxShadow: [
            BoxShadow(
              color: Color(0x99E5F041),
              blurRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class _Clouds extends StatelessWidget {
  const _Clouds();

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        Positioned(
          left: 8,
          top: 16,
          child: _CloudDot(
            width: 15,
            height: 8,
          ),
        ),
        Positioned(
          left: 16,
          top: 11,
          child: _CloudDot(
            width: 12,
            height: 12,
          ),
        ),
        Positioned(
          left: 23,
          top: 17,
          child: _CloudDot(
            width: 10,
            height: 7,
          ),
        ),
      ],
    );
  }
}

class _CloudDot extends StatelessWidget {
  const _CloudDot({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(
          alpha: 0.90,
        ),
      ),
    );
  }
}
