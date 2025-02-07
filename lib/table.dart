import 'package:flame/components.dart';
import 'package:flame/game.dart';

class TableBlock extends SpriteComponent with HasGameRef<FlameGame> {
  int playersAtTable;

  TableBlock({required this.playersAtTable}) : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('table$playersAtTable.png');
  }
}
