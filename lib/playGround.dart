import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:gdg_hack/game.dart';
import 'package:gdg_hack/backend/realtimeService.dart';
import 'package:badges/badges.dart' as badges;

import 'models/Hackathon.dart';
import 'package:gdg_hack/private_chat_dialog.dart';
import 'package:gdg_hack/player.dart';

class Playground extends StatefulWidget {
  final Hackathon hackathon;
  const Playground({super.key, required this.hackathon});

  @override
  State<Playground> createState() => _PlaygroundState();
}

class _PlaygroundState extends State<Playground> {
  late Hackathon _hackathon;
  late Codavers _game;
  int _unreadMessageCount = 0;
  String? _mainPlayerId;

  @override
  void initState() {
    super.initState();
    _hackathon = widget.hackathon;
    _initializeGame();
  }

  void _initializeGame() {
    _game = Codavers(
        hackathon: _hackathon,
        context: context,
        messageHandler: _handleIncomingMessage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _mainPlayerId = _game.mainPlayerId;
      });
    });
  }

  void _updateNotificationCount(int count) {
    setState(() {
      _unreadMessageCount = count;
    });
  }

  void _handleIncomingMessage(String senderId, String message) {
    _updateNotificationCount(_unreadMessageCount + 1);
    String senderName = "Player $senderId";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'New message from $senderName: $message. Tap notification button to view.'),
        duration: const Duration(seconds: 5),
      ),
    );
    print(
        "Playground: Received message from $senderId: $message. Unread count: $_unreadMessageCount");
  }

  void _openPrivateChatSession() {
    if (_game.playgroundPlayers.isNotEmpty && _mainPlayerId != null) {
      Player recipientPlayer = _game.playgroundPlayers.firstWhere(
          (player) => player.id != _mainPlayerId,
          orElse: () => _game.playgroundPlayers.isNotEmpty
              ? _game.playgroundPlayers.first
              : Player(id: 'none', name: 'none', role: 'none'));
      if (recipientPlayer.id != 'none') {
        showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext dialogContext) {
            return PrivateChatDialog(
              recipientPlayer: recipientPlayer,
              senderPlayerId: _mainPlayerId!,
              realtimeService: _game.realtimeService,
              allPlayers: _game.playgroundPlayers,
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No other players available to chat with (excluding yourself).'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No other players available to chat with.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_hackathon.name),
        actions: [
          IconButton(
            onPressed: () {
              _openPrivateChatSession();
              _updateNotificationCount(0);
            },
            icon: badges.Badge(
              badgeContent: Text(
                _unreadMessageCount.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              showBadge: _unreadMessageCount > 0,
              child: const Icon(
                Icons.notifications,
                color: Colors.purpleAccent,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _game == null
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      decoration: const BoxDecoration(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(40))),
                      child: GameWidget(game: _game)),
                ),
              ),
      ),
    );
  }
}
