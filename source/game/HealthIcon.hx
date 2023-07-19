package game;

import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
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
		scrollFactor.set();
	}
}
