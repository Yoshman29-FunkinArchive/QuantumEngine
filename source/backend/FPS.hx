package backend;

import openfl.events.KeyboardEvent;
#if cpp
import cpp.vm.Gc;
#elseif hl
import hl.Gc;
#elseif java
import java.vm.Gc;
#elseif neko
import neko.vm.Gc;
#end
import openfl.system.System;

import flixel.addons.editors.ogmo.FlxOgmo3Loader.DecalData;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.ui.Keyboard;

class FPS extends TextField {
    public var cacheCount:Int = 20;
    public var curCacheID:Int = 0;
    public var cache:Array<Float>;

    public var curFPS(default, null):Float = 0;

    public function new(x:Float, y:Float, color = 0xFFFFFF) {
        super();

        this.x = x;
        this.y = y;

        
        autoSize = LEFT;
        multiline = wordWrap = selectable = mouseEnabled = false;

        text = "FPS: 0";

        defaultTextFormat = new TextFormat("_sans", 12, color);

        cache = [for(_ in 0...cacheCount) 0];
    }

    private override function __enterFrame(deltaTime:Float) {
        cache[curCacheID] = 1 / FlxG.elapsed;
        curCacheID = (curCacheID + 1) % cacheCount;

        this.visible = !FlxG.debugger.visible;

        var total:Float = 0;
        for(c in cache)
            total += c;
        total /= cacheCount;
        curFPS = total;

        var text = 'FPS: ${Std.int(curFPS)}\nMemory: ${CoolUtil.getSizeString(currentMemUsage())}';
        this.text = text;
    }

	public static inline function currentMemUsage() {
		#if cpp
		return Gc.memInfo64(Gc.MEM_INFO_USAGE);
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#else
		return 0;
		#end
	}
}