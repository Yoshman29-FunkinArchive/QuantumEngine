package game;

import flixel.tweens.FlxTween;
import flixel.group.FlxGroup;

class RatingGroup extends FlxTypedGroup<RatingSprite> {
    public var ratingOffset:Int = 0;

    public var x:Float = 0;
    public var y:Float = 0;
    
    var __sprite:RatingSprite = null;

    public function new(x:Float, y:Float) {
        super();
        this.x = x;
        this.y = y;

        @:privateAccess
        members = CoolUtil.allocArray(length = 50);
        
        for(i in 0...length) {
            __sprite = new RatingSprite();
            __sprite.loadFrames('game/ui/ratings/${PlayState.SONG.ratingSkin}');
            __sprite.visible = false;
            __sprite.antialiasing = true;
            members[i] = __sprite;
        }
    }

    public override function update(elapsed:Float) {
        for(index in 0...length) {
            __sprite = members[(index + ratingOffset) % length];
            if (__sprite != null && __sprite.exists && __sprite.active) {
                __sprite.update(elapsed);
                __sprite.alpha = 1 - FlxMath.bound((Conductor.instance.songPosition - (Conductor.instance.crochet * 2) - __sprite.hitTime) / 200, 0, 1);
                if (__sprite.alpha <= 0)
                    __sprite.active = __sprite.visible = false;
            }
        }
    }

    public override function draw() {
        for(index in 0...length) {
            __sprite = members[(index + ratingOffset) % length];
            if (__sprite != null && __sprite.exists && __sprite.visible)
                __sprite.draw();
        }
    }

    public function showRating(rating:String, combo:Int) {
        if (combo >= 10) {
            showSprite('combo', 40, 60);

            var comboStr = Std.string(combo);
            while(comboStr.length < 3)
                comboStr = "0" + comboStr;

            for(i in 0...comboStr.length)
                showSprite('num${comboStr.charAt(i)}', (43 * i) - 90, 140, 0.5);
        }
        showSprite('sick', 0, 0);
    }

    public function showSprite(anim:String, x:Float = 0, y:Float = 0, scale:Float = 0.7) {
        __sprite = members[ratingOffset];
        __sprite.setPosition(this.x + x, this.y + y);
        __sprite.visible = __sprite.active = true;
        __sprite.alpha = 1;
        __sprite.acceleration.set(0, 550);
        __sprite.velocity.set(FlxG.random.float(-5, 5), -FlxG.random.int(140, 175));
        __sprite.animation.play(anim, true);
        __sprite.scale.set(scale, scale);
        __sprite.updateHitbox();
        __sprite.hitTime = Conductor.instance.songPosition;

        ratingOffset = (ratingOffset + 1) % length;
    }
}

class RatingSprite extends FlxSprite {
    public var hitTime:Float = 0;
}