package save;

class SaveManager {
    public static var save:FunkinSave;
    public static var settings:EngineSettings;
    
    public static var __save:FlxSave;
    public static var __settings:FlxSave;

    public static function init() {
        @:privateAccess
        var defaultPath = FlxSave.validate(openfl.Lib.current.stage.application.meta["company"]);

        __save = new FlxSave();
        __save.bind('save', '$defaultPath/${GameConfig.saveName}');

        __settings = new FlxSave();
        __settings.bind(GameConfig.engineSettingsSaveName, GameConfig.engineSettingsSavePath);

        settings = (__settings.data.settings is EngineSettings) ? cast(__settings.data.settings, EngineSettings) : new EngineSettings();
        save = (__save.data.save is FunkinSave) ? cast(__save.data.save, FunkinSave) : new FunkinSave();

        FlxG.sound.volume = settings.volume;
        FlxG.sound.muted = settings.muted;

        FlxG.signals.postStateSwitch.add(flush);
    }

    public static function flush() {
        settings.volume = FlxG.sound.volume;
        settings.muted = FlxG.sound.muted;

        __save.data.save = save;
        __settings.data.settings = settings;

        __save.flush();
        __settings.flush();
    }
}

class SaveData {
    public function new() {}
}