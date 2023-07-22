package game;

import assets.chart.Chart.ChartStrumLine;
import flixel.system.FlxSound;
import flixel.util.FlxDestroyUtil;
import game.characters.Character;
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

    public function new(x:Float, y:Float, strLine:ChartStrumLine) {
        super();
        this.x = x;
        this.y = y;
        this.strLine = strLine;
        this.cpu = strLine.cpu;
        this.notes = new NoteGroup();

        for(i in 0...4) {
            add(new DefaultStrum(this, (-1.50 + i) * Note.swagWidth, 0, i, cpu));
        }
    }

    public override function update(elapsed:Float) {
        for(e in members)
            e.cpu = cpu;
        notes.update(elapsed);


        if (cpu) {
            notes.forEach(function(note) {
                if (note.tooLate) {
                    note.onMiss(this);
                }
                if (note.canBeHit && note.mustHitCPU && !note.wasGoodHit && note.time < Conductor.instance.songPosition) {
                    note.onHit(this);
                }
            });
        } else {
            var notesPerStrum = CoolUtil.allocArray(length);
            var additionalPressedNotes:Array<Note> = [];
            var justPressedArray = [for(i in 0...length) Controls.controls[controlsArray[i]].justPressed];
            var pressedArray = [for(i in 0...length) Controls.controls[controlsArray[i]].pressed];
            var justReleasedArray = [for(i in 0...length) Controls.controls[controlsArray[i]].justReleased];

            notes.forEach(function(note) {
                if (note.tooLate)
                    note.onMiss(this);
    
                if (note.canBeHit && !note.wasGoodHit) {
                    if (note.isSustainNote) {
                        if (pressedArray[note.strumID]) {
                            additionalPressedNotes.push(note);
                        }
                    } else {
                        if (justPressedArray[note.strumID]) {
                            if (notesPerStrum[note.strumID] == null) {
                                notesPerStrum[note.strumID] = note;
                            } else if (notesPerStrum[note.strumID].time == note.time) {
                                additionalPressedNotes.push(note);
                            }
                        }
                    }
                }
            });

            for(n in notesPerStrum)
                if (n != null)
                    n.onHit(this);
            for(n in additionalPressedNotes)
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