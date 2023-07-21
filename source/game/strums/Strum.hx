package game.strums;

class Strum extends FlxSprite {
    public var id:Int;
    public var cpu:Bool = false;

    public var lastHitTime:Float = -5000;
    
    public function new(x:Float, y:Float, id:Int, cpu:Bool) {
        super(x, y);
        this.id = id;
        create();
    }

    public function create() {}

    public function update(elapsed:Float) {
        super.update(elapsed);
        if (cpu) {
            switch(animation.getCurAnimName()) {
                case "static":
                    // nothing
                case "confirm":
                    if (Conductor.instance.songPosition > lastHitTime + (Conductor.instance.stepCrochet * 1.5))
                        animation.play("static", true);
                default:
                    animation.play("static", true);
            }
        } else {
            switch(animation.getCurAnimName()) {
                case "static":

                case "pressed":
                    // nothing
                case "confirm":
            }
        }
    }
}