import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class Player extends SpriteComponent with HasGameRef<FlameGame> {
  String name;
  String role;
  Player({required this.name, required this.role})
      : super(size: Vector2(30, 60));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('$role.png');
  }

  void moveTo(Vector2 target) {
    target.y -= 110; // Lock player at the bottom
    // target.x = gameRef.size.x - size.x - 20;
    add(
      MoveEffect.to(
        target,
        EffectController(duration: 0.5, curve: Curves.easeOut), // Smooth move
      ),
    );
  }
}
