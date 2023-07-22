package game.characters;

class Boyfriend extends SpriteCharacter {
    public function new(x:Float, y:Float, flip:Bool) {
        super(x, y, flip); 
        scale.x *= -1; // bf is flipped
        antialiasing = true;
        this.loadFrames('game/characters/bf');

        offset.set(0, -350);
    }
}