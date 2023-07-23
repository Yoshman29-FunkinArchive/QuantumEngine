package game.characters;

class SpriteCharacter extends FlxSprite implements Character {
	public var _(get, null):FlxSprite;

	public function get__():FlxSprite
		return this;

    public var cameraOffset:FlxPoint = FlxPoint.get(125, -100);

    public var lastSingStep:Float = -5000;
    public var flipped:Bool = false;

    public function new(x:Float, y:Float, flipped:Bool) {
        super(x, y);
        this.flipped = flipped;
        if (flipped)
            scale.x *= -1;
    }

	public function playMissAnim(strumID:Int, ?note:Note) {
        lastSingStep = Conductor.instance.curStepFloat;

        animation.play("miss-" + ["LEFT", "DOWN", "UP", "RIGHT"][strumID], true);
    }

	public function playSingAnim(strumID:Int, ?note:Note) {
        lastSingStep = Conductor.instance.curStepFloat;

        animation.play("sing-" + ["LEFT", "DOWN", "UP", "RIGHT"][strumID], true);
    }

	public function dance(beat:Int, force:Bool) {
        if (!force) {
            switch(getAnimPrefix()) {
                case "sing":
                    if (Conductor.instance.curStepFloat - lastSingStep < 3.5)
                        return;
                case "miss":
                    if (Conductor.instance.curStepFloat - lastSingStep < 7.5)
                        return;
                case "long":
                    if (!animation.curAnim.finished)
                        return;
            }
        }

        playDanceAnim(beat);
    }

    public function getCameraPosition():FlxPoint {
        var midpoint = getMidpoint(FlxPoint.get());
        midpoint.x -= offset.x;
        midpoint.y -= offset.y;
        if (flipped)
            midpoint.x -= cameraOffset.x;
        else
            midpoint.x += cameraOffset.x;
        midpoint.y += cameraOffset.y;
        return midpoint;
    }

    public function playDanceAnim(beat:Int) {
        animation.play("dance-idle", false);
    }

    private function getAnimPrefix():String {
        var curAnim = animation.getCurAnimName();
        if (curAnim != null) {
            var pos = curAnim.indexOf("-");
            return (pos >= 0) ? curAnim.substr(0, pos) : null;
        }
        return null;
    }
}