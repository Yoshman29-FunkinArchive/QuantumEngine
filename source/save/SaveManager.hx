package save;

class SaveManager {
    public static var settings:EngineSettings;
    public static var save:FunkinSave;

    public static function init() {
        FlxG.save.bind(GameConfig.saveName, 'BaldiFunkin');

        settings = (FlxG.save.data.settings is EngineSettings) ? cast(FlxG.save.data.settings, EngineSettings) : new EngineSettings();
        save = (FlxG.save.data.save is FunkinSave) ? cast(FlxG.save.data.save, FunkinSave) : new FunkinSave();

        FlxG.sound.volume = settings.volume;
        FlxG.sound.muted = settings.muted;

        FlxG.signals.postStateSwitch.add(onStateSwitch);
    }

    public static function onStateSwitch() {
        settings.volume = FlxG.sound.volume;
        settings.muted = FlxG.sound.muted;

        FlxG.save.data.settings = settings;
        FlxG.save.data.save = save;
        FlxG.save.flush();
    }
}

class SaveData {
    public function new() {}
}