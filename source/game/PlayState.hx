package game;

import game.modes.GameModeHandler;
import game.modcharts.HScriptModchart;
import game.modcharts.ModchartGroup;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import menus.FreeplayState;
import flixel.FlxSubState;
import menus.PauseSubState;
import flixel.path.FlxPathfinder.FlxTypedPathfinder;
import flixel.text.FlxText;
import flixel.group.FlxGroup;
import game.stages.Stage;
import assets.chart.Chart;
import flixel.FlxCamera;
import flixel.FlxG;
import game.characters.presets.Character;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';

	public static var SONG:Chart;
	public static var songName:String;
	public static var difficulty:String;

	public static var daPixelZoom:Float = 6;
	public static var campaignScore:Int = 0;

	public static var instance:PlayState;

	public var stage:Stage;

	public var camGame:FunkinCamera;
	public var camHUD:FunkinCamera;

	public var hud:FlxGroup;
	public var scoreTxt:FlxText;
	public var healthBar:HealthBar;
	public var ratings:RatingGroup;

	public var strumLines:FlxTypedGroup<StrumLine> = new FlxTypedGroup<StrumLine>(); // make it a group maybe

	public var eventHandler:EventHandler;
	public var stats:GameStats;

	public var camTarget:FlxObject;

	public var canPause:Bool = true;
	public var songEnding:Bool = false;

	public var health(default, set):Float = 0.5;

	public var modchartHandler:ModchartGroup;

	public var gameMode:GameModeHandler;

	public static function load(songName:String, songDifficulty:String, gameMode:GameModeHandler) {
        PlayState.SONG = Chart.loadFrom(songName, songDifficulty); // TODO
        PlayState.songName = songName;
        PlayState.difficulty = songDifficulty;
		FlxG.switchState(new PlayState(gameMode));
	}

	public function new(gameMode:GameModeHandler) {
		super();
		this.gameMode = gameMode;
	}

	public override function create() {
		if (SONG.cutscene != null && SONG.cutscene != CNone)
			FlxTransitionableState.skipNextTransIn = true; // TODO: custom transition system

		modchartHandler = new ModchartGroup();
		add(modchartHandler);

		super.create();

		instance = this;

		// SETTING UP PLAYSTATE STUFF
		loadStats();

		FlxG.cameras.reset(camGame = new FunkinCamera());

		hud = new FlxGroup();
		hud.camera = camHUD = new FunkinCamera();
		FlxG.cameras.add(camHUD, false);
		camHUD.bgColor = 0; // transparent
		add(hud);

		loadHUD();

		camTarget = new FlxObject(0, 0, 2, 2);
		add(camTarget);

		camGame.follow(camTarget, LOCKON, 0.04);




		// SETTING UP CHART RELATED STUFF
		loadStage();
		loadModcharts();

		modchartHandler.create();

		loadChart();

		eventHandler = new EventHandler([for(e in SONG.events) e], onEvent);
		add(eventHandler);


		Conductor.instance.onFinished.addOnce(playEndCutscene);
		Conductor.instance.songPosition = -Conductor.instance.bpmChanges[0].crochet * 5;
		persistentUpdate = true;

		loadPrecachedAssets();
	}
 
	function loadStage() {
		add(stage = Type.createInstance(SONG.stage, []));
	}
	function loadHUD() {
		hud.add(healthBar = new HealthBar());
		hud.add(scoreTxt = new ScoreText(stats));
	}
	function loadModcharts() {
		for(m in SONG.modcharts) {
			switch(m) {
				case SClass(cl):
					modchartHandler.modcharts.push(Type.createInstance(cl, []));
				case SHScript(path):
					modchartHandler.modcharts.push(new HScriptModchart(path));
				default:
					// nuh uh
			}
		}
	}
	function loadStats() {
		stats = new GameStats();
	}
	function loadChart() {
		var vocalTracks:Array<String> = [];

		for(strLine in SONG.strumLines) {
			var strumLine:StrumLine = null;
			strumLines.add(strumLine = new StrumLine(FlxG.width * strLine.xPos, 50 + (Note.swagWidth / 2), strLine));
			strumLine.visible = strLine.visible;

			if (strLine.character != null) {
				if (stage.characterGroups.exists(strLine.character.position)) {
					var grp = stage.characterGroups.get(strLine.character.position);
					var char:Character = Type.createInstance(strLine.character.character, [0, 0, grp.flip, strumLine]);
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

				if (note.sustainLength > 1) {
					var curCrochet = SONG.bpmChanges.getTimeForBeat(SONG.bpmChanges.getBeatForTime(note.time) + 1) - note.time;
					requiredNotes += Math.ceil(note.sustainLength / curCrochet);
				}
			}

			strumLine.notes.allocate(requiredNotes);

			var i = 0;
			var n:Note = null;

			for(note in strLine.notes) {
				if (note.type == null) continue;

				n = Type.createInstance(note.type, [strumLine, note, false]);
				strumLine.notes.members[i++] = n;

				if (note.sustainLength > 1) {
					var curCrochet:Float = (SONG.bpmChanges.getTimeForStep(SONG.bpmChanges.getStepForTime(note.time) + 1) - note.time);
					var am = Math.ceil(note.sustainLength / curCrochet);
					for(index in 1...am) {
						n = Type.createInstance(note.type, [strumLine, note, true, index * curCrochet, curCrochet, false]);
						strumLine.notes.members[i++] = n;
					}
					n = Type.createInstance(note.type, [strumLine, note, true, (am-1) * curCrochet, curCrochet, true]);
					strumLine.notes.members[i++] = n;
				}
			}

			var old:Note = null;
			for(n in strumLine.notes.members) {
				if (old != null) {
					old.nextNote = n;
					n.prevNote = old;
				}
				old = n;
			}

			strumLine.notes.sortNotes();

			#if debug
			FlxG.debugger.track(strumLine, 'Strumline #${strumLines.length} - ${strLine.character != null ? Type.getClassName(strLine.character.character).replace("game.characters.", null) : "(No char)"}');
			#end
		}

		hud.add(strumLines);


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
	}
	function loadPrecachedAssets() {
		for(i in 0...4) {
			var s = Paths.sound('game/ui/intro/${SONG.countdownSkin}/intro${i}');
			if (Assets.exists(s))
				FlxG.sound.cache(s);

			var p = Paths.image('game/ui/intro/${SONG.countdownSkin}/intro${i}');
			if (Assets.exists(p))
				FlxG.bitmap.add(p);
		}
	}

	function playEndCutscene() {
		Conductor.instance.stop();
		Conductor.instance.unload();
		songEnding = true;
		playCutscene(SONG.endCutscene, true);
		if (subState == null || !(subState is Cutscene)) {
			onSongFinished();
		}
	}

	public override function postCreate() {
		playCutscene(SONG.cutscene);
		modchartHandler.postCreate();
	}

	function playCutscene(cutscene:ChartCutscene, out:Bool = false) {
		if (gameMode.playCutscenes && cutscene != null) {
			switch(cutscene) {
				case CVideo(path):
					openSubState(new game.cutscenes.VideoCutscene(Paths.video(path)));
					if (out)
						FlxTransitionableState.skipNextTransOut = true;
				default:
					// nothing
			}
		}
	}

	public function onSongFinished() {
		// TODO: story progression & stuff
		modchartHandler.onSongFinished();

		gameMode.saveScore();
		gameMode.onSongFinished();
	}

	public override function stepHit() {
		super.stepHit();
		modchartHandler.stepHit(curStep);
	}

	public override function measureHit() {
		super.measureHit();
		modchartHandler.measureHit(curMeasure);

		FlxG.camera.zoom += 0.015;
		camHUD.zoom += 0.03;
	}

	public function onEvent(event:SongEvent) {
		switch(event.type) {
			case ECameraMove(strID):
				var strum = strumLines.members[strID];
				if (strum != null && strum.character != null) {
					var pos = strum.character.getCameraPosition();
					camTarget.setPosition(pos.x, pos.y);
					camGame.follow(camTarget, LOCKON, 0.04);
					pos.put();
				}
			default:
		}
		modchartHandler.onEvent(event);
		stage.onEvent(event);
	}

	public override function beatHit() {
		super.beatHit();
		modchartHandler.beatHit(curBeat);

		if (curBeat < 0) {
			var s = Paths.sound('game/ui/intro/${SONG.countdownSkin}/intro${Math.abs(curBeat) - 1}');
			if (Assets.exists(s))
				FlxG.sound.play(s);

			var p = Paths.image('game/ui/intro/${SONG.countdownSkin}/intro${Math.abs(curBeat) - 1}');
			if (Assets.exists(p)) {
				var spr = new FlxSprite().loadGraphic(p);
				spr.screenCenter();
				spr.antialiasing = true;
				spr.cameras = [camHUD];
				hud.add(spr);
				FlxTween.tween(spr, {alpha: 0}, Conductor.instance.bpmChanges[0].crochet * 0.001, {
					onComplete: function(_) {
						hud.remove(spr, true);
						spr.destroy();
					}
				});
			}
		}

		for(cGrp in stage.characterGroups) for(m in cGrp.members) {
			if (m == null) continue;
			if (m is Character)
				cast(m, Character).dance(curBeat, false);
		}

		healthBar?.beatHit(curBeat);
	}

	public override function update(elapsed:Float) {
		if (subState is Cutscene) {
			super.update(elapsed);
			return;
		}

		if (!Conductor.instance.playing) {
			if (Conductor.instance.songPosition	< 0) {
				Conductor.instance.songPosition += elapsed * 1000;
				Conductor.instance.updateConductor();
			} else {
				Conductor.instance.play(true, false);
			}
		}

		super.update(elapsed);

		FlxG.camera.zoom = CoolUtil.fLerp(FlxG.camera.zoom, stage.camZoom, 0.05);
		camHUD.zoom = CoolUtil.fLerp(camHUD.zoom, 1, 0.05);
		if (Controls.justPressed.PAUSE && canPause)
			pause();
	}

	public function pause() {
		modchartHandler.onPause();
		persistentUpdate = false;
		Conductor.instance.pause();
		openSubState(new PauseSubState());
	}

	override function closeSubState() {
		if (subState is PauseSubState) {
			// resume game
			Conductor.instance.resume();
		} else if (subState is Cutscene && songEnding) {
			onSongFinished();
		}
		super.closeSubState();
	}

	public function onHealthChange() {
		healthBar?.updateBar();

		if (health <= 0 && !(subState is GameOverSubstate)) {
			// death >:(
			Conductor.instance.stop();
			openSubState(new GameOverSubstate());
			persistentUpdate = false;
			persistentDraw = false;
		}
		modchartHandler.onHealthChange();
	}

	private inline function set_health(v:Float) {
		health = FlxMath.bound(v, 0, 1);
		onHealthChange();
		return health;
	}
}
