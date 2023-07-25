package game.characters;

class Girlfriend extends AtlasCharacter {
	public function new(x:Float, y:Float, flipped:Bool, parent:StrumLine) {
		super(x, y, flipped, parent, Paths.atlas('game/characters/gf'));
		antialiasing = true;

		anim.addBySymbol("sing-cheer", "GF Cheer", 24, false);
		anim.addBySymbol("sing-UP", "GF Up Note", 24, false);
		anim.addBySymbol("sing-LEFT", "GF left note", 24, false);
		anim.addBySymbol("sing-RIGHT", "GF Right Note", 24, false);
		anim.addBySymbol("sing-DOWN", "GF Down Note", 24, false);
		anim.addBySymbolIndices("dance-left", "GF Dancing Beat", [30,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14], 24, false);
		anim.addBySymbolIndices("dance-right", "GF Dancing Beat", [15,16,17,18,19,20,21,22,23,24,25,26,27,28,29], 24, false);
		anim.addBySymbolIndices("long-hairBlow", "GF Dancing Beat Hair blowing", [0,1,2,3], 24, false);
		anim.addBySymbolIndices("long-hairFall", "GF Dancing Beat Hair Landing", [0,1,2,3,4,5,6,7,8,9,10,11]);
		anim.addBySymbol("dance-fear", "GF FEAR", 24, false);
		anim.addBySymbolIndices("dance-sad", "gf sad", [0,1,2,3,4,5,6,7,8,9,10,11,12], 24, true);

		playAnim("dance-left");

		offset.set(-100, -275);
	}

	public override function playDanceAnim(beat:Int) {
		playAnim(beat.mod(2) == 0 ? "dance-left" : "dance-right");
	}
}