package game.modes;

import menus.FreeplayState;

class FreeplayHandler extends GameModeHandler {
    public function new() {
        super();
    }

    public override function onSongFinished() {
        // go back to freeplay menu
        FlxG.switchState(new FreeplayState());
        trace("song finished!");
    }

    public static function playSong(name:String, difficulty:String) {
        PlayState.load(name, difficulty, new FreeplayHandler());
    }
}