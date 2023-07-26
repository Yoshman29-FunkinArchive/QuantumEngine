package game;
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
	public var scoreTxt:FlxText;
	public var healthBar:HealthBar;

	public var strumLines:FlxTypedGroup<StrumLine> = new FlxTypedGroup<StrumLine>(); // make it a group maybe

	public var eventHandler:EventHandler;
	public var stats:GameStats;

	public var camTarget:FlxObject;

	public var canPause:Bool = true;

	public var health(default, set):Float = 0.5;

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

		scoreTxt = new FlxText(0, (FlxG.height * 0.9) + 30, FlxG.width, "Score:0 - Misses:0 - Accuracy: 100%", 16);
		scoreTxt.font = Paths.font('fonts/vcr');
		scoreTxt.alignment = CENTER;
		scoreTxt.borderSize = 1;
		scoreTxt.borderColor = 0xFF000000;
		scoreTxt.borderStyle = OUTLINE;

		hud.add(healthBar = Type.createInstance(SONG.healthBar, []));
		hud.add(scoreTxt);

		camTarget = new FlxObject(0, 0, 2, 2);
		add(camTarget);

		camGame.follow(camTarget, LOCKON, 0.04);




		// SETTING UP CHART RELATED STUFF
		add(stage = Type.createInstance(SONG.stage, []));

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
						n = Type.createInstance(note.type, [strumLine, note, true, index * curCrochet, curCrochet, index == am-1]);
						strumLine.notes.members[i++] = n;
					}
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

		eventHandler = new EventHandler([for(e in SONG.events) e], onEvent);
		add(eventHandler);

		stats = new GameStats();
		stats.onChange.add((_) -> updateScore());
		updateScore();

		Conductor.instance.onFinished.addOnce(onSongFinished);
		Conductor.instance.play();
		persistentUpdate = true;
	}

	public function onSongFinished() {
		// TODO: story progression & stuff
		FlxG.switchState(new FreeplayState());
	}

	public function updateScore() {
		scoreTxt.text = stats.toString();
	}

	public override function measureHit() {
		super.measureHit();

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

		healthBar?.beatHit(curBeat);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		FlxG.camera.zoom = CoolUtil.fLerp(FlxG.camera.zoom, stage.camZoom, 0.05);
		camHUD.zoom = CoolUtil.fLerp(camHUD.zoom, 1, 0.05);

		if (Controls.justPressed.PAUSE && canPause)
			pause();
	}

	public function pause() {
		persistentUpdate = false;
		Conductor.instance.pause();
		openSubState(new PauseSubState());
	}

	override function closeSubState() {
		if (subState is PauseSubState) {
			// resume game
			Conductor.instance.resume();
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
	}

	private inline function set_health(v:Float) {
		health = FlxMath.bound(v, 0, 1);
		onHealthChange();
		return health;
	}
}
