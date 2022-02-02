import 'package:camplux/ui/custom_painters/particles/model.dart';
import 'package:flutter/material.dart';

/// {@template particle_painter}
///The CustomPainter for the particles
///{@endtemplate}
class ParticlesPainter extends CustomPainter {
  ///{@macro particle_painter}
  ParticlesPainter(this.anim, {this.particlesCount = 20})
      : super(repaint: anim);

  ///The amount of particles to create
  final int particlesCount;

  ///The animations that drives the particle frame update
  final AnimationController anim;

  ///The particles created and active
  final List<Particle> particles = [];

  ///Determines if a new particle should replace a dead one
  bool createNewParticle = true;

  ///This boolean initializes the particles and ensures that its done only once
  var _isInit = false;

  Particle _particle(Size size) {
    return Particle.random(
      size,
      onDie: (particle) {
        if (!createNewParticle) return;

        ///Ensures a particle isn't being rendered while being removed
        ///This prevents jitters in the particles
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          particles
            ..remove(particle)
            ..add(_particle(size));
        });
      },
    );
  }

  /// Creates particle instances and adds the m to the particles array
  void init(Size size) {
    _isInit = true;
    for (var i = 0; i < particlesCount; i++) {
      particles.add(_particle(size));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (particles.isEmpty && particlesCount < 1) return;
    if (!_isInit) {
      init(size);
    }
    for (final particle in particles) {
      particle.paintParticle(canvas, size);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}
