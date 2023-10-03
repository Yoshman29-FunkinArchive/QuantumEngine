package game;

import menus.*;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate
{
	var char:Character;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public override function create()
	{
		super.create();

		Conductor.instance.stop();

		var strumLine = PlayState.instance.strumLines.members[0];

		char = Type.createInstance(strumLine.character.gameOverChar, [strumLine.x, strumLine.y, strumLine.character.flipped, strumLine]);
		add(char._);

		var pos = char.getCameraPosition();
		camFollow = new FlxObject(pos.x, pos.y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('game/gameover/gameOverSFX'));

		FlxG.camera.follow(camFollow, LOCKON, 0.01);

		char.playDeathAnim(function() {
			if (!isEnding)
				Conductor.instance.loadAndPlay('game/gameover/gameOver', true);
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Controls.justPressed.ACCEPT && !isEnding)
		{
			isEnding = true;
			char.playDeathConfirmAnim();
			Conductor.instance.loadAndPlay('game/gameover/gameOverEnd');
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					FlxG.switchState(new PlayState(PlayState.instance.gameMode));
				});
			});
		}

		if (Controls.justPressed.BACK)
		{
			Conductor.instance.stop();

			//if (PlayState.isStoryMode)
				//FlxG.switchState(new StoryMenuState());
			//else
				FlxG.switchState(new FreeplayState());
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (!isEnding)
			char.dance(curBeat, false);
	}

	var isEnding:Bool = false;
}
