import 'dart:math' as math;

import 'package:delivo/app/theme/app_radius.dart';
import 'package:delivo/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

class HomeStatItem extends StatelessWidget {
  const HomeStatItem({
    required this.icon,
    required this.label,
    required this.value,
    this.animatedValue,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;
  final int? animatedValue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (animatedValue case final target?)
                  _OdometerNumber(
                    value: target,
                    style: theme.textTheme.titleLarge,
                  )
                else
                  Text(value, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: '$label: ${animatedValue ?? value}',
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.borderLarge,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.borderLarge,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppRadius.borderLarge,
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _OdometerNumber extends StatefulWidget {
  const _OdometerNumber({required this.value, required this.style});

  final int value;
  final TextStyle? style;

  @override
  State<_OdometerNumber> createState() => _OdometerNumberState();
}

class _OdometerNumberState extends State<_OdometerNumber>
    with TickerProviderStateMixin {
  static const Duration _digitDuration = Duration(milliseconds: 800);

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
  void didUpdateWidget(covariant _OdometerNumber oldWidget) {
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
    final length = math.max(previous.length, current.length);

    final previousPadded = previous.padLeft(length, ' ');
    final currentPadded = current.padLeft(length, ' ');

    return List<_DigitSlotState>.generate(length, (index) {
      return _DigitSlotState(
        placeFromRight: length - index - 1,
        previousCharacter: previousPadded[index],
        currentCharacter: currentPadded[index],
      );
    }, growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final isIncreasing = widget.value > _previousValue;
    final textStyle = widget.style;

    return AnimatedSize(
      duration: _digitDuration,
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final slot in _slots)
            _OdometerDigit(
              key: ValueKey<int>(slot.placeFromRight),
              previousCharacter: slot.previousCharacter,
              currentCharacter: slot.currentCharacter,
              isIncreasing: isIncreasing,
              style: textStyle,
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
    final hasChanged = previousCharacter != currentCharacter;

    if (!hasChanged) {
      return _DigitBox(character: currentCharacter, style: style);
    }

    return ClipRect(
      child: AnimatedSwitcher(
        duration: _OdometerNumberState._digitDuration,
        reverseDuration: _OdometerNumberState._digitDuration,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          final isIncoming = child.key == ValueKey<String>(currentCharacter);

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
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: _DigitBox(
          key: ValueKey<String>(currentCharacter),
          character: currentCharacter,
          style: style,
        ),
      ),
    );
  }
}

class _DigitBox extends StatelessWidget {
  const _DigitBox({required this.character, required this.style, super.key});

  final String character;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? DefaultTextStyle.of(context).style;

    final painter = TextPainter(
      text: TextSpan(text: '0', style: effectiveStyle),
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
                style: effectiveStyle.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
    );
  }
}
