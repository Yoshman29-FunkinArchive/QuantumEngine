package assets;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets as FLAssets;

class Assets {
    public static function getFrames(path) {
        return FlxAtlasFrames.fromSparrow(Paths.image(path), Paths.xml(path));
    }

    public static function getCoolTextFile(path) {
        var trimmed:String;
        return [for(l in FLAssets.getText(Paths.txt(path)).replace("\r", "").split("\n")) if ((trimmed = l.trim()) != "" && !trimmed.startsWith("#")) trimmed];
    }

    public static inline function exists(path)
        return FLAssets.exists(path);
}