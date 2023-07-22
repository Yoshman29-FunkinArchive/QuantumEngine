package game.characters;

interface Character {
    public var _(get, null):FlxSprite;

    public function playMissAnim(strumID:Int, ?note:Note):Void;

    public function playSingAnim(strumID:Int, ?note:Note):Void;

    public function dance(beat:Int, force:Bool):Void;
    
}

class CharacterUtil {
    public static function getClassFromChar(charName:String):Class<Character> {
        switch(charName) {
            case "bf":
                return Boyfriend;
        }
        
        var cl:Class<Character> = cast Type.resolveClass('game.characters.${charName}');
        if (cl != null)
            return cl;

        FlxG.log.error('Failed to find extended class for ${charName}. Is it missing?');
        return SpriteCharacter;
    }
}