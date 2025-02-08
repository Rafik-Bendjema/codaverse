import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/realtimeService.dart';

class Player extends SpriteComponent with HasGameRef<FlameGame> {
  final String id;
  String name;
  String role;

  Player({required this.id, required this.name, required this.role})
      : super(size: Vector2(30, 60));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('$role.png');
  }

  /// Move the player to a target position with a smooth effect.
  /// Once movement completes, update the realtime database.
  void moveTo(Vector2 target, RealtimePositionService realtimeService) {
    add(
      MoveEffect.to(
        target,
        EffectController(duration: 0.5, curve: Curves.easeOut),
        onComplete: () {
          realtimeService.updatePlayerPosition(id, target);
        },
      ),
    );
  }
}
