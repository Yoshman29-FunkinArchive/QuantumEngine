package game.stages;

import flixel.group.FlxGroup;

@:keep
class Stage extends FlxGroup {
	public var characterGroups:Map<String, CharGroup> = [];

	public var prefix:String = "";

	public var camZoom:Float = 0.9;

	public var ratings:RatingGroup;

	public var param:String = null;

	public function new(param:String = null) {
		super();
		this.param = param;
		Conductor.instance.onBeat.add(beatHit);
		Conductor.instance.onStep.add(stepHit);
		Conductor.instance.onMeasure.add(measureHit);

		create();

		if (ratings == null)
			addRatingGroup((FlxG.width * 0.55) - 40, (FlxG.height * 0.5) - 60);
	}

	public function create() {

	}

	public function addCharGroup(x:Float, y:Float, name:String, flip:Bool = false, scrollX:Float = 1, scrollY:Float = 1) {
		add(characterGroups[name] = new CharGroup(x, y, flip, scrollX, scrollY));
	}

	public function addRatingGroup(x:Float, y:Float) {
		add(ratings = new RatingGroup(x, y));
	}

	public override function destroy() {
		super.destroy();

		Conductor.instance.onBeat.remove(beatHit);
		Conductor.instance.onStep.remove(stepHit);
		Conductor.instance.onMeasure.remove(measureHit);
	}

	public inline function p(text:String)
		return '$prefix$text';

	// EVENTS
	public function beatHit(_:Int) {}
	public function stepHit(_:Int) {}
	public function measureHit(_:Int) {}
	public function onEvent(_:SongEvent) {}
}

class CharGroup extends FlxGroup {
	public var x:Float;
	public var y:Float;

	public var scrollX:Float;
	public var scrollY:Float;

	public var flip:Bool;

	public function new(x:Float, y:Float, flip:Bool = false, scrollX:Float = 1, scrollY:Float = 1) {
		super();
		this.x = x;
		this.y = y;
		this.scrollX = scrollX;
		this.scrollY = scrollY;
		this.flip = flip;
	}

	/**
	 * Creates a chracter in this group, and returns it
	 * @param strLine StrumLine
	 * @return Character
	 */
	public function createCharacter(char:Class<Character>, ?strLine:StrumLine):Character {
		var char:Character = Type.createInstance(char, [0, 0, flip, strLine]);
		add(char._);
		char._.setPosition(x, y);
		char._.scrollFactor.x *= scrollX;
		char._.scrollFactor.y *= scrollY;
		return char;
	}
}

enum abstract CharPosName(String) from String to String {
	var PLAYER = "player";
	var OPPONENT = "opponent";
	var GIRLFRIEND = "girlfriend";
}