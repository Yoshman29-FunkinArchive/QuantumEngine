package;

import flixel.util.FlxSave;
import flixel.util.FlxColor;

/**
 * Class containing all of the game's configuration.
 */
class GameConfig {
    /**
        MOD INFO
    **/
    public static final modName:String = "Bald Engine";
    public static final saveName:String = "BaldEngine";

    /**
        MENUS
    **/
    public static final defaultSongColor:FlxColor = 0xFF9271FD;
    public static final defaultFont:String = "fonts/vcr";

    /**
        ENGINE - DO NOT TOUCH FOR SYNCHRONISATION BETWEEN MODS
    **/
    public static final funkinVersion:Array<Int> = [0, 2, 7, 1];
    public static final engineVersion:Array<Int> = [0, 1, 0];
    public static final engineSettingsSaveName:String = "BaldEngineSettings";
    public static final engineSettingsSavePath:String = "YoshiCrafter29/BaldEngine";
}