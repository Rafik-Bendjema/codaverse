import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/realtimeService.dart';
import 'package:gdg_hack/models/Hackathon.dart';
import 'package:gdg_hack/player.dart';
import 'package:gdg_hack/table.dart';
import 'package:gdg_hack/private_chat_dialog.dart';

class Codavers extends FlameGame with TapDetector, MouseMovementDetector {
  final Hackathon hackathon;
  late Player mainPlayer;
  final List<TableBlock> tables = [];
  final List<Player> playgroundPlayers = [];
  TextComponent? hoverText;
  Player? hoveredPlayer;
  final BuildContext context;
  late RealtimePositionService realtimeService;
  String? mainPlayerId;

  final Function(String senderId, String message) _handleIncomingMessage;

  Codavers({
    required this.hackathon,
    required this.context,
    required Function(String senderId, String message) messageHandler,
  })  : _handleIncomingMessage = messageHandler,
        super();

  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    super.onLoad();

    realtimeService = RealtimePositionService();

    mainPlayerId = await realtimeService.createNewPlayer();
    print("Codavers: mainPlayerId after createNewPlayer: $mainPlayerId");
    if (mainPlayerId == null) {
      print("Codavers Error: Could not create a unique player ID.");
      return;
    }

    final background = SpriteComponent()
      ..sprite = await loadSprite('bg.png')
      ..size = size
      ..position = Vector2.zero();
    add(background);

    for (var i = 0; i < hackathon.teams.length; i++) {
      tables.add(TableBlock(team: hackathon.teams[i]));
    }
    _generateTables();

    mainPlayer = Player(id: mainPlayerId!, name: "You", role: "player")
      ..position =
          tables.isNotEmpty ? tables[0].position.clone() : Vector2.zero();
    add(mainPlayer);

    realtimeService.updatePlayerPosition(mainPlayerId, mainPlayer.position);

    realtimeService.listenForPlayerPositions((playerId, position, playerName) {
      if (playerId == mainPlayerId) return;
      final index = playgroundPlayers.indexWhere((p) => p.id == playerId);
      if (index != -1) {
        playgroundPlayers[index].position = position;
      } else {
        final newPlayer = Player(id: playerId, name: playerName, role: "player")
          ..position = position;
        playgroundPlayers.add(newPlayer);
        add(newPlayer);
      }
    });

    hoverText = TextComponent(
      text: "",
      textRenderer:
          TextPaint(style: const TextStyle(color: Colors.white, fontSize: 16)),
      anchor: Anchor.center,
      position: Vector2.zero(),
    );
    add(hoverText!);
    hoverText!.removeFromParent();

    if (mainPlayerId != null) {
      realtimeService.listenForChatMessages(mainPlayerId!, 'NONE',
          (ChatMessage chatMessage) {
        _handleIncomingMessage(chatMessage.senderId, chatMessage.message);
      });
      print(
          "Codavers: Chat message listener started for notifications (player ID: $mainPlayerId)");
    } else {
      print(
          "Codavers Error: mainPlayerId is null, cannot start chat message listener for notifications.");
    }
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

  void _showPlayerDialog(Player clickedPlayer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PrivateChatDialog(
          recipientPlayer: clickedPlayer,
          senderPlayerId: mainPlayerId!,
          realtimeService: realtimeService,
          allPlayers: playgroundPlayers,
        );
      },
    );
  }

  @override
  void onTapDown(TapDownInfo info) {
    Vector2 tapPosition = info.eventPosition.widget;

    for (var player in playgroundPlayers) {
      if (player.toRect().contains(tapPosition.toOffset())) {
        if (player != mainPlayer) {
          _showPlayerDialog(player);
          return;
        }
      }
    }

    bool tappedOnTable =
        tables.any((table) => table.toRect().contains(tapPosition.toOffset()));
    if (!tappedOnTable) {
      print("Tapped at: ${tapPosition.x}, ${tapPosition.y}");
      realtimeService.updatePlayerPosition(mainPlayerId, mainPlayer.position);
      mainPlayer.moveTo(tapPosition, realtimeService);
    }
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
          hoverText!.position = player.position + Vector2(0, -30);
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
