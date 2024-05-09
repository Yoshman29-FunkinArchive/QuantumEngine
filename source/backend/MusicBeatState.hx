package backend;

import backend.plugins.DiscordRpc.DiscordPresence;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep(get, null):Int;
	private var curBeat(get, null):Int;
	private var curMeasure(get, null):Int;

	private inline function get_curBeat() return Conductor.instance.curBeat;
	private inline function get_curStep() return Conductor.instance.curStep;
	private inline function get_curMeasure() return Conductor.instance.curMeasure;

	private inline function _onBeat(curBeat:Int) {
		if (subState != null && !persistentUpdate)
			return;
		return beatHit();
	}
	private inline function _onStep(curBeat:Int) {
		if (subState != null && !persistentUpdate)
			return;
		return stepHit();
	}
	private inline function _onMeasure(curBeat:Int) {
		if (subState != null && !persistentUpdate)
			return;
		return measureHit();
	}

	override function create()
	{
		super.create();
		Conductor.instance.onBeat.add(_onBeat);
		Conductor.instance.onStep.add(_onStep);
		Conductor.instance.onMeasure.add(_onMeasure);
		FlxG.signals.postStateSwitch.addOnce(postCreate);
	}

	#if (web && haxe >= "4.3.0")
	// weird haxe bug
	override function switchTo(state:flixel.FlxState) {
		return true;
	}
	#end

	function postCreate() {
		#if cpp
		cpp.vm.Gc.run(true);
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function beatHit() {}
	public function stepHit() {}
	public function measureHit() {}

	public override function destroy() {
		super.destroy();
		Conductor.instance.onBeat.remove(_onBeat);
		Conductor.instance.onStep.remove(_onStep);
		Conductor.instance.onMeasure.remove(_onMeasure);
	}

	public function updateDiscordPresence(presence:DiscordPresence) {
		if (subState is MusicBeatSubstate) {
			cast(subState, MusicBeatSubstate).updateDiscordPresence(presence);
		}
	}
}
