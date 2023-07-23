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

	public var camGame:FunkinCamera;
	public var camHUD:FunkinCamera;

	public var hud:FlxGroup;

	public var strumLines:Array<StrumLine> = []; // make it a group maybe

	public var eventHandler:EventHandler;

	public var camTarget:FlxObject;

	public override function create() {
		super.create();

		instance = this;

		// SETTING UP PLAYSTATE STUFF
		FlxG.cameras.reset(camGame = new FunkinCamera());

		hud = new FlxGroup();
		hud.camera = camHUD = new FunkinCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor = 0; // transparent
		add(hud);

		camTarget = new FlxObject(0, 0, 2, 2);
		add(camTarget);

		camGame.follow(camTarget, LOCKON, 0.04);


		// SETTING UP CHART RELATED STUFF
		add(stage = Type.createInstance(SONG.stage, []));

		var vocalTracks:Array<String> = [];
		
		for(strLine in SONG.strumLines) {
			var strumLine:StrumLine = null;
			hud.add(strumLine = new StrumLine(FlxG.width * strLine.xPos, 50 + (Note.swagWidth / 2), strLine));
			strumLines.push(strumLine);
			strumLine.visible = strLine.visible;

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

			for(vocalTrack in strLine.vocalTracks) {
				if (!vocalTracks.contains(vocalTrack))
					vocalTracks.push(vocalTrack);
			}

			var requiredNotes = 0;
			for(note in strLine.notes) {
				if (note.type == null) continue;
				requiredNotes += 1;

				// if (note.sustainLength > 10) {
				// 	var curCrochet = SONG.bpmChanges.getTimeForBeat(SONG.bpmChanges.getBeatForTime(note.time) + 1) - note.time;
				// 	requiredNotes += Std.int(note.sustainLength / curCrochet);
				// }
			}

			strumLine.notes.allocate(requiredNotes);

			var i = 0;
			for(note in strLine.notes) {
				if (note.type == null) continue;
				
				var n:Note = Type.createInstance(note.type, [strumLine, note, false]);
				strumLine.notes.members[i++] = n;

				// if (note.sustainLength > 10) {
				// 	var curCrochet = SONG.bpmChanges.getTimeForBeat(SONG.bpmChanges.getBeatForTime(note.time) + 1) - note.time;
				// 	requiredNotes += Std.int(note.sustainLength / curCrochet);
				// }
			}

			strumLine.notes.sortNotes();
		}


		// TODO: countdown
		Conductor.instance.load(SONG.instPath, true, vocalTracks);
		Conductor.instance.bpmChanges = SONG.bpmChanges;

		for(s in strumLines) {
			for(v in s.strLine.vocalTracks) {
				var index = vocalTracks.indexOf(v);
				if (index >= 0)
					s.vocalTracks.push(cast Conductor.instance.sounds.sounds[index+1])
				else
					s.vocalTracks.push(null);
			}
		}

		eventHandler = new EventHandler([for(e in SONG.events) e], onEvent);
		add(eventHandler);

		Conductor.instance.play();
	}

	public override function measureHit() {
		super.measureHit();

		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
	}

	public function onEvent(event:SongEvent) {
		switch(event.type) {
			case ECameraMove(strID):
				var strum = strumLines[strID];
				if (strum != null && strum.character != null) {
					var pos = strum.character.getCameraPosition();
					camTarget.setPosition(pos.x, pos.y);
					pos.put();
				}
		}
		stage.onEvent(event);
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
