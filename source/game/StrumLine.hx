package game;

import game.characters.Character;
import game.strums.DefaultStrum;
import game.strums.Strum;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StrumLine extends FlxTypedSpriteGroup<Strum> {
    public var controlsArray:Array<String> = ["NOTE_LEFT", "NOTE_DOWN", "NOTE_UP", "NOTE_RIGHT"];

    public var cpu:Bool = false;

    public var character:Character;

    public function new(x:Float, y:Float, cpu:Bool = false) {
        super();
        this.x = x;
        this.y = y;
        this.cpu = cpu;

        for(i in 0...4) {
            add(new DefaultStrum(this, (-1.50 + i) * Note.swagWidth, 0, i, cpu));
        }
    }

    public override function update(elapsed:Float) {
        for(e in members)
            e.cpu = cpu;
        super.update(elapsed);
    }
}