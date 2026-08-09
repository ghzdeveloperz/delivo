
import 'dart:math' as math;
import 'dart:ui';

import 'package:delivo/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class HomeStatItem extends StatelessWidget {
  const HomeStatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.animatedValue,
    this.onTap,
    this.emphasized = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? animatedValue;
  final VoidCallback? onTap;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final radius = emphasized ? 21.0 : 20.0;

    final primaryText =
        isDark ? Colors.white : const Color(0xFF171A2B);

    final secondaryText = isDark
        ? Colors.white.withValues(alpha: 0.56)
        : const Color(0xFF6B7085);

    final cardBase = isDark
        ? Colors.white.withValues(
            alpha: emphasized ? 0.048 : 0.042,
          )
        : Colors.white.withValues(alpha: 0.70);

    final borderColor = isDark
        ? Colors.white.withValues(
            alpha: emphasized ? 0.085 : 0.070,
          )
        : const Color(0xFFE5E7F0)
            .withValues(alpha: 0.92);

    final gradientStart = isDark
        ? Colors.white.withValues(alpha: 0.052)
        : Colors.white.withValues(alpha: 0.82);

    final gradientEnd = isDark
        ? Colors.white.withValues(alpha: 0.012)
        : const Color(0xFFF8F9FD)
            .withValues(alpha: 0.58);

    final iconBackgroundA = isDark
        ? const Color(0xFF8B7CF6)
            .withValues(alpha: 0.18)
        : const Color(0xFF6C5CE7)
            .withValues(alpha: 0.10);

    final iconBackgroundB = isDark
        ? const Color(0xFF2D9CDB)
            .withValues(alpha: 0.06)
        : const Color(0xFF2D9CDB)
            .withValues(alpha: 0.05);

    final chevronColor = isDark
        ? Colors.white.withValues(alpha: 0.44)
        : const Color(0xFF6B7085);

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal:
            emphasized ? AppSpacing.md : AppSpacing.sm,
        vertical:
            emphasized ? 14 : 12,
      ),
      child: emphasized
          ? _EmphasizedContent(
              icon: icon,
              label: label,
              value: value,
              animatedValue: animatedValue,
              onTap: onTap,
              theme: theme,
              primaryText: primaryText,
              secondaryText: secondaryText,
              chevronColor: chevronColor,
              iconBackgroundA: iconBackgroundA,
              iconBackgroundB: iconBackgroundB,
            )
          : _CompactContent(
              icon: icon,
              label: label,
              value: value,
              animatedValue: animatedValue,
              onTap: onTap,
              theme: theme,
              primaryText: primaryText,
              secondaryText: secondaryText,
              chevronColor: chevronColor,
              iconBackgroundA: iconBackgroundA,
              iconBackgroundB: iconBackgroundB,
            ),
    );

    return Semantics(
      button: onTap != null,
      label: '$label: ${animatedValue ?? value}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 12,
            sigmaY: 12,
          ),
          child: Material(
            color: cardBase,
            child: InkWell(
              onTap: onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(radius),
                  border: Border.all(
                    color: borderColor,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradientStart,
                      gradientEnd,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(
                              alpha: 0.09,
                            )
                          : const Color(0xFF171A2B)
                              .withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmphasizedContent extends StatelessWidget {
  const _EmphasizedContent({
    required this.icon,
    required this.label,
    required this.value,
    required this.animatedValue,
    required this.onTap,
    required this.theme,
    required this.primaryText,
    required this.secondaryText,
    required this.chevronColor,
    required this.iconBackgroundA,
    required this.iconBackgroundB,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? animatedValue;
  final VoidCallback? onTap;
  final ThemeData theme;
  final Color primaryText;
  final Color secondaryText;
  final Color chevronColor;
  final Color iconBackgroundA;
  final Color iconBackgroundB;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FloatingIcon(
          icon: icon,
          size: 44,
          backgroundA: iconBackgroundA,
          backgroundB: iconBackgroundB,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (animatedValue case final target?)
                _OdometerNumber(
                  value: target,
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: primaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                  ),
                )
              else
                Text(
                  value,
                  style: theme
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                    color: primaryText,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.35,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: chevronColor,
          ),
      ],
    );
  }
}

class _CompactContent extends StatelessWidget {
  const _CompactContent({
    required this.icon,
    required this.label,
    required this.value,
    required this.animatedValue,
    required this.onTap,
    required this.theme,
    required this.primaryText,
    required this.secondaryText,
    required this.chevronColor,
    required this.iconBackgroundA,
    required this.iconBackgroundB,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? animatedValue;
  final VoidCallback? onTap;
  final ThemeData theme;
  final Color primaryText;
  final Color secondaryText;
  final Color chevronColor;
  final Color iconBackgroundA;
  final Color iconBackgroundB;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _FloatingIcon(
              icon: icon,
              size: 34,
              backgroundA: iconBackgroundA,
              backgroundB: iconBackgroundB,
            ),
            const Spacer(),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: chevronColor,
              ),
          ],
        ),
        const Spacer(),
        if (animatedValue case final target?)
          _OdometerNumber(
            value: target,
            style: theme.textTheme.titleMedium?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
            ),
          )
        else
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: primaryText,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
            ),
          ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: secondaryText,
          ),
        ),
      ],
    );
  }
}

