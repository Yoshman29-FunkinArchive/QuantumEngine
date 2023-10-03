package game.modes;

import menus.MainMenuState;

/**
    Use this class to make custom (Story Mode / Freeplay) game modes
    Handles what happens for example when the song ends and stuff
**/
class GameModeHandler {
    public var playCutscenes:Bool = true;
    
    public function new() {}

    public function saveScore() {
		SaveManager.save.setSongScore(PlayState.songName.toLowerCase(), PlayState.difficulty.toLowerCase(), PlayState.instance.stats.getSaveData());
    }
    public function onSongFinished() {
		FlxG.switchState(new MainMenuState());
    }
}