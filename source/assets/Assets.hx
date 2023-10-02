package assets;

import haxe.ds.Vector;
import flixel.graphics.frames.FlxFrame;
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
	public static function getFrames(path:String):FlxFramesCollection {
		var frames:FlxAtlasFrames = null;

		var imgPath = Paths.image(path);
		var f = FlxAtlasFrames.findFrame(FlxG.bitmap.add(imgPath));
		if (f != null)
			frames = f;
		else if (Assets.exists(Paths.xml(path)))
			frames = FlxAtlasFrames.fromSparrow(imgPath, Paths.xml(path));
		else if (Assets.exists(Paths.txt(path)))
			frames = FlxAtlasFrames.fromSpriteSheetPacker(imgPath, Paths.txt(path));

		if (frames == null) {
			FlxG.log.warn('Frames at ${path} not found.');
			return null;
		}

		@:privateAccess
		if (!frames.parent.frameCollections.exists(USER("animations"))) {
			var data = getJsonIfExists(Paths.json(path));
			if (data != null && data is Array) {
				var animations:Array<AnimDefinition> = cast data;

				var dummySprite = new FlxSprite();
				dummySprite.frames = frames;

				var animController = dummySprite.animation;

				var newFrames:Array<FlxFrame> = [];
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
							continue;
						}
					}


					var anim = animController.getByName(a.name);
					var beginningPos = newFrames.length;
					if (anim == null) {
						FlxG.log.warn('Animation for ${a.name} is invalid.');
						continue;
					}
					for(i in anim.frames) {
						var correspondingFrame = frames.frames[i];
						newFrames.push(correspondingFrame.copyTo());
					}

					for(i in beginningPos...newFrames.length) {
						var f = newFrames[i];
						if (a.x != null) f.offset.x -= a.x;
						if (a.y != null) f.offset.y -= a.y;
					}

					anim.frames = [for(i in beginningPos...(newFrames.length)) i];
				}

				frames.frames = newFrames;


				@:privateAccess
				frames.parent._destroyOnNoUse = false;


				@:privateAccess {

					var nameAnimPairs:Array<FlxAnimation> = [];

					for(k=>a in animController._animations) {
						nameAnimPairs.push(a.clone(null));
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
	public static function loadFrames(sprite:FlxSprite, path:String) {
		var frames = Assets.getFrames(path);
		if (frames == null)
			return;


		sprite.frames = frames;

		@:privateAccess {
			// hack
			if (frames.parent.frameCollections.exists(USER("animations"))) {
				var animations:Array<FlxAnimation> = cast frames.parent.getFramesCollections(USER("animations"));

				sprite.animation._animations = [for(a in animations) a.name => a.clone(sprite.animation)];
				// for(anim in animations) {
				//     sprite.animation._animations.set(anim.name, anim.clone(sprite.animation));
				// }
			}
		}
	}
}

typedef AnimDefinition = {
	var name:String;
	@:optional var prefix:String;
	@:optional var indices:Array<Int>;
	@:optional var fps:Int;
	@:optional var loop:Bool;
	@:optional var flipX:Bool;
	@:optional var flipY:Bool;
	@:optional var x:Float;
	@:optional var y:Float;
}