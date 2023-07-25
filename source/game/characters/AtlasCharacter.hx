package game.characters;

import flxanimate.FlxAnimate;

class AtlasCharacter extends FlxAnimate implements Character {
	public var _(get, null):FlxSprite;

	public function get__():FlxSprite
		return this;

	public var cameraOffset:FlxPoint = FlxPoint.get(125, -100);

	public var lastSingStep:Float = -5000;
	public var flipped:Bool = false;

	public var parent:StrumLine = null;

	var __curPlayingAnim:String = null;

	public function new(x:Float, y:Float, flipped:Bool, parent:StrumLine, sprite:String = null) {
		super(x, y, sprite);
		this.parent = parent;
		this.flipped = flipped;
		if (flipped)
			scale.x *= -1;

		// preloading miss sfxs
		for(i in 1...4)
			FlxG.sound.load(Paths.sound('game/sfx/missnote$i'));
	}

	public function playMissAnim(strumID:Int, ?note:Note) {
		lastSingStep = Conductor.instance.curStepFloat;

		playAnim("miss-" + ["LEFT", "DOWN", "UP", "RIGHT"][strumID], true);
		FlxG.sound.play(Paths.sound('game/sfx/missnote${FlxG.random.int(1, 3)}'), FlxG.random.float(0.1, 0.2));
		parent.muteVocals();
	}

	public function playSingAnim(strumID:Int, ?note:Note) {
		lastSingStep = Conductor.instance.curStepFloat;

		playAnim("sing-" + ["LEFT", "DOWN", "UP", "RIGHT"][strumID], true);
		parent.unmuteVocals();
	}

	public function dance(beat:Int, force:Bool) {
		if (!force) {
			switch(getAnimPrefix()) {
				case "sing":
					if (Conductor.instance.curStepFloat - lastSingStep < 3.5)
						return;
				case "miss":
					if (Conductor.instance.curStepFloat - lastSingStep < 7.5)
						return;
				case "long":
					if (!anim.finished)
						return;
			}
		}

		playDanceAnim(beat);
	}

	public function getCameraPosition():FlxPoint {
		var midpoint = getMidpoint(FlxPoint.get());
		midpoint.x -= offset.x;
		midpoint.y -= offset.y;
		if (flipped)
			midpoint.x -= cameraOffset.x;
		else
			midpoint.x += cameraOffset.x;
		midpoint.y += cameraOffset.y;
		return midpoint;
	}

	public function playDanceAnim(beat:Int) {
		playAnim("dance-idle", false);
	}

	private function getAnimPrefix():String {
		var curAnim = __curPlayingAnim;
		if (curAnim != null) {
			var pos = curAnim.indexOf("-");
			return (pos >= 0) ? curAnim.substr(0, pos) : null;
		}
		return null;
	}

	private function playAnim(Name:Null<String> = "", Force:Null<Bool> = false, Reverse:Null<Bool> = false, Frame:Null<Int> = 0) {
		__curPlayingAnim = Name;
		anim.play(Name, Force, Reverse, Frame);
	}
}