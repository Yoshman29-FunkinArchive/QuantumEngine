package save;

import flixel.input.keyboard.FlxKey;

@:keep
class EngineSettings extends SaveData {
    // AUDIO
    public var volume:Float = 1;
    public var muted:Bool = false;

    // USER SETTINGS
    public var controls:Map<String, ControlData> = [];
    public var downscroll:Bool = false;
    public var antialiasing:Bool = true;
}

typedef ControlData = {
    var keybinds:Array<FlxKey>;
    // gamepad controller support soon???
}