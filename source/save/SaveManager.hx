package save;

import openfl.Lib;

class SaveManager {
    public static var settings:EngineSettings;
    public static var save:FunkinSave;

    public static function init() {
        FlxG.save.bind(GameConfig.saveName, 'BaldiFunkin');

        settings = (FlxG.save.data.settings is EngineSettings) ? cast(FlxG.save.data.settings, EngineSettings) : new EngineSettings();
        save = (FlxG.save.data.save is FunkinSave) ? cast(FlxG.save.data.save, FunkinSave) : new FunkinSave();

        FlxG.signals.postStateSwitch.add(function() {
            FlxG.save.data.settings = settings;
            FlxG.save.data.save = save;
            FlxG.save.flush();
        });
    }
}

class SaveData {
    public function new() {}
}