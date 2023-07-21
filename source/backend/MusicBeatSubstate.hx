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

	private inline function get_curBeat() return Conductor.instance.curBeat;
	private inline function get_curStep() return Conductor.instance.curStep;
	private inline function get_curMeasure() return Conductor.instance.curMeasure;


	private inline function _onBeat(curBeat:Int)
		return beatHit();
	private inline function _onStep(curBeat:Int)
		return stepHit();
	private inline function _onMeasure(curBeat:Int)
		return measureHit();

	override function create()
	{
		super.create();
		Conductor.onBeat.add(_onBeat);
		Conductor.onStep.add(_onStep);
		Conductor.onMeasure.add(_onMeasure);
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
		Conductor.onBeat.remove(_onBeat);
		Conductor.onStep.remove(_onStep);
		Conductor.onMeasure.remove(_onMeasure);
	}
}
