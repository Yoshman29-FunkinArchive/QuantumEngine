package assets;

import haxe.Json;
import flixel.graphics.frames.FlxAtlasFrames;

typedef AssetsFL = openfl.utils.Assets;

/**
 * Class containing asset helpers.
 */
class Assets {
    /**
     * Returns frames at specified path
     * @param path 
     */
    public static function getFrames(path) {
        return FlxAtlasFrames.fromSparrow(Paths.image(path), Paths.xml(path));
    }

    /**
     * Returns frames specified by those two paths (Paths independant)
     * @param imgPath 
     * @param xmlPath 
     */
    public static function getFrames_(imgPath, xmlPath) {
        return FlxAtlasFrames.fromSparrow(imgPath, xmlPath);
    }

    public static function getCoolTextFile(path) {
        var trimmed:String;
        return [for(l in AssetsFL.getText(path).replace("\r", "").split("\n")) if ((trimmed = l.trim()) != "" && !trimmed.startsWith("#")) trimmed];
    }

    public static inline function getJsonIfExists(path):Dynamic
        return Assets.exists(path) ? getJson(path) : null;

    public static function getJson(path):Dynamic {
        var json = null;
        try {
            json = Json.parse(AssetsFL.getText(path));
        } catch(e) {
            FlxG.log.error('Failed to parse JSON at $path: ${e.toString()}');
        }
        return json;
    }

    public static inline function exists(path)
        return AssetsFL.exists(path);
}