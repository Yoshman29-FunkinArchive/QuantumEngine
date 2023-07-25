package backend.plugins;

import flixel.system.debug.watch.Tracker;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.util.FlxSignal.FlxTypedSignal;
import lime.net.oauth.OAuthVersion;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;


// beat -> bpmdef
typedef BPMChangeEvents = Map<Int, BPMDefinition>;

typedef BPMDefinition = {
	var beat:Int;
	var bpm:Float;
	@:optional var stepsPerBeat:Int;
	@:optional var beatsPerMeasure:Int;
}

typedef BPMChange = {
	var def:BPMDefinition;
	var songTime:Float;

	var stepTime:Float;
	var beatTime:Float;
	var measureTime:Float;

	var crochet:Float;
	var stepCrochet:Float;
	var measureCrochet:Float;
}



class Conductor extends FlxBasic {
	public static var instance:Conductor;

	public var sounds:FlxSoundGroup = new FlxSoundGroup();
	public var curPlayingPath = null;

	private var __empty:String = "";
	public var songPosition:Float = 0;

	public var curMeasureFloat:Float = 0;
	public var curBeatFloat:Float = 0;
	public var curStepFloat:Float = 0;

	public var curMeasure:Int = 0;
	public var curBeat:Int = 0;
	public var curStep:Int = 0;

	public var crochet:Float = 0;
	public var stepCrochet:Float = 0;
	public var measureCrochet:Float = 0;

	private var __lastUpdateTime:Float = -1;
	private var __lastVolume:Float = -1;

	public var bpmChangeID = 0;
	public var bpmChanges:Array<BPMChange> = [];
	public var curBPM:Float = 0;

	public var playing(get, null):Bool;

	public var onBeat:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onStep:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onMeasure:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public function new() {
		super();
	}

	public override function destroy() {
		super.destroy();
		for(s in sounds.sounds) {
			s.stop();
			s.destroy();
		}
		sounds = null;

		onBeat.removeAll();
		onStep.removeAll();
		onMeasure.removeAll();

		onBeat = null;
		onStep = null;
		onMeasure = null;

		bpmChanges = null;
	}

	public static function init() {
		instance = new Conductor();
		FlxG.plugins.add(instance);
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);

