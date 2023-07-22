package game;

import flixel.group.FlxGroup;
import game.stages.Stage;
import assets.chart.Chart;
import flixel.FlxCamera;
import flixel.FlxG;
import game.characters.Character;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	// public static var SONG:SwagSong;
	public static var SONG:Chart;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var daPixelZoom:Float = 6;
	public static var campaignScore:Int = 0;

	public static var instance:PlayState;

	public var stage:Stage;

	public var camHUD:FlxCamera;

	public var hud:FlxGroup;

	public override function create() {
		super.create();

		instance = this;

		add(stage = Type.createInstance(SONG.stage, []));

		hud = new FlxGroup();
		hud.camera = camHUD = new FlxCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor = 0; // transparent
		add(hud);
		
		for(strLine in SONG.strumLines) {
			var strumLine:StrumLine = null;
			if (strLine.visible) {
				hud.add(strumLine = new StrumLine(FlxG.width * strLine.xPos, 50 + (Note.swagWidth / 2), strLine.cpu));
			}

			if (strLine.character != null) {
				if (stage.characterGroups.exists(strLine.character.position)) {
					var grp = stage.characterGroups.get(strLine.character.position);
					var char:Character = Type.createInstance(strLine.character.character, [0, 0, grp.flip]);
					grp.add(char._);
					char._.setPosition(grp.x, grp.y);
					char._.scrollFactor.x *= grp.scrollX;
					char._.scrollFactor.y *= grp.scrollY;

					if (strumLine != null)
						strumLine.character = char;
				} else {
					FlxG.log.error('CHART ERROR: Character position "${strLine.character.position}" not found in stage ${Type.getClassName(SONG.stage)}');
				}
			}
		}


		// TODO: countdown
		Conductor.instance.load(SONG.instPath);
		Conductor.instance.bpmChanges = SONG.bpmChanges;

		Conductor.instance.play();
	}

	public override function measureHit() {
		super.measureHit();

		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
	}

	public override function beatHit() {
		super.beatHit();

		for(cGrp in stage.characterGroups) for(m in cGrp.members) {
			if (m == null) continue;
			if (m is Character)
				cast(m, Character).dance(curBeat, false);
		}
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.camera.zoom = CoolUtil.fLerp(FlxG.camera.zoom, stage.camZoom, 0.05);
		camHUD.zoom = CoolUtil.fLerp(camHUD.zoom, 1, 0.05);
	}
}
