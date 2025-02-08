import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:gdg_hack/models/Team.dart';

class TableBlock extends SpriteComponent with HasGameRef<FlameGame> {
  Team team;

  TableBlock({required this.team}) : super(size: Vector2(50, 50));

  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('table${team.members.length}.png');
  }
}
