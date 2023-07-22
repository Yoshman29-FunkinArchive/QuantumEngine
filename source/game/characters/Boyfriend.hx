package game.characters;

class Boyfriend extends SpriteCharacter {
    public function new(x:Float, y:Float, flip:Bool) {
        super(x, y, flip);
        flipX = !flipX; // bf is flipped
        antialiasing = true;
        this.loadFrames('game/characters/bf');
    }
}