		if (playing) {
			var masterSound = sounds.sounds[0];
			if (__lastUpdateTime != masterSound.time) {
				songPosition = __lastUpdateTime = masterSound.time;
			} else {
				songPosition += elapsed * 1000;
			}

			var masterSound = sounds.sounds[0];
			for(s in sounds.sounds) {
				if (s == masterSound) continue;
				if (!(s is ConductorSound)) continue;
				var sound = cast(s, ConductorSound);
				if (sound.isSoundDelayed(elapsed, masterSound)) {
					sound.time = songPosition;
				}
			}

			var latestBPMChange = 0;
			for(k=>b in bpmChanges) {
				if (b.songTime > songPosition) break;
				latestBPMChange = k;
			}

			if (latestBPMChange != bpmChangeID) {
				bpmChangeID = latestBPMChange;

				FlxG.log.notice('CONDUCTOR: new BPM change (ID: ${bpmChangeID}): ${bpmChanges[bpmChangeID]}');
			}

			var curBPMChange = bpmChanges[bpmChangeID];
			var overheadtime = songPosition - curBPMChange.songTime;

			curBPM = curBPMChange.def.bpm;
			curMeasureFloat = curBPMChange.measureTime + (overheadtime / curBPMChange.measureCrochet);
			curBeatFloat = curBPMChange.beatTime + (overheadtime / curBPMChange.crochet);
			curStepFloat = curBPMChange.stepTime + (overheadtime / curBPMChange.stepCrochet);
			crochet = curBPMChange.crochet;
			stepCrochet = curBPMChange.stepCrochet;
			measureCrochet = curBPMChange.measureCrochet;

			var oldStep = curStep;
			var oldBeat = curBeat;
			var oldMeasure = curMeasure;

			curMeasure = Math.floor(curMeasureFloat);
			curBeat = Math.floor(curBeatFloat);
			curStep = Math.floor(curStepFloat);

			if (oldStep != curStep) {
				if (curStep > oldStep)
					for(i in (oldStep+1)...(curStep+1))
						onStep.dispatch(i);
				else
					onStep.dispatch(curStep);
			}

			if (oldBeat != curBeat) {
				if (curBeat > oldBeat)
					for(i in (oldBeat+1)...(curBeat+1))
						onBeat.dispatch(i);
				else
					onBeat.dispatch(curBeat);
			}

			if (oldMeasure != curMeasure) {
				if (curMeasure > oldMeasure)
					for(i in (oldMeasure+1)...(curMeasure+1))
						onMeasure.dispatch(i);
				else
					onMeasure.dispatch(curMeasure);
			}

			var curVolume:Float = FlxG.sound.muted ? 0 : FlxG.sound.volume;
			if (__lastVolume != curVolume) {
				__lastVolume = curVolume;
				sounds.volume = FlxG.sound.muted ? 0 : 1;
			}
		}
	}

	public function get_playing() {
		return sounds.sounds.length > 0 && sounds.sounds[0].playing;
	}

	public function load(path:String, forceReplay:Bool = false, ?additionalTracks:Array<String>, ?bpmDefPath:String) {
		if (forceReplay || curPlayingPath != path) {
			if (bpmDefPath == null)
				bpmDefPath = path;

			while(sounds.sounds.length > 0) {
				var snd = sounds.sounds[sounds.sounds.length-1];
				snd.stop();
				FlxG.sound.list.remove(snd, true);
				sounds.remove(snd);
				snd.destroy();
			}

			__resetVars();

			bpmDefPath = Paths.bpmDef(bpmDefPath);
			bpmChanges = Assets.exists(bpmDefPath) ? parseBpmDefinitionFromFile(bpmDefPath) : [];


			curPlayingPath = path;
			if (additionalTracks == null)
				additionalTracks = [path];
			else {
				additionalTracks = [for(a in additionalTracks) a];
				additionalTracks.insert(0, path);
			}
			for(e in additionalTracks) {
				var sound = new ConductorSound().loadEmbedded(Paths.sound(e));
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

	public inline function loadAndPlay(path:String, loop:Bool = false) {
		load(path);
		play(false, loop);
	}
	public inline function play(ForceRestart:Bool = false, Loop:Bool = false, StartTime:Float = 0.0, ?EndTime:Float) {
		for(s in sounds.sounds)
			if (s != null) {
				s.play(ForceRestart, StartTime, EndTime);
				@:privateAccess
				s.updateTransform();
				s.looped = Loop;
			}

		for(s in sounds.sounds)
			s.time = sounds.sounds[0].time;
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

	public inline function resume() {
		for(s in sounds.sounds)
			s.time = songPosition;
		sounds.resume();
	}

	private function __resetVars() {
		songPosition = 0;
		curBeat = 0;
		curBeatFloat = 0;
		curMeasure = 0;
		curMeasureFloat = 0;
		curStep = 0;
		curStepFloat = 0;
		bpmChangeID = 0;
		__lastUpdateTime = -1;
	}

	public static function parseBpmDefinitionFromFile(path:String) {
		var data:Array<String> = Assets.getCoolTextFile(path);

		var bpmChanges:Array<BPMDefinition> = [];

		for(line in data) {
			var equalIndex = line.indexOf("=");
			if (equalIndex < 0) {
				FlxG.log.warn('BPM DEFINITION: $path: Invalid line "${line}", EQUAL is missing');
				continue;
			}

			var beatNum = Std.parseInt(line.substr(0, equalIndex).trim());
			if (beatNum == null) {
				FlxG.log.warn('BPM DEFINITION: $path: Invalid line "${line}", BEAT is invalid.');
				continue;
			}

			var rightSideData = [for(d in line.substr(equalIndex + 1).trim().split(" ")) if (d != "") d];
			if (rightSideData.length <= 0) {
				FlxG.log.warn('BPM DEFINITION: $path: Invalid line "${line}", no DATA.');
				continue;
			}

			var bpm = Std.parseFloat(rightSideData[0]);

			if (Math.isNaN(bpm)) {
				FlxG.log.warn('BPM DEFINITION: $path: Invalid line "${line}", BPM is invalid.');
				continue;
			}

			var def:BPMDefinition = {
				beat: beatNum,
				bpm: bpm
			};

			if (rightSideData.length > 1) {
				var timeDef = rightSideData[1].split("/");
				var stepsPerBeat = Std.parseInt(timeDef[0]);
				var beatsPerMesure = Std.parseInt(timeDef[1]);

				if (stepsPerBeat == null) {
					FlxG.log.warn('BPM DEFINITION: $path: Invalid line "${line}", STEPS PER BEAT is invalid.');
					continue;
				}
				if (beatsPerMesure == null) {
					FlxG.log.warn('BPM DEFINITION: $path: Invalid line "${line}", BEATS PER MESURE is invalid.');
					continue;
				}

				def.beatsPerMeasure = beatsPerMesure;
				def.stepsPerBeat = stepsPerBeat;
			}

			bpmChanges.push(def);
		}

		if (bpmChanges.length <= 0)
			bpmChanges.push({
				beat: 0,
				bpm: 60
			});
		else
			bpmChanges.sort((x, y) -> x.beat - y.beat);


		var lastChange:BPMChange = { // templace 60 bpm change
			stepTime: 0,
			beatTime: 0,
			songTime: 0,
			measureTime: 0,

			crochet: 1000,
			stepCrochet: 250,
			measureCrochet: 4000,

			def: {
				beat: 0,
				bpm: 60
			}
		};

		var finalChanges:Array<BPMChange> = [];

		for(change in bpmChanges) {
			if (lastChange.def.beatsPerMeasure == null)
				lastChange.def.beatsPerMeasure = 4;
			if (lastChange.def.stepsPerBeat == null)
				lastChange.def.stepsPerBeat = 4;

			var beatPassed = change.beat - lastChange.beatTime;

			lastChange = {
				def: change,
				songTime: lastChange.songTime + (beatPassed * lastChange.crochet),

				stepTime: lastChange.stepTime + (beatPassed * lastChange.def.stepsPerBeat),
				beatTime: lastChange.beatTime + (beatPassed),
				measureTime: lastChange.measureTime + (beatPassed / lastChange.def.beatsPerMeasure),

				crochet: 0,
				stepCrochet: 0,
				measureCrochet: 0
			};
			finalChanges.push(lastChange);

			lastChange.crochet = (60 / change.bpm) * 1000;
			lastChange.stepCrochet = lastChange.crochet / lastChange.def.stepsPerBeat;
			lastChange.measureCrochet = lastChange.crochet * lastChange.def.beatsPerMeasure;
		}

		return finalChanges;
	}
}

class ConductorSound extends FlxSound {
	public var delayTime:Float = 0;
	public var delayTimeReductionCooldown:Float = 0;

	public override function update(elapsed:Float) {
		super.update(elapsed);
		if (delayTimeReductionCooldown > 0)
			delayTimeReductionCooldown -= elapsed;
		else
			delayTime -= elapsed / 4;
	}
	public function isSoundDelayed(elapsed:Float, masterSound:FlxSound):Bool {
		if (Math.abs(time - masterSound.time) > 25) {
			delayTime += elapsed;
			delayTimeReductionCooldown = 0.005; // 5 ms
			if (delayTime > 0.02) {
				delayTime = 0;
				return true;
			}
		}
		return false;
	}
}

class ConductorUtils {
	public static function getTimeForBeat(bpmChanges:Array<BPMChange>, beat:Float) {
		var latest = bpmChanges[0];
		for(b in bpmChanges) {
			if (b.beatTime > beat)
				break;
			latest = b;
		}
		return latest.songTime + ((beat - latest.beatTime) * latest.crochet);
	}

	public static function getBeatForTime(bpmChanges:Array<BPMChange>, time:Float) {
		var latest = bpmChanges[0];
		for(b in bpmChanges) {
			if (b.songTime > time)
				break;
			latest = b;
		}
		return latest.beatTime + ((time - latest.songTime) / latest.crochet);
	}

	public static function getTimeForMeasure(bpmChanges:Array<BPMChange>, measure:Float) {
		var latest = bpmChanges[0];
		for(b in bpmChanges) {
			if (b.measureTime > measure)
				break;
			latest = b;
		}
		return latest.songTime + ((measure - latest.measureTime) * latest.measureCrochet);
	}

	public static function getMeasureForTime(bpmChanges:Array<BPMChange>, time:Float) {
		var latest = bpmChanges[0];
		for(b in bpmChanges) {
			if (b.songTime > time)
				break;
			latest = b;
		}
		return latest.measureTime + ((time - latest.songTime) / latest.measureCrochet);
	}

	public static function getTimeForStep(bpmChanges:Array<BPMChange>, step:Float) {
		var latest = bpmChanges[0];
		for(b in bpmChanges) {
			if (b.stepTime > step)
				break;
			latest = b;
		}
		return latest.songTime + ((step - latest.stepTime) * latest.stepCrochet);
	}

	public static function getStepForTime(bpmChanges:Array<BPMChange>, time:Float) {
		var latest = bpmChanges[0];
		for(b in bpmChanges) {
			if (b.songTime > time)
				break;
			latest = b;
		}
		return latest.stepTime + ((time - latest.songTime) / latest.stepCrochet);
	}
}