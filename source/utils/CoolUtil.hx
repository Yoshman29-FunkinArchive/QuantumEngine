package utils;

import flixel.math.FlxMath;
import flixel.animation.FlxAnimationController;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static inline function numberArray(max:Int, ?min:Int = 0):Array<Int>
		return [for(i in min...max) i];

	

	/**
	 * Returns a string representation of a size, following this format: `1.02 GB`, `134.00 MB`
	 * @param size Size to convert ot string
	 * @return String Result string representation
	 */
	 public static function getSizeString(size:Float):String {
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while(rSize > 1024 && label < labels.length-1) {
			label++;
			rSize /= 1024;
		}
		return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
	}

	/**
	 * Add several zeros at the beginning of a string, so that `2` becomes `02`.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	public static inline function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	/**
	 * Add several zeros at the end of a string, so that `2` becomes `20`, useful for ms.
	 * @param str String to add zeros
	 * @param num The length required
	 */
	public static inline function addEndZeros(str:String, num:Int) {
		while(str.length < num) str = '${str}0';
		return str;
	}

	public static inline function allocArray<T>(size:Int):Array<T> {
		#if cpp
		return cpp.NativeArray.create(size);
		#else
		return cast new haxe.ds.Vector<T>(10000);
		#end
	}

	public static inline function fLerp(v1:Float, v2:Float, ratio:Float)
		return FlxMath.lerp(v1, v2, ratio * FlxG.elapsed * 60);
}

class CoolExtension {
	public static inline function getCurAnimName(animController:FlxAnimationController) {
		return animController.curAnim != null ? animController.curAnim.name : null;
	}
	

	public static inline function nullify<T>(array:Array<T>, value:T = null) {
		for(i in 0...array.length)
			array[i] = value;
	}

	/**
	 * Basically indexOf, but starts from the end.
	 * @param array Array to scan
	 * @param element Element
	 * @return Index, or -1 if unsuccessful.
	 */
	 public static inline function indexOfFromLast<T>(array:Array<T>, element:T):Int {
		var i = array.length - 1;
		while(i >= 0) {
			if (array[i] == element)
				break;
			i--;
		}
		return i;
	}

	public static inline function mod(num:Int, m:Int) {
		var result = num % m;
		return (result < 0) ? m + result : result;
	}
}