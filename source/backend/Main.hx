package backend;

import backend.plugins.DiscordRpc;
import game.StrumLine;
import flixel.sound.FlxSoundGroup;
import flixel.system.debug.Window;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.system.debug.watch.Tracker;
import backend.cache.AssetLibraryTree;
import assets.FunkinCache;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import menus.TitleState;
import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;
import backend.FlixelFixer2000;

class Main extends Sprite
{
	public static var soundGroups:Array<FlxSoundGroup> = [];

	public function new()
	{
		super();

		addChild(new FlxGame(0, 0, true));

		#if !mobile
		addChild(new backend.FPS(10, 3, 0xFFFFFF));
		#end

		// initiating backend shit
		SaveManager.init();
		Controls.init();
		Conductor.init();
		FunkinCache.init();
		AssetLibraryTree.init();
		DiscordRpc.init();
		// configure the replacement for the cache
		FlxG.bitmap.configure();

		FlxG.fixedTimestep = false;

		FlxG.drawFramerate = FlxG.updateFramerate = 120;

		FlixelFixer2000.fix();

		configureTransition();

		setupDebug();

		FlxG.switchState(new TitleState());
	}

	public function configureTransition() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1 * 0.75, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7 * 0.75, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
	}

	public function setupDebug() {
		#if debug
		var windows:Array<Tracker> = [];
		// CONDUCTOR
		FlxG.debugger.addTrackerProfile(new TrackerProfile(Conductor, [
			"songPosition", "curBPM", "curMeasure", "curBeat",
			"curStep", "crochet", "stepCrochet", "measureCrochet",
			"bpmChangeID", "playing"], []));
		windows.push(cast(FlxG.debugger.track(Conductor.instance), Tracker));

		// FUNKIN CACHE
		FlxG.debugger.addTrackerProfile(new TrackerProfile(FunkinCacheTracker, ["cachedBitmaps", "cachedSounds", "cachedFonts", "cachedFlixelGraphics"]));
		windows.push(cast(FlxG.debugger.track(new FunkinCacheTracker()), Tracker));

		FlxG.debugger.addTrackerProfile(new TrackerProfile(StrumLine, ["controlsArray", "cpu", "justPressedArray", "pressedArray", "justReleasedArray", "__notesIndex", "__vocalsMuted"]));


		// REMOVING AUTO CLOSE
		for(window in windows) {
			FlxG.signals.preStateSwitch.remove(window.removeAll);
			FlxG.signals.preStateSwitch.remove(window.close);
		}
		#end
	}
}

#if debug
class FunkinCacheTracker {
	public var cachedBitmaps(get, null):Int;
	public var cachedSounds(get, null):Int;
	public var cachedFonts(get, null):Int;
	public var cachedFlixelGraphics(get, null):Int;

	private function get_cachedBitmaps() {
		var am = 0;
		for(e in FunkinCache.instance.bitmapData.keys())
			am++;
		return am;
	}

	private function get_cachedSounds() {
		var am = 0;
		for(e in FunkinCache.instance.sound.keys())
			am++;
		return am;
	}

	private function get_cachedFonts() {
		var am = 0;
		for(e in FunkinCache.instance.font.keys())
			am++;
		return am;
	}

	private function get_cachedFlixelGraphics() {
		var am = 0;
		@:privateAccess
		for(e in FlxG.bitmap._cache.keys())
			am++;
		return am;
	}

	public function new() {

	}
}
#end
