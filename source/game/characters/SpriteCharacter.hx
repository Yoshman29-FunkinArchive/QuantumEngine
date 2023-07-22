package game.characters;

class SpriteCharacter extends FlxSprite implements Character {
	public var _(get, null):FlxSprite;

	public function get__():FlxSprite
		return this;

    public var lastSingStep:Float = -5000;
    public var isPlayer:Bool = false;

    public function new(x:Float, y:Float, isPlayer:Bool) {
        super(x, y);
        this.isPlayer = isPlayer;
        flipX = isPlayer;
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
                    if (Conductor.instance.curStepFloat - lastSingStep < 1.5)
                        return;
                case "miss":
                    if (Conductor.instance.curStepFloat - lastSingStep < 2.5)
                        return;
                case "long":
                    if (!animation.curAnim.finished)
                        return;
            }
        }

        playDanceAnim(beat);
    }

    public function playDanceAnim(beat:Int) {
        animation.play("dance-idle", true);
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