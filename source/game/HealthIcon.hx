package game;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public var iconHealth(default, set):Float = 0.5;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		var imgPath = Paths.image('game/icons/${char}');
		if (!Assets.exists(imgPath))
			imgPath = Paths.image('game/icons/face');
		loadGraphic(imgPath, true, 150, 150);

		antialiasing = true;
		animation.add(char, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
		animation.play(char);
	}

	private function set_iconHealth(iconHealth:Float) {
		if (this.iconHealth != (this.iconHealth = iconHealth)) {
			if (iconHealth < 0.2)
				animation.curAnim.curFrame = 1;
			else if (animation.curAnim.frames.length > 2 && iconHealth > 0.8)
				animation.curAnim.curFrame = 2;
			else 
				animation.curAnim.curFrame = 0;
		}
		return this.iconHealth;
	}
}
