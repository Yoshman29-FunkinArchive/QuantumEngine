package assets;

import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.animation.FlxAnimationController;
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
    public static inline function getFrames(path:String):FlxFramesCollection {
        var frames = {
            if (Assets.exists(Paths.xml(path)))
                FlxAtlasFrames.fromSparrow(Paths.image(path), Paths.xml(path));
            else if (Assets.exists(Paths.txt(path)))
                FlxAtlasFrames.fromSpriteSheetPacker(Paths.image(path), Paths.txt(path));
            else
                null;
        };

        if (frames == null) {
            FlxG.log.warn('Frames at ${path} not found.');
            return null;
        }

        @:privateAccess
        if (frames.parent.frameCollections[USER("animations")] == null) {
            trace("gen animation for " + path);
            var data = getJsonIfExists(Paths.json(path));
            if (data != null && data is Array) {
                var animations:Array<AnimDefinition> = cast data;

                var dummySprite = new FlxSprite();
                dummySprite.frames = frames;
        
                var animController = dummySprite.animation;
                

                for(a in animations) {
                    if (a.name == null) {
                        FlxG.log.warn('Animations JSON: Animation without name found, skipping ($path)');
                        continue;
                    }

                    var flipX:Bool = !!a.flipX;
                    var flipY:Bool = !!a.flipY;
                    var loop:Bool = a.loop == null ? true : !!a.loop;
                    var fps:Int = a.fps == null ? 24 : a.fps;

                    if (a.prefix != null) {
                        if (a.indices != null && a.indices is Array) {
                            animController.addByIndices(a.name, a.prefix, a.indices, null, fps, loop, flipX, flipY);
                        } else {
                            animController.addByPrefix(a.name, a.prefix, fps, loop, flipX, flipY);
                        }
                    } else {
                        if (a.indices != null && a.indices is Array) {
                            animController.add(a.name, a.indices, fps, loop, flipX, flipY);
                        } else {
                            FlxG.log.warn('Animations JSON: Animation ${a.name} does not contain frame info, skipping ($path)');
                        }
                    }
                }
                
                @:privateAccess
                frames.parent._destroyOnNoUse = false;

                
                @:privateAccess {

                    var nameAnimPairs:Array<NameAnimPair> = [];

                    for(k=>a in animController._animations) {
                        nameAnimPairs.push(new NameAnimPair(k, a.clone(null)));
                    }
                    
                    frames.parent.frameCollectionTypes.push(USER("animations"));
                    frames.parent.frameCollections[USER("animations")] = nameAnimPairs;

                    dummySprite.destroy();

                    frames.parent._destroyOnNoUse = true;
                    frames.parent._useCount = 0;
                }
            } else {
                @:privateAccess {
                    frames.parent.frameCollectionTypes.push(USER("animations"));
                    frames.parent.frameCollections[USER("animations")] = [];
                }
            }
        }

        
        return frames;
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

class AssetsUtil {
    public static inline function loadFrames(sprite:FlxSprite, path:String) {
        var frames = Assets.getFrames(path);
        if (frames == null)
            return sprite;

        
        sprite.frames = frames;

        @:privateAccess {
            // hack
            if (frames.parent.frameCollections.exists(USER("animations"))) {
                var animations:Array<NameAnimPair> = cast frames.parent.getFramesCollections(USER("animations"));

                sprite.animation._animations = [for(a in animations) a.name => a.anim.clone(sprite.animation)];
                FlxG.bitmap.mustDestroy.remove(sprite.frames.parent);
            }
        }

        return sprite;
    }
}

class NameAnimPair implements IFlxDestroyable {
    public var name:String;
    public var anim:FlxAnimation;

    public function new(name:String, anim:FlxAnimation) {
        this.name = name;
        this.anim = anim;
    }

    public function destroy() {
        anim = FlxDestroyUtil.destroy(anim);
    }
}

typedef AnimDefinition = {
    var name:String;
    @:optional var prefix:String;
    @:optional var indices:Array<Int>;
    @:optional var fps:Int;
    @:optional var loop:Bool;
    var flipX:Bool;
    var flipY:Bool;
}