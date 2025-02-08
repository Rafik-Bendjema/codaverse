import 'package:flutter/material.dart';
import 'package:gdg_hack/backend/realtimeService.dart';
import 'package:gdg_hack/player.dart';

class PrivateChatDialog extends StatefulWidget {
  final Player recipientPlayer;
  final String senderPlayerId;
  final RealtimePositionService realtimeService;
  final List<Player> allPlayers;

  const PrivateChatDialog({
    super.key,
    required this.recipientPlayer,
    required this.senderPlayerId,
    required this.realtimeService,
    required this.allPlayers,
  });

  @override
  _PrivateChatDialogState createState() => _PrivateChatDialogState();
}

class _PrivateChatDialogState extends State<PrivateChatDialog> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    print(
        "PrivateChatDialog: initState - Sender ID: ${widget.senderPlayerId}, Recipient ID: ${widget.recipientPlayer.id}");
    _loadMessages();
  }

  void _loadMessages() {
    // **SINGLE, DIRECTIONAL LISTENER - FOR INCOMING MESSAGES TO CURRENT PLAYER**
    widget.realtimeService.listenForChatMessages(
      widget.recipientPlayer
          .id, // Listen for messages addressed TO the recipient (which is the *current* player in this dialog from the *other* player)
      widget
          .senderPlayerId, // ... coming FROM the sender (the *other* player initiating this chat)
      (ChatMessage message) {
        print(
            "PrivateChatDialog: Message RECEIVED (Incoming): Sender: ${message.senderId}, Recipient: ${message.recipientId}, Message: ${message.message}, Timestamp: ${message.timestamp}");

        // **Filter to ensure we only process messages *intended for this specific chat dialog***
        if (message.senderId ==
                widget.recipientPlayer
                    .id && // Message sender is the *other* player (recipientPlayer of this dialog)
            message.recipientId == widget.senderPlayerId) {
          // Message recipient is the *current* player (senderPlayerId of this dialog)
          print(
              "PrivateChatDialog: Message PASSED Filter (Incoming). Adding to list.");
          setState(() {
            _messages.add(message);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          });
        } else {
          print(
              "PrivateChatDialog: Message FAILED Filter (Incoming). Ignoring.");
        }
      },
    );
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      // **1. Create ChatMessage object for the message being sent:**
      ChatMessage sentMessage = ChatMessage(
        senderId: widget.senderPlayerId,
        recipientId: widget.recipientPlayer.id,
        message: messageText,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // **2. Add the sent message to the local _messages list immediately:**
      setState(() {
        _messages
            .add(sentMessage); // Add to message list to display immediately
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });

      // **3. Send the message to Firebase (keep this part as it is):**
      widget.realtimeService.sendChatMessage(
        widget.recipientPlayer.id,
        widget.senderPlayerId,
        messageText,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Chat with ${widget.recipientPlayer.name}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  print("here is all players ${widget.allPlayers.length}");
                  final message = _messages[index];
                  String senderName = widget.allPlayers.firstWhere(
                      (player) => player.id == message.senderId, orElse: () {
                    print(
                        "PrivateChatDialog: Sender Player NOT FOUND for message senderId: ${message.senderId}. Available player IDs: ${widget.allPlayers.map((p) => p.id).toList()}"); // Log when not found
                    return Player(
                        id: 'unknown', name: 'Unknown Player', role: 'none');
                  }).name;
                  bool isMe = message.senderId == widget.senderPlayerId;

                  print(
                      "PrivateChatDialog: Rendering message - Sender ID: ${message.senderId}, Sender Name: $senderName"); // Log message senderId and name

                  return Align(
                    alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            senderName,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isMe ? Colors.black87 : Colors.black87),
                          ),
                          Text(
                            message.message,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Close', style: TextStyle(color: Colors.blue)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
