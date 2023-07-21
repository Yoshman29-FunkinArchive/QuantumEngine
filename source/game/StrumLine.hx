package game;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StrumLine extends FlxTypedSpriteGroup<Strum> {
    public function new(x:Float, y:Float) {
        super();
        this.x = x;
        this.y = y;
    }
}