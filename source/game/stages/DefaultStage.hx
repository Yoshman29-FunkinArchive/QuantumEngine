package game.stages;

@:keep
class DefaultStage extends Stage {
	var bg:FlxSprite;
	var stageFront:FlxSprite;
	var stageCurtains:FlxSprite;

	public override function create() {
		prefix = "game/stages/default/";
		super.create();

		camZoom = 0.9;

		bg = new FlxSprite(-600, -200).loadGraphic(Paths.image(p('back')));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image(p('front')));
		stageFront.scale.set(1.1, 1.1);
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		addCharGroup(400, 130, "girlfriend", false, 0.95, 0.95);

		stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image(p('curtains')));
		stageCurtains.scale.set(0.9, 0.9);
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;
		add(stageCurtains);

		addCharGroup(100, 100, "opponent");
		addCharGroup(770, 100, "player", true);
	}
}