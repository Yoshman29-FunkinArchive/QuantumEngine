package game.characters;

@id("bf")
class Boyfriend extends SpriteCharacter {
	public function new(x:Float, y:Float, flip:Bool, parent:StrumLine) {
		super(x, y, flip, parent);
		scale.x *= -1; // bf is flipped
		antialiasing = true;
		this.loadFrames('game/characters/bf');

		offset.set(0, -350);
	}
}