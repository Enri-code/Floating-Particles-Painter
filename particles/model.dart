import 'dart:async';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

///Particle Function
typedef ParticleCallback = void Function(Particle);

/// {@template particle}
/// A particle class for spawning particles using a ParticlePainter
///
/// Extend this class and override its [drawParticle] function to
/// create your own shape
/// {@endtemplate}
// ignore: must_be_immutable
class Particle extends Equatable {
  /// {@macro particle}
  Particle({
    required this.radius,
    required this.position,
    required this.direction,
    required this.timer,
    required this.paint,
    required this.onDie,
  });

  /// This creates a particle with random properties
  factory Particle.random(
    Size boundary, {
    Color? color,
    Duration? lifeSpan,
    ParticleCallback? onDie,
  }) {
    return Particle(
      position: Offset(
        _random.nextDouble() * boundary.width,
        _random.nextDouble() * boundary.height,
      ),
      direction: Offset(
        _random.nextDouble() - 0.5,
        _random.nextDouble() - 0.5,
      ),
      radius: _random.nextDouble() * 12 + 6,
      timer: Timer(
        lifeSpan ?? Duration(milliseconds: _random.nextInt(5000) + 6000),
        () {},
      ),
      paint: Paint()
        ..color = color ??
            Color.lerp(
              Color.lerp(Colors.white, Colors.blue, _random.nextDouble()),
              Colors.pink,
              _random.nextDouble(),
            )!
                .withOpacity(0),
      onDie: onDie,
    );
  }

  static final _random = math.Random();

  ///The radius of the particle
  final double radius;

  /// This counts the amount of time that the paricle will be active
  final Timer timer;

  ///The paint properties for rendering the particle
  final Paint paint;

  ///Callback function for when the particle's lifetime ends
  final ParticleCallback? onDie;

  ///The position in pixels that the particle begins at
  Offset position;

  ///The amount of pixels to move in the x and y axis for the next frame
  Offset direction;

  ///Determines if the particles should bounce in its container or exit
  bool canExitContainer = false;

  ///Moves particle to its next position for the next frame
  void _moveParticle(Size boundary) {
    position += direction;
    if (canExitContainer) return;

    ///This checks if the particle is at the edge of the counary and
    ///inverts its direction if it is
    if ((position.dx < radius && direction.dx.isNegative) ||
        (position.dx > boundary.width - radius && !direction.dx.isNegative)) {
      direction = direction.scale(-1, 1);
    }
    if ((position.dy < radius && direction.dy.isNegative) ||
        (position.dy > boundary.height - radius && !direction.dy.isNegative)) {
      direction = direction.scale(1, -1);
    }
  }

  void drawParticle(Canvas canvas, Size boundary) {
    canvas.drawCircle(position, radius, paint);
  }

  /// Renders the particle using the canvas reference
  void paintParticle(Canvas canvas, Size boundary) {
    drawParticle(canvas, boundary);
    _moveParticle(boundary);
    final opacity = paint.color.opacity;
    if (!timer.isActive) {
      if (opacity <= 0) {
        onDie?.call(this);
      } else {
        paint.color = paint.color.withOpacity((opacity - 0.03).clamp(0, 1));
      }
    } else if (opacity < 1) {
      paint.color = paint.color.withOpacity((opacity + 0.02).clamp(0, 1));
    }
  }

  @override
  List<Object?> get props => [
        radius,
        timer,
        paint,
        onDie,
        position,
        direction,
        canExitContainer,
      ];
}
