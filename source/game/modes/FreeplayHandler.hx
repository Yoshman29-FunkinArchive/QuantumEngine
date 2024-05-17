package game.modes;

import assets.chart.Chart;
import menus.FreeplayState;

class FreeplayHandler extends GameModeHandler {
	public var songName:String;
	public var songDifficulty:String;

	public function new(songName:String, songDifficulty:String) {
		super();
		this.songName = songName;
		this.songDifficulty = songDifficulty;
	}

	public override function onSongFinished() {
		// go back to freeplay menu
		FlxG.switchState(new FreeplayState());
		trace("song finished!");
	}

	public override function loadSong() {
        PlayState.SONG = Chart.loadFrom(songName, songDifficulty);
	}
	
	public override function getName():String {
		return "Freeplay";
	}
}