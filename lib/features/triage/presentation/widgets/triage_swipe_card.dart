import 'dart:math' as math;

import 'package:delivo/app/theme/app_colors.dart';
import 'package:delivo/app/theme/app_radius.dart';
import 'package:delivo/features/triage/domain/entities/triage_gesture_action.dart';
import 'package:delivo/features/triage/domain/services/triage_gesture_resolver.dart';
import 'package:flutter/material.dart';

class TriageSwipeCard extends StatefulWidget {
  const TriageSwipeCard({
    required this.child,
    required this.enabled,
    required this.onFavorite,
    required this.onMarkForDeletion,
    required this.onOrganize,
    required this.onDecisionCompleted,
    required this.onDecisionAnimationFailed,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final Future<bool> Function() onFavorite;
  final Future<bool> Function() onMarkForDeletion;
  final Future<bool> Function() onOrganize;
  final Future<void> Function() onDecisionCompleted;
  final VoidCallback onDecisionAnimationFailed;

  @override
  State<TriageSwipeCard> createState() =>
      TriageSwipeCardState();
}

class TriageSwipeCardState extends State<TriageSwipeCard>
    with SingleTickerProviderStateMixin {
  static const TriageGestureResolver _resolver =
      TriageGestureResolver();

  late final AnimationController _animationController;

  Animation<Offset>? _offsetAnimation;
  Offset _dragOffset = Offset.zero;
  bool _handlingAction = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    )..addListener(() {
        final animation = _offsetAnimation;
        if (animation != null) {
          setState(() {
            _dragOffset = animation.value;
          });
        }
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> triggerFavorite() {
    return _handleAction(
      TriageGestureAction.favorite,
    );
  }

  Future<void> triggerDeletion() {
    return _handleAction(
      TriageGestureAction.markForDeletion,
    );
  }

  Future<void> triggerOrganize() {
    return _handleAction(
      TriageGestureAction.organize,
    );
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.enabled || _handlingAction) {
      return;
    }

    _animationController.stop();
    _offsetAnimation = null;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _handlingAction) {
      return;
    }

    setState(() {
      _dragOffset += details.delta;
    });
  }

  Future<void> _onPanEnd(
    DragEndDetails details,
  ) async {
    if (!widget.enabled || _handlingAction) {
      return;
    }

    final action = _resolver.resolve(
      dx: _dragOffset.dx,
      dy: _dragOffset.dy,
      velocityX:
          details.velocity.pixelsPerSecond.dx,
      velocityY:
          details.velocity.pixelsPerSecond.dy,
    );

    await _handleAction(action);
  }

  Future<void> _handleAction(
    TriageGestureAction action,
  ) async {
    if (_handlingAction || !widget.enabled) {
      return;
    }

    _handlingAction = true;

    switch (action) {
      case TriageGestureAction.cancel:
        await _animateBack();

      case TriageGestureAction.favorite:
        await _performDecision(
          action: action,
          persist: widget.onFavorite,
        );

      case TriageGestureAction.markForDeletion:
        await _performDecision(
          action: action,
          persist: widget.onMarkForDeletion,
        );

      case TriageGestureAction.organize:
        final persisted = await widget.onOrganize();

        if (!persisted || !mounted) {
          await _animateBack();
          widget.onDecisionAnimationFailed();
          break;
        }

        final width = MediaQuery.sizeOf(context).width;
        final direction =
            _dragOffset.dx >= 0 ? 1.0 : -1.0;

        await _animateTo(
          Offset(direction * width * 1.25, 0),
          duration:
              const Duration(milliseconds: 190),
          curve: Curves.easeInCubic,
        );

        if (mounted) {
          await widget.onDecisionCompleted();
          setState(() {
            _dragOffset = Offset.zero;
          });
        }
    }

    _handlingAction = false;
  }

  Future<void> _performDecision({
    required TriageGestureAction action,
    required Future<bool> Function() persist,
  }) async {
    final persisted = await persist();

    if (!persisted || !mounted) {
      await _animateBack();
      widget.onDecisionAnimationFailed();
      return;
    }

    final size = MediaQuery.sizeOf(context);
    final target = switch (action) {
      TriageGestureAction.favorite =>
        Offset(
          _dragOffset.dx * 0.25,
          size.height * 0.95,
        ),
      TriageGestureAction.markForDeletion =>
        Offset(
          _dragOffset.dx * 0.25,
          -size.height * 0.95,
        ),
      _ => Offset.zero,
    };

    await _animateTo(
      target,
      duration: const Duration(milliseconds: 190),
      curve: Curves.easeInCubic,
    );

    if (mounted) {
      await widget.onDecisionCompleted();
      setState(() {
        _dragOffset = Offset.zero;
      });
    }
  }

  Future<void> _animateBack() {
    return _animateTo(
      Offset.zero,
      duration: const Duration(milliseconds: 210),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _animateTo(
    Offset target, {
    required Duration duration,
    required Curve curve,
  }) async {
    _animationController
      ..stop()
      ..reset()
      ..duration = duration;

    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: curve,
      ),
    );

    await _animationController.forward();

    if (!mounted) {
      return;
    }

    setState(() {
      _dragOffset = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final rotation =
        (_dragOffset.dx / math.max(width, 1)) * 0.08;
    final feedback =
        _feedbackForOffset(_dragOffset);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart:
          widget.enabled ? _onPanStart : null,
      onPanUpdate:
          widget.enabled ? _onPanUpdate : null,
      onPanEnd: widget.enabled ? _onPanEnd : null,
      onPanCancel:
          widget.enabled ? _animateBack : null,
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: rotation,
          child: ClipRRect(
            borderRadius: AppRadius.borderXLarge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ColoredBox(
                  color: Colors.black,
                ),
                widget.child,
                _SwipeFeedbackOverlay(
                  feedback: feedback,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _SwipeFeedback _feedbackForOffset(
    Offset offset,
  ) {
    final progress = math.min(
      1.0,
      math.max(
            offset.dx.abs(),
            offset.dy.abs(),
          ) /
          _resolver.distanceThreshold,
    );

    if (progress < 0.12) {
      return const _SwipeFeedback.none();
    }

    final horizontal =
        offset.dx.abs() >=
        offset.dy.abs() * _resolver.dominanceRatio;
    final vertical =
        offset.dy.abs() >=
        offset.dx.abs() * _resolver.dominanceRatio;

    if (horizontal) {
      return _SwipeFeedback(
        label: 'Organizar',
        icon: Icons.folder_rounded,
        color: AppColors.secondary,
        alignment: offset.dx >= 0
            ? Alignment.centerLeft
            : Alignment.centerRight,
        progress: progress,
      );
    }

    if (vertical && offset.dy < 0) {
      return _SwipeFeedback(
        label: 'Revisar exclusão',
        icon: Icons.close_rounded,
        color: AppColors.destructive,
        alignment: Alignment.bottomCenter,
        progress: progress,
      );
    }

    if (vertical && offset.dy > 0) {
      return _SwipeFeedback(
        label: 'Favoritar',
        icon: Icons.favorite_rounded,
        color: AppColors.favorite,
        alignment: Alignment.topCenter,
        progress: progress,
      );
    }

    return const _SwipeFeedback.none();
  }
}

final class _SwipeFeedback {
  const _SwipeFeedback({
    required this.label,
    required this.icon,
    required this.color,
    required this.alignment,
    required this.progress,
  }) : visible = true;

  const _SwipeFeedback.none()
      : label = '',
        icon = Icons.circle,
        color = Colors.transparent,
        alignment = Alignment.center,
        progress = 0,
        visible = false;

  final String label;
  final IconData icon;
  final Color color;
  final Alignment alignment;
  final double progress;
  final bool visible;
}

class _SwipeFeedbackOverlay extends StatelessWidget {
  const _SwipeFeedbackOverlay({
    required this.feedback,
  });

  final _SwipeFeedback feedback;

  @override
  Widget build(BuildContext context) {
    if (!feedback.visible) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: feedback.alignment,
            end: -feedback.alignment,
            colors: [
              feedback.color.withValues(
                alpha:
                    0.28 * feedback.progress,
              ),
              Colors.transparent,
            ],
          ),
        ),
        child: Align(
          alignment: feedback.alignment,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Opacity(
              opacity: feedback.progress,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: 0.62,
                  ),
                  borderRadius:
                      BorderRadius.circular(999),
                  border: Border.all(
                    color: feedback.color.withValues(
                      alpha: 0.9,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      feedback.icon,
                      size: 20,
                      color: feedback.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      feedback.label,
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
