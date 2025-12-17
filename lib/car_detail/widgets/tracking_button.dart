import 'dart:async';

import 'package:fleet_watch/app/bloc/connectivity_bloc.dart';
import 'package:fleet_watch/car_detail/bloc/car_detail_bloc.dart';
import 'package:fleet_watch/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrackingButton extends StatefulWidget {
  const TrackingButton({required this.isTracking, super.key});

  final bool isTracking;

  @override
  State<TrackingButton> createState() => _TrackingButtonState();
}

class _TrackingButtonState extends State<TrackingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    unawaited(_controller.repeat(reverse: true));
    _animation = Tween<double>(
      begin: 0,
      end: 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, connectivityState) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: widget.isTracking
                    ? Offset(0, -_animation.value)
                    : Offset.zero,
                child: Container(
                  decoration: widget.isTracking
                      ? BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        )
                      : null,
                  child: widget.isTracking
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: theme.colorScheme.primary),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size.fromHeight(56),
                            backgroundColor: theme.colorScheme.surface,
                          ),
                          onPressed: connectivityState.isOnline
                              ? () => context.read<CarDetailBloc>().add(
                                  const ToggleTracking(),
                                )
                              : null,
                          child: Text(l10n.stopTracking),
                        )
                      : FilledButton(
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size.fromHeight(56),
                          ),
                          onPressed: connectivityState.isOnline
                              ? () => context.read<CarDetailBloc>().add(
                                  const ToggleTracking(),
                                )
                              : null,
                          child: Text(l10n.startTracking),
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
