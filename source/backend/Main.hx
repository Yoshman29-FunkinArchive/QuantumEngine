package backend;

import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
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
		addChild(new backend.FPS(10, 3, 0xFFFFFF));
		#end
		
		// initiating backend shit
		PlayerSettings.init();
		FlxG.save.bind('funkin', 'ninjamuffin99');
		Highscore.load();
		configureOof();


		FlxG.switchState(new TitleState());
	}

	public function configureOof() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
	}
}
