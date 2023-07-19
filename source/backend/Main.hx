package backend;

import menus.TitleState;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();

		addChild(new FlxGame(0, 0));

		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
		
		// initiating backend shit
		PlayerSettings.init();
		FlxG.save.bind('funkin', 'ninjamuffin99');
		Highscore.load();


		FlxG.switchState(new TitleState());
	}
}
