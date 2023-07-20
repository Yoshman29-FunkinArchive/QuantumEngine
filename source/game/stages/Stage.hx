package game.stages;

import flixel.group.FlxGroup;

@:keep
class Stage extends FlxGroup {
    public var characterGroups:Map<String, FlxGroup> = [];

    public var prefix:String = "";

    public var camZoom:Float = 0.9;

    public function new() {
        super();
		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);
		Conductor.onMeasure.add(measureHit);

        create();
    }

    public function create() {

    }

    public override function destroy() {
        super.destroy();

		Conductor.onBeat.remove(beatHit);
		Conductor.onStep.remove(stepHit);
		Conductor.onMeasure.remove(measureHit);
    }

    public inline function p(text:String)
        return '$prefix$text';

    public function beatHit(_:Int) {}
    public function stepHit(_:Int) {}
    public function measureHit(_:Int) {}
}