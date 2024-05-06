package game.characters;

@aliases("bf-dead")
class BoyfriendDead extends SpriteCharacter {
	public function new(x:Float, y:Float, flip:Bool, parent:StrumLine) {
		super(x, y, flip, parent);
		scale.x *= -1; // bf is flipped
		antialiasing = true;
		this.loadFrames('game/characters/bf-dead');

		offset.set(0, -350);
	}

	public override function playDanceAnim(beat:Int) {
		animation.play("dance-idle", true);
	}
}