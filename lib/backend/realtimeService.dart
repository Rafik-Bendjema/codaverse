import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flame/components.dart';

class RealtimePositionService {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<String?> createNewPlayer() async {
    User? user = auth.currentUser;
    if (user == null) {
      print("RealtimeService: User not logged in.");
      return null;
    }
    String userId = user.uid;

    try {
      final playerRef = database.ref("playground/players/$userId");
      final snapshot = await playerRef.get();

      if (snapshot.exists) {
        print(
            "RealtimeService: Player entry exists for user ID: $userId. Reusing.");
        await playerRef
            .update({"timestamp": DateTime.now().millisecondsSinceEpoch});
      } else {
        print(
            "RealtimeService: Creating new player entry for user ID: $userId.");
        await playerRef.set({
          "x": 0.0,
          "y": 0.0,
          "timestamp": DateTime.now().millisecondsSinceEpoch,
          "name": "Player_${userId.substring(0, 5)}",
        });
      }
      return userId;
    } catch (e) {
      print("RealtimeService Error creating player data: $e");
      return null;
    }
  }

  Future<void> updatePlayerPosition(String? playerId, Vector2 position) async {
    if (playerId == null) {
      print("RealtimeService Error: Player ID is null in updatePlayerPosition");
      return;
    }
    try {
      await database.ref("playground/players/$playerId").update({
        "x": position.x,
        "y": position.y,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      print("RealtimeService Error updating player position in Firebase: $e");
    }
  }

  void listenForPlayerPositions(
      void Function(String, Vector2, String) onPositionUpdate) {
    database.ref("playground/players").onValue.listen((event) {
      final data = event.snapshot.value;
      if (data != null && data is Map) {
        data.forEach((key, value) {
          if (value is Map) {
            final x = (value["x"] as num).toDouble();
            final y = (value["y"] as num).toDouble();
            final name = value["name"] as String? ?? "Unknown Player";
            onPositionUpdate(key.toString(), Vector2(x, y), name);
          }
        });
      }
    }, onError: (error) {
      print(
          "RealtimeService Error in listenForPlayerPositions listener: $error");
    });
  }

  Future<void> sendMessage(
      String recipientPlayerId, String senderPlayerId, String message) async {
    try {
      final messagesRef =
          database.ref("playground/messages/$recipientPlayerId");
      await messagesRef.push().set({
        "senderId": senderPlayerId,
        "message": message,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
      print(
          "RealtimeService: Message sent successfully to player: $recipientPlayerId");
    } catch (e) {
      print("RealtimeService Error sending message to Firebase: $e");
    }
  }

  void listenForMessages(String recipientPlayerId,
      void Function(String senderId, String message) onMessageReceived) {
    database.ref("playground/messages/$recipientPlayerId").onChildAdded.listen(
        (event) {
      final messageData = event.snapshot.value;
      if (messageData != null && messageData is Map) {
        final senderId = messageData["senderId"] as String? ?? "Unknown Sender";
        final message = messageData["message"] as String? ?? "";
        if (message.isNotEmpty) {
          onMessageReceived(senderId, message);
        }
      }
    }, onError: (error) {
      print("RealtimeService Error in listenForMessages listener: $error");
    });
  }

  Future<void> sendChatMessage(
      String recipientPlayerId, String senderPlayerId, String message) async {
    try {
      final chatRef = database.ref("playground/chat_messages");
      await chatRef.push().set({
        "senderId": senderPlayerId,
        "recipientId": recipientPlayerId,
        "message": message,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      });
      print(
          "RealtimeService: Chat message sent from $senderPlayerId to $recipientPlayerId");
    } catch (e) {
      print("RealtimeService Error sending chat message: $e");
    }
  }

  void listenForChatMessages(String currentPlayerId, String otherPlayerId,
      void Function(ChatMessage) onMessageReceived) {
    database
        .ref("playground/chat_messages")
        .orderByChild("timestamp")
        .onChildAdded
        .listen((event) {
      final messageData = event.snapshot.value;
      if (messageData != null && messageData is Map) {
        final message = ChatMessage.fromMap(messageData);
        if ((message.senderId == currentPlayerId &&
                message.recipientId == otherPlayerId) ||
            (message.senderId == otherPlayerId &&
                message.recipientId == currentPlayerId) ||
            otherPlayerId == 'NONE' ||
            otherPlayerId == 'none') {
          onMessageReceived(message);
        }
      }
    }, onError: (error) {
      print("RealtimeService Error in listenForChatMessages listener: $error");
    });
  }
}

class ChatMessage {
  final String senderId;
  final String recipientId;
  final String message;
  final int timestamp;

  ChatMessage({
    required this.senderId,
    required this.recipientId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<dynamic, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'] ?? '',
      recipientId: map['recipientId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recipientId': recipientId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}
