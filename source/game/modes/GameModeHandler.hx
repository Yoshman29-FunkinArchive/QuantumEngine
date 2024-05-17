package game.modes;

import assets.chart.Chart;
import menus.MainMenuState;

/**
	Use this class to make custom (Story Mode / Freeplay) game modes
	Handles what happens for example when the song ends and stuff
**/
class GameModeHandler {
	public var playCutscenes:Bool = true;
	
	public function new() {}

	/**
	 * Called whenever the score is saved in PlayState
	 */
	public function saveScore() {
		SaveManager.save.saveScore(TSong(PlayState.SONG.song, PlayState.SONG.difficulty), PlayState.instance.stats.getSaveData());
	}

	/**
	 * Called whenever the song is finished in PlayState.
	 */
	public function onSongFinished() {
		FlxG.switchState(new MainMenuState());
	}

	/**
	 * Called whenever the song is finished in PlayState.
	 */
	public function restartSong() {
		FlxG.switchState(new PlayState(PlayState.instance.gameMode));
	}

	/**
	 * Called whenever the chart is loaded in PlayState.
	 */
	public function loadSong() {
        PlayState.SONG = Chart.loadFrom("bopeebo", "hard");
	}

	/**
	 * Called to obtain the name of the gamemode.
	 * @return Gamemode name.
	 */
	public function getName():String {
		return "UNKNOWN";
	}
}