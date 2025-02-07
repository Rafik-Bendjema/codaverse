import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'player.dart';
import 'table.dart';

class Codavers extends FlameGame with TapDetector, MouseMovementDetector {
  final Hackathon hackathon;
  late Player mainPlayer;
  final List<TableBlock> tables = [];
  final List<Player> playgroundPlayers = [];
  TextComponent? hoverText;
  Player? hoveredPlayer; // Track the hovered player

  Codavers({required this.hackathon});

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // Load background
    final background = SpriteComponent()
      ..sprite = await loadSprite('bg.jpg')
      ..size = size
      ..position = Vector2.zero();
    add(background);

    // Main player
    mainPlayer = Player(name: "rafik", role: "player")
      ..position = Vector2(size.x - size.x - 20, size.y - size.y - 20);
    add(mainPlayer);

    // Generate tables
    for (var i = 0; i < 6; i++) {
      tables.add(TableBlock(playersAtTable: Random().nextInt(5)));
    }
    _generateTables();

    // Generate 3 random players in playground
    for (var i = 0; i < 3; i++) {
      var randomX = Random().nextDouble() * size.x * 0.8;
      var randomY = Random().nextDouble() * size.y * 0.8;

      var player = Player(
        name: "Player ${i + 1}",
        role: "player",
      )..position = Vector2(randomX, randomY);

      playgroundPlayers.add(player);
      add(player);
    }

    // Add hover text (initially hidden)
    hoverText = TextComponent(
      text: "",
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 16)),
      anchor: Anchor.center,
      position: Vector2.zero(),
    );
    add(hoverText!);
    hoverText!.removeFromParent(); // Hide by default
  }

  void _generateTables() {
    int tableCount = tables.length;
    double xPadding = 70;
    double yPadding = 100;

    int rows = (tableCount / 3).ceil();
    int cols = (tableCount < 2) ? tableCount : 2;
    double tableSize = 60;

    double xSpacing =
        (size.x - (cols * tableSize) - ((cols - 1) * xPadding)) / 2;
    double ySpacing =
        (size.y - (rows * tableSize) - ((rows - 1) * yPadding)) / 3;

    for (int i = 0; i < tableCount; i++) {
      int row = i ~/ cols;
      int col = i % cols;

      double x = xSpacing + col * (tableSize + xPadding);
      double y = ySpacing + row * (tableSize + yPadding);

      tables[i].position = Vector2(x, y);
      add(tables[i]);
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    Vector2 tapPosition = info.eventPosition.global;
    print("Tapped at: ${tapPosition.x}, ${tapPosition.y}");
    mainPlayer.moveTo(tapPosition);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    Vector2 mousePosition = info.eventPosition.global;
    bool hovering = false;

    for (var player in playgroundPlayers) {
      if (player.toRect().contains(mousePosition.toOffset())) {
        if (hoveredPlayer != player) {
          hoveredPlayer = player;
          hoverText!.text = player.name;
          hoverText!.position =
              player.position + Vector2(0, -30); // Above player
          add(hoverText!);
        }
        hovering = true;
        break;
      }
    }

    if (!hovering && hoveredPlayer != null) {
      hoverText!.removeFromParent();
      hoveredPlayer = null;
    }
  }
}
