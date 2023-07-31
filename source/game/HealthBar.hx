package game;

import flixel.math.FlxRect;
import flixel.group.FlxGroup;

class HealthBar extends FlxGroup {
    var bg:FlxSprite;
    var bar:FlxSprite;

    var playerIcon:HealthIcon;
    var opponentIcon:HealthIcon;

    public function new() {
        super();

        create();
        createHealthIcons();
        updateBar();
    }

    public function create() {
        bg = new FlxSprite(0, FlxG.height * 0.9, Paths.image('game/ui/healthBar'));
        bg.color = 0xFFFF0000;
        bg.antialiasing = true;
        bg.screenCenter(X);
        add(bg);

        bar = new FlxSprite(bg.x, bg.y, Paths.image('game/ui/healthBar'));
        bar.color = 0xFF66FF33;
        bar.antialiasing = true;
        add(bar);
    }

    public function createHealthIcons() {
        playerIcon = new HealthIcon(PlayState.SONG.playerIcon, true);
        opponentIcon = new HealthIcon(PlayState.SONG.opponentIcon, false);
        for(i in [playerIcon, opponentIcon]) {
            i.y = bg.y - (i.height / 2);
            add(i);
        }
    }

    public function beatHit(curBeat:Int) {
        for(i in [playerIcon, opponentIcon]) {
            i.scale.set(1.1, 1.1);
            i.updateHitbox();
        }
        opponentIcon.offset.x += opponentIcon.width * 0.65;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        for(i in [playerIcon, opponentIcon]) {
            i.scale.set(CoolUtil.fLerp(i.scale.x, 1, 0.125), CoolUtil.fLerp(i.scale.y, 1, 0.125));
            i.updateHitbox();
            i.offset.x += i.width * 0.125;
        }
        opponentIcon.offset.x += opponentIcon.width * 0.75;
    }

    public function updateBar() {
        var left:Float = bar.frameWidth * (1 - PlayState.instance.health);
        bar.clipRect = new FlxRect(left, 0, bar.frameWidth - left, bar.frameHeight);

        playerIcon.x = opponentIcon.x = FlxMath.lerp(bar.x + bar.width, bar.x, PlayState.instance.health);

        playerIcon.iconHealth = PlayState.instance.health;
        opponentIcon.iconHealth = 1 - PlayState.instance.health;
    }
}