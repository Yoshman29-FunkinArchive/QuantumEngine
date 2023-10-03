package menus;

import game.PlayState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.sound.FlxSound;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
	var curSelected:Int = 0;
	// separate conductor so that pause menu supports bpm for funky pause menus and the game one is untouched
	var conductor:Conductor;

	var cam:FlxCamera;

	public function new()
	{
		super();

		conductor = new Conductor();
		conductor.onBeat.add((_) -> beatHit());
		conductor.onStep.add((_) -> stepHit());
		conductor.onMeasure.add((_) -> measureHit());
		add(conductor);

		conductor.loadAndPlay('menus/pause/breakfast', true);
		conductor.sounds.sounds[0].volume = 0;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cam = new FlxCamera(0, 0);
		cam.bgColor = 0;
		FlxG.cameras.add(cam, false);

		cameras = [cam];
	}

	override function update(elapsed:Float)
	{
		if (conductor.sounds.sounds[0].volume < 0.5)
			conductor.sounds.sounds[0].volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = Controls.justPressed.UP;
		var downP = Controls.justPressed.DOWN;
		var accepted = Controls.justPressed.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					PlayState.instance.gameMode.restartSong();
				case "Exit to menu":
					FlxG.switchState(new MainMenuState());
			}
		}
	}

	override function destroy()
	{
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i => item in grpMenuShit.members)
		{
			item.targetY = i - curSelected;

			if (item.targetY == 0) {
				item.alpha = 1;
			} else {
				item.alpha = 0.6;
			}
		}
	}
}
