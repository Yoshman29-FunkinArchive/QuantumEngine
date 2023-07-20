package backend.plugins;

import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import backend.FPS.IHasDebugInfo;
import flixel.system.FlxSoundGroup;


// beat -> bpmdef
typedef BPMChangeEvents = Map<Int, BPMDefinition>;

typedef BPMDefinition = {
    var bpm:Int;
    @:optional var stepsPerBeat:Int;
    @:optional var beatsPerMeasure:Int;
}

class Conductor extends FlxBasic implements IHasDebugInfo  {
    public var sounds:FlxSoundGroup = new FlxSoundGroup();
    public var curPlayingPath = null;

    public static var instance:Conductor;

    public var _songPosition:Float = 0;
    public var _curMeasureFloat:Float = 0;
    public var _curBeatFloat:Float = 0;
    public var _curStepFloat:Float = 0;
    public var _curMeasure:Int = 0;
    public var _curBeat:Int = 0;
    public var _curStep:Int = 0;

    public var __lastUpdateTime:Float = -1;
    public var __lastVolume:Float = -1;

    public function new() {
        super();

        FlxG.plugins.add(this);
    }

    public static function init() {
        instance = new Conductor();
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (sounds.sounds.length > 0) {
            var masterSound = sounds.sounds[0];
            if (__lastUpdateTime != masterSound.time) {
                _songPosition = __lastUpdateTime = masterSound.time;
            } else {
                _songPosition += elapsed * 1000;
            }

            var curVolume:Float = FlxG.sound.muted ? 0 : FlxG.sound.volume;
            if (__lastVolume != curVolume) {
                __lastVolume = curVolume;
                sounds.volume = FlxG.sound.muted ? 0 : 1;
            }
        }
    }

    public function playing() {
        return sounds.sounds.length > 0 && sounds.sounds[0].playing;
    }

    @:keep
    public function getDebugInfo() {
        return 'songPosition: ${Std.int(_songPosition)}\n' +
        'curMeasure: ${Std.int(_curMeasure)}\n' +
        'curBeat: ${Std.int(_curBeat)}\n' +
        'curStep: ${Std.int(_curStep)}\n' +
        'nb of sounds: ${Std.int(sounds.sounds.length)}\n';
    }

    public function load(path:String, forceReplay:Bool = false, ?additionalTracks:Array<String>) {
        if (forceReplay || curPlayingPath != path) {
            while(sounds.sounds.length > 0) {
                var snd = sounds.sounds[sounds.sounds.length-1];
                snd.stop();
                FlxG.sound.list.remove(snd, true);
                sounds.remove(snd);
                snd.destroy();
            }

            __resetVars();


            curPlayingPath = path;
            if (additionalTracks == null)
                additionalTracks = [path];
            else
                additionalTracks.insert(0, path);
            for(e in additionalTracks) {
                var sound = new FlxSound().loadEmbedded(Paths.sound(e));
                sound.autoDestroy = false;
                sound.persist = true;
                FlxG.sound.list.add(sound);
                sounds.add(sound);
            }
        }
    }

    /*
        SHADOW FUNCTIONS
    */
    
    public inline function loadAndPlay(path:String) {
        load(path);
        play();
    }
    public inline function play(ForceRestart:Bool = false, StartTime:Float = 0.0, ?EndTime:Float)
        for(s in sounds.sounds)
            if (s != null) {
                s.play(ForceRestart, StartTime, EndTime);
                @:privateAccess
                s.updateTransform();
            }

    public inline function stop()
        for(s in sounds.sounds)
            if (s != null)
                s.stop();

    public inline function fadeIn(Duration:Float = 1, From:Float = 0, To:Float = 1, ?onComplete:FlxTween->Void)
        for(s in sounds.sounds)
            if (s != null)
                s.fadeIn(Duration, From, To, onComplete);

    public inline function fadeOut(Duration:Float = 1, ?To:Float = 0, ?onComplete:FlxTween->Void)
        for(s in sounds.sounds)
            if (s != null)
                s.fadeOut(Duration, To, onComplete);

    public inline function pause()
        sounds.pause();

    public inline function resume()
        sounds.resume();

    private function __resetVars() {
        _songPosition = 0;
        _curBeat = 0;
        _curBeatFloat = 0;
        _curMeasure = 0;
        _curMeasureFloat = 0;
        _curStep = 0;
        _curStepFloat = 0;
        __lastUpdateTime = -1;
    }
}