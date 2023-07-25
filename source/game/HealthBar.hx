package game;

import flixel.math.FlxRect;
import flixel.group.FlxGroup;

class HealthBar extends FlxGroup {
    var left:FlxSprite;
    var right:FlxSprite;

    public function new() {
        super();

        create();
        updateBar();
    }

    public function create() {
        left = new FlxSprite(0, FlxG.height * 0.9, Paths.image('game/ui/healthBar'));
        left.color = 0xFFFF0000;
        left.antialiasing = true;
        left.screenCenter(X);
        add(left);

        right = new FlxSprite(left.x, left.y, Paths.image('game/ui/healthBar'));
        right.color = 0xFF66FF33;
        right.antialiasing = true;
        add(right);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public function updateBar() {
        var left:Float = right.frameWidth * (1 - PlayState.instance.health);
        right.clipRect = new FlxRect(left, 0, right.frameWidth - left, right.frameHeight);
    }
}