package assets.chart;

import game.characters.Character.CharacterUtil;

class BaseGameParser {
	public static function parse(chart:Chart, data:SwagSong, fixPath:String->(String->String)->String) {
		var p1:ChartStrumLine = new ChartStrumLine(false);
		var p2:ChartStrumLine = new ChartStrumLine(true);

		chart.strumLines.push(p1);
		chart.strumLines.push(p2);

		p1.character = new ChartCharacter(CharacterUtil.getClassFromChar(data.player1), PLAYER);
		p2.character = new ChartCharacter(CharacterUtil.getClassFromChar(data.player2), OPPONENT);

		p1.xPos = 0.75;


		var gf:ChartStrumLine = null;

		if (data.gfVersion == null)
			data.gfVersion = "gf";

		if (data.gfVersion != "none") {
			gf = new ChartStrumLine();
			gf.visible = false;
			gf.xPos = 0.5;
			gf.character = new ChartCharacter(CharacterUtil.getClassFromChar(data.gfVersion), GIRLFRIEND);
			chart.strumLines.push(gf);
		}



		var camTarget = -1;

		if (!!data.needsVoices) {
			var usesSeparateVocals = Assets.exists(Paths.sound(fixPath("Voices_P1", Paths.sound)));
			if (usesSeparateVocals) {
				p1.vocalTracks.push(fixPath("Voices_P1", Paths.sound));
				p2.vocalTracks.push(fixPath("Voices_P2", Paths.sound));
			} else {
				p1.vocalTracks.push(fixPath("Voices", Paths.sound));
			}
		}

		for(k=>section in data.notes) {
			var secTarget = (section.gfSection ? 2 : (section.mustHitSection ? 1 : 0));

			if (secTarget != camTarget) {
				chart.events.push(new SongEvent(chart.bpmChanges.getTimeForMeasure(k), ECameraMove(camTarget)));
				camTarget = secTarget;
			}

			for(n in section.sectionNotes) {
				var time:Float = n[0];
				var id:Int = Std.int(n[1]) % 8;
				var susLen:Float = n[2];

				var bfNote = id >= 4 ? !section.mustHitSection : section.mustHitSection;

				id %= 4;

				(bfNote ? p1 : p2).notes.push(new ChartNote(time, id, susLen));
			}
		}
	}
}


typedef SwagSong = {
	var notes:Array<SwagSection>; // 0: time, 1 : id, 2 : sustain length, 3 : note type (psych)
	var events:Array<Dynamic>;
	var speed:Float; // scroll speed, might need to convert???

	var song:String; // config.json
	var player1:String; // bf
	var player2:String; // dad
	var gfVersion:String; // "none" for no gf since psych only supports it in stage.json

	var bpm:Float;
	var needsVoices:Bool;

	var stage:String; // already in config.json
	var arrowSkin:String; // maybe??
	var splashSkin:String; // maybe not actually WAIT MAYBE IN STRUMLINES
}

typedef SwagSection = {
	var sectionNotes:Array<Dynamic>; // Array of numbers (or string due to psych)
	var mustHitSection:Bool;
	var gfSection:Bool; // camera focuses
	var bpm:Float;
	var changeBPM:Bool; // might be useful???? i mean bpm file...
	var altAnim:Bool; // alter note type maybe
}