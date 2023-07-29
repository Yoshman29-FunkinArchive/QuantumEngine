package save;

import flixel.input.keyboard.FlxKey;

@:keep
class EngineSettings extends SaveData {
    public var downscroll:Bool = false;
    
    public var antialiasing:Bool = true;

    public var controls:Map<String, ControlData> = [];
}

typedef ControlData = {
    var keybinds:Array<FlxKey>;
    // gamepad controller support soon???
}