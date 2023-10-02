package game.characters;

class Dad extends SpriteCharacter {
    public function new(x:Float, y:Float, flip:Bool, parent:StrumLine) {
        super(x, y, flip, parent);
        antialiasing = true;
        this.loadFrames('game/characters/dad');
    }
}