package game;

import assets.chart.Chart.ChartStrumLine;
import flixel.sound.FlxSound;
import flixel.util.FlxDestroyUtil;
import game.characters.presets.Character;
import game.strums.DefaultStrum;
import game.strums.Strum;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import backend.plugins.Conductor.ConductorSound;

class StrumLine extends FlxTypedSpriteGroup<Strum> {
	public var controlsArray:Array<String> = ["NOTE_LEFT", "NOTE_DOWN", "NOTE_UP", "NOTE_RIGHT"];

	public var cpu:Bool = false;

	public var character:Character;

	public var notes:NoteGroup;

	public var strLine:ChartStrumLine;

	public var vocalTracks:Array<ConductorSound> = [];

	#if debug
	public var __notesIndex(get, null):String;

	public inline function get___notesIndex()
		@:privateAccess
		return '${notes.lastUpdateID} / ${notes.length}';

	public var __vocalsMuted(get, null):Bool;
	public inline function get___vocalsMuted()
		@:privateAccess
		return vocalTracks.length > 0 && vocalTracks[0].volume <= 0;
	#end

	public function new(x:Float, y:Float, strLine:ChartStrumLine) {
		super();
		this.x = x;
		this.y = y;
		this.strLine = strLine;
		this.cpu = strLine.cpu;
		this.notes = new NoteGroup();

		for(i in 0...4) {
			add(new DefaultStrum(this, (-1.50 + i) * Note.swagWidth, 0, i, cpu, strLine.speed));
		}
	}

	public function muteVocals() {
		for(v in vocalTracks)
			v.volume = 0;
	}

	public function unmuteVocals() {
		for(v in vocalTracks)
			v.volume = 1;
	}

	function updateCPU(note:Note) {
		if (note.tooLate) {
			note.onMiss(this);
		}
		if (note.canBeHit && note.mustHitCPU && !note.wasGoodHit && note.time < Conductor.instance.songPosition) {
			note.onHit(this);
		}
	}

	function updatePlayer(note:Note) {
		if (note.tooLate)
			note.onMiss(this);

		if (note.canBeHit && !note.wasGoodHit) {
			if (note.isSustainNote) {
				if (pressedArray[note.strumID] && note.time < Conductor.instance.songPosition) {
					pressedSustains.push(note);
				}
			} else {
				if (justPressedArray[note.strumID]) {
					if (notesPerStrum[note.strumID] == null) {
						notesPerStrum[note.strumID] = note;
					} else if (notesPerStrum[note.strumID].time > note.time) {
						notesPerStrum[note.strumID] = note;
						additionalPressedNotes[note.strumID] = [];
					} else if (notesPerStrum[note.strumID].time == note.time) {
						additionalPressedNotes[note.strumID].push(note);
					}
				}
			}
		}
	}

	var notesPerStrum:Array<Note> = [];
	var additionalPressedNotes:Array<Array<Note>>;
	var pressedSustains:Array<Note>;
	var justPressedArray:Array<Bool>;
	var pressedArray:Array<Bool>;
	var justReleasedArray:Array<Bool>;

	public override function update(elapsed:Float) {
		for(e in members)
			e.cpu = cpu;
		notes.update(elapsed);


		if (cpu) {
			notes.forEach(updateCPU);
		} else {
			if (notesPerStrum.length != length) {
				notesPerStrum = CoolUtil.allocArray(length);
				additionalPressedNotes = [for(i in 0...length) []];
				pressedSustains = [];
				justPressedArray = [for(i in 0...length) Controls.controls[controlsArray[i]].justPressed];
				pressedArray = [for(i in 0...length) Controls.controls[controlsArray[i]].pressed];
				justReleasedArray = [for(i in 0...length) Controls.controls[controlsArray[i]].justReleased];
			} else {
				notesPerStrum.nullify();
				additionalPressedNotes = [for(i in 0...length) []];
				pressedSustains = [];
				justPressedArray.nullify(false);
				pressedArray.nullify(false);
				justReleasedArray.nullify(false);

				for(i in 0...length) {
					justPressedArray[i] = Controls.controls[controlsArray[i]].justPressed;
					pressedArray[i] = Controls.controls[controlsArray[i]].pressed;
					justReleasedArray[i] = Controls.controls[controlsArray[i]].justReleased;
				}
			}

			notes.forEach(updatePlayer);

			for(n in notesPerStrum)
				if (n != null)
					n.onHit(this);
			for(str in additionalPressedNotes)
				for(n in str)
					n.onHit(this);
			for(n in pressedSustains)
				n.onHit(this);
		}

		super.update(elapsed);
	}

	public override function draw() {
		super.draw();
		notes.draw();
	}

	public override function destroy() {
		super.destroy();
		notes = FlxDestroyUtil.destroy(notes);
	}
}