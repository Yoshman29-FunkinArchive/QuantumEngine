package game.characters.presets;

interface Character {
	public var _(get, null):FlxSprite;

	public var parent:StrumLine;

	public var flipped:Bool;

	public var gameOverChar:Class<Character>;

	public function playMissAnim(strumID:Int, ?note:Note):Void;

	public function playSingAnim(strumID:Int, ?note:Note):Void;

	public function playDeathAnim(callback:Void->Void):Void;

	public function playDeathConfirmAnim():Void;

	public function dance(beat:Int, force:Bool):Void;

	public function getCameraPosition():FlxPoint;

}

class CharacterUtil {
	public static function getClassFromChar(charName:String):Class<Character> {
		switch(charName) {
			case "bf":
				return Boyfriend;
			case "gf":
				return Girlfriend;
		}

		var potentialName = getClassNameForChar(charName);
		
		var cl:Class<Character> = null;
		for(cName in ['game.characters.${potentialName}', 'game.characters.${charName}', charName]) {
			cl = cast Type.resolveClass(cName);
			if (cl != null)
				break;
		}
		if (cl != null)
			return cl;

		FlxG.log.error('Failed to find extended class for ${charName}. Is it missing?');
		return SpriteCharacter;
	}

	public static function getClassNameForChar(charName:String) {
		var potentialName = [for(e in charName.split("_")) for(e2 in e.split("-")) e2];
		for(k=>n in potentialName) {
			potentialName[k] = n.charAt(0).toUpperCase() + n.substr(1);
		}
		return potentialName.join("");
	}
}