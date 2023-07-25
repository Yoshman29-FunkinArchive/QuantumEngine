package game.strums;

class DefaultStrum extends Strum {
	public override function create() {
		super.create();

		this.loadFrames('game/notes/default');

		animation.rename("static" + id, "static");
		animation.rename("pressed" + id, "pressed");
		animation.rename("confirm" + id, "confirm");

		scale.set(0.7, 0.7);
		updateHitbox();

		antialiasing = true;
	}
}