class _FloatingIcon extends StatelessWidget {
  const _FloatingIcon({
    required this.icon,
    required this.size,
    required this.backgroundA,
    required this.backgroundB,
  });

  final IconData icon;
  final double size;
  final Color backgroundA;
  final Color backgroundB;

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(size * 0.30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              backgroundA,
              backgroundB,
            ],
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.045)
                : const Color(0xFFE5E7F0),
          ),
        ),
        child: Icon(
          icon,
          color: isDark
              ? const Color(0xFF9D91FF)
              : const Color(0xFF6C5CE7),
          size: size * 0.48,
        ),
      ),
    );
  }
}

class _OdometerNumber extends StatefulWidget {
  const _OdometerNumber({
    required this.value,
    required this.style,
  });

  final int value;
  final TextStyle? style;

  @override
  State<_OdometerNumber> createState() =>
      _OdometerNumberState();
}

class _OdometerNumberState
    extends State<_OdometerNumber>
    with TickerProviderStateMixin {
  static const Duration _digitDuration =
      Duration(milliseconds: 800);

  late int _previousValue;
  late List<_DigitSlotState> _slots;

  @override
  void initState() {
    super.initState();

    _previousValue = widget.value;
    _slots = _buildSlots(
      previousValue: widget.value,
      currentValue: widget.value,
    );
  }

  @override
  void didUpdateWidget(
    covariant _OdometerNumber oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (widget.value == oldWidget.value) {
      return;
    }

    _previousValue = oldWidget.value;

    setState(() {
      _slots = _buildSlots(
        previousValue: oldWidget.value,
        currentValue: widget.value,
      );
    });
  }

  List<_DigitSlotState> _buildSlots({
    required int previousValue,
    required int currentValue,
  }) {
    final previous = previousValue.toString();
    final current = currentValue.toString();
    final length = math.max(
      previous.length,
      current.length,
    );

    final previousPadded =
        previous.padLeft(length, ' ');
    final currentPadded =
        current.padLeft(length, ' ');

    return List<_DigitSlotState>.generate(
      length,
      (index) {
        return _DigitSlotState(
          placeFromRight: length - index - 1,
          previousCharacter:
              previousPadded[index],
          currentCharacter:
              currentPadded[index],
        );
      },
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncreasing =
        widget.value > _previousValue;

    return AnimatedSize(
      duration: _digitDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final slot in _slots)
            _OdometerDigit(
              key: ValueKey<int>(
                slot.placeFromRight,
              ),
              previousCharacter:
                  slot.previousCharacter,
              currentCharacter:
                  slot.currentCharacter,
              isIncreasing: isIncreasing,
              style: widget.style,
            ),
        ],
      ),
    );
  }
}

final class _DigitSlotState {
  const _DigitSlotState({
    required this.placeFromRight,
    required this.previousCharacter,
    required this.currentCharacter,
  });

  final int placeFromRight;
  final String previousCharacter;
  final String currentCharacter;
}

class _OdometerDigit extends StatelessWidget {
  const _OdometerDigit({
    required this.previousCharacter,
    required this.currentCharacter,
    required this.isIncreasing,
    required this.style,
    super.key,
  });

  final String previousCharacter;
  final String currentCharacter;
  final bool isIncreasing;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final hasChanged =
        previousCharacter != currentCharacter;

    if (!hasChanged) {
      return _DigitBox(
        character: currentCharacter,
        style: style,
      );
    }

    return ClipRect(
      child: AnimatedSwitcher(
        duration:
            _OdometerNumberState._digitDuration,
        reverseDuration:
            _OdometerNumberState._digitDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (
          currentChild,
          previousChildren,
        ) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null)
                currentChild,
            ],
          );
        },
        transitionBuilder: (
          child,
          animation,
        ) {
          final isIncoming = child.key ==
              ValueKey<String>(
                currentCharacter,
              );

          final incomingBegin = isIncreasing
              ? const Offset(0, 0.52)
              : const Offset(0, -0.52);

          final outgoingEnd = isIncreasing
              ? const Offset(0, -0.52)
              : const Offset(0, 0.52);

          final slide = isIncoming
              ? Tween<Offset>(
                  begin: incomingBegin,
                  end: Offset.zero,
                ).animate(animation)
              : Tween<Offset>(
                  begin: outgoingEnd,
                  end: Offset.zero,
                ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
        child: _DigitBox(
          key: ValueKey<String>(
            currentCharacter,
          ),
          character: currentCharacter,
          style: style,
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({
    required this.character,
    required this.style,
    super.key,
  });

  final String character;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? DefaultTextStyle.of(context).style;

    final painter = TextPainter(
      text: TextSpan(
        text: '0',
        style: effectiveStyle,
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final isBlank = character == ' ';

    return SizedBox(
      width: isBlank ? 0 : painter.width,
      height: painter.height,
      child: isBlank
          ? const SizedBox.shrink()
          : Align(
              alignment: Alignment.center,
              child: Text(
                character,
                style: effectiveStyle,
              ),
            ),
    );
  }
}
