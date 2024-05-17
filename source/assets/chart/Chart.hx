package assets.chart;

import game.HealthBar;
import game.notes.DefaultNote;
import game.characters.presets.Character;
import game.modcharts.Modchart;
import game.characters.presets.SpriteCharacter;
import game.notes.Note;
import game.SongEvent;
import haxe.Json;
import game.stages.Stage;
import assets.chart.SongMeta.SongMetaData;
import flixel.group.FlxGroup;

class Chart {
	/**
	 * Name of the song.
	 */
	public var song:String;
	/**
	 * Difficulty of the song
	 */
	public var difficulty:String;


	/**
	 * Stage used in this song
	 */
	public var stage:ClassReference<Stage>;

	/**
	 * Stage used in this song
	 */
	public var modcharts:Array<ClassReference<Modchart>> = [];

	/**
	 * All audio files paths used for the instrumental of this song (do not put in Paths.sound)
	 */
	public var instPath:String = null;

	/**
	 * Strumlines that this chart contains
	 */
	public var strumLines:Array<ChartStrumLine> = [];

	/**
	 * All the BPM changes this chart contains. The first BPM change defines the BPM the intro will use.
	 */
	public var bpmChanges:Array<BPMChange> = [];

	/**
	 * Name of the song
	 */
	public var songMeta:SongMetaData = null;

	/**
	 * Song events
	 */
	public var events:Array<SongEvent> = [];

	/**
	 * Icon for player
	 */
	public var playerIcon:String = "test";
	
	/**
	 * Icon for opponent
	 */
	public var opponentIcon:String = "test";

	/**
	 * Rating skin
	 */
	public var ratingSkin:String = "default";

	/**
	 * Rating skin
	 */
	public var countdownSkin:String = "default";

	/*
	 * Cutscene
	 */
	public var cutscene:ChartCutscene = CNone;

	/*
	 * Cutscene
	 */
	public var endCutscene:ChartCutscene = CNone;

	/**
	 * Load a chart from a specified song
	 * @param song Song
	 * @param difficulty Difficulty
	 */
	public static function loadFrom(song:String, difficulty:String) {
		var chartFile = new Chart(song);
		chartFile.song = song;
		chartFile.difficulty = difficulty;

		var lSong = song.toLowerCase();
		var lDiff = difficulty.toLowerCase();

		var diffPaths = [lDiff];
		if (chartFile.songMeta.folders != null && Reflect.hasField(chartFile.songMeta.folders, difficulty)) {
			diffPaths = Reflect.field(chartFile.songMeta.folders, difficulty);
		}

		function fixPath(path, pathFunc:String->String):String {
			for(d in diffPaths) {
				var diffPath = pathFunc('songs/${lSong}/$d/$path');
				if (Assets.exists(diffPath))
					return 'songs/${lSong}/$d/$path';
			}
			return 'songs/$lSong/$path';
		};

		chartFile.instPath = fixPath('Inst', Paths.sound);

		var additionalMeta = SongMeta.getAdditionalDiffMeta(lSong, lDiff);
		if (additionalMeta != null)
			SongMeta.applyMetaChanges(chartFile.songMeta, additionalMeta);

		chartFile.bpmChanges = Conductor.parseBpmDefinitionFromFile(Paths.bpmDef(fixPath('Inst', Paths.bpmDef)));

		chartFile.stage = new ClassReference<Stage>(chartFile.songMeta.stage, "game.stages", Stage);

		for(modchart in chartFile.songMeta.modcharts) {
			if (modchart.length <= 0) continue;

			var cl:ClassReference<Modchart> = new ClassReference<Modchart>(modchart, "game.modcharts", null);
			if (cl.cls == null)
				FlxG.log.warn('Modchart "${modchart}" not found.');
			else
				chartFile.modcharts.push(cl);
		}

		var jsonData:Dynamic = Assets.getJsonIfExists(Paths.json(fixPath('chart', Paths.json)));

		if (jsonData == null) {
			return chartFile; // return empty chart
		}

		/**
		 * TRY TO GUESS WHAT CHART TYPE THIS IS
		 */

		var state:ChartState = new ChartState();
		state.result = chartFile;
		state.data = jsonData;
		state.fixPath = fixPath;
		state.difficulty = lDiff;
		state.song = lSong;

		// fnf chart fix
		if (Reflect.hasField(jsonData, "song") && jsonData.song != null && !(jsonData.song is String))
			jsonData = jsonData.song;

		if (Reflect.hasField(jsonData, "notes") && Reflect.hasField(jsonData, "player1")) {
			// PSYCH / BASE GAME (PRE WEEKEND1) FORMAT
			BaseGameParser.parse(state);
		} else if (Reflect.hasField(jsonData, "codenameChart")) {
			// CODENAME CHART
			CodenameParser.parse(state);
		} else if (Reflect.hasField(jsonData, "version")) {
			// NEW FNF CHART
			FunkinCrewParser.parse(state);
		}

		#if (html5 && debug)
		js.Browser.console.log(chartFile);
		#end

		return chartFile;
	}

	public function new(song:String) {
		songMeta = SongMeta.getMeta(song);
	}

	public static function parseNoteType(type:String) {
		return switch(type) {
			default: DefaultNote;
		}
	}
}

class ChartState {
	/**
	 * RESULT PARSED CHART
	 */
	public var result:Chart;
	/**
	 * BASE DATA
	 */
	public var data:Dynamic;
	/**
	 * FIX PATH FUNCTION
	 */
	public var fixPath:(String,(String->String))->String;
	/**
	 * DIFFICULTY NAME - In case chart files contains multiple difficulties at once (lowercased)
	 */
	public var difficulty:String;
	/**
	 * SONG NAME - In case chart files contains multiple... songs?? odd (lowercased)
	 */
	public var song:String;

	public function new() {}
}

class ChartStrumLine {
	public var cpu:Bool = true;
	public var xPos:Float = 0.25;
	public var character:ChartCharacter = new ChartCharacter(SpriteCharacter);
	public var visible:Bool = true;
	public var speed:Float = 1;

	public var notes:Array<ChartNote> = [];

	public var vocalTracks:Array<String> = [];

	public function new(cpu:Bool = true) {
		this.cpu = cpu;
		this.xPos = cpu ? 0.25 : 0.75;
	}
}

class ChartNote {
	public var time:Float;
	public var strum:Int;
	public var sustainLength:Float;
	public var type:Class<Note> = Note;

	public function new(time:Float, strum:Int, sustainLength:Float, type:Class<Note> = null) {
		if (type == null)
			type = DefaultNote;

		this.time = time;
		this.type = type;
		this.strum = strum;
		this.sustainLength = sustainLength;
	}
}

class ChartCharacter {
	public var character:Class<Character>;
	public var position:String;

	public function new(character:Class<Character>, position:CharPosName = PLAYER) {
		this.character = character;
		this.position = position;
	}
}

enum ChartCutscene {
	CNone;
	CVideo(path:String);
	CCustom(cutscene:game.cutscenes.Cutscene);
}