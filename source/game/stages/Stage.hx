package game.stages;

import flixel.group.FlxGroup;

@:keep
class Stage extends FlxGroup {
    public var characterGroups:Map<String, CharGroup> = [];

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

    public function addCharGroup(x:Float, y:Float, name:String) {
        characterGroups[name] = new CharGroup(x, y);
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

class CharGroup extends FlxGroup {

    public var x:Float;
    public var y:Float;

    public function new(x:Float, y:Float) {
        super();
        this.x = x;
        this.y = y;
    }
}

enum abstract CharPosName(String) from String to String {
    var PLAYER = "player";
    var OPPONENT = "opponent";
    var GIRLFRIEND = "girlfriend";
}