package backend;

import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep(get, null):Int;
	private var curBeat(get, null):Int;
	private var curMeasure(get, null):Int;
	private var controls(get, never):Controls;

	private inline function get_curBeat() return backend.plugins.Conductor.instance.curBeat;
	private inline function get_curStep() return backend.plugins.Conductor.instance.curStep;
	private inline function get_curMeasure() return backend.plugins.Conductor.instance.curMeasure;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	private inline function _onBeat(curBeat:Int)
		return beatHit();
	private inline function _onStep(curBeat:Int)
		return stepHit();
	private inline function _onMeasure(curBeat:Int)
		return measureHit();

	override function create()
	{
		super.create();
		backend.plugins.Conductor.onBeat.add(_onBeat);
		backend.plugins.Conductor.onStep.add(_onStep);
		backend.plugins.Conductor.onMeasure.add(_onMeasure);
		FlxG.signals.postStateSwitch.addOnce(postCreate);
	}

	function postCreate() {

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
		backend.plugins.Conductor.onBeat.remove(_onBeat);
		backend.plugins.Conductor.onStep.remove(_onStep);
		backend.plugins.Conductor.onMeasure.remove(_onMeasure);
	}
}
