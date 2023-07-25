package debug;

import assets.chart.Chart.ChartNote;
import game.notes.DefaultNote;
import openfl.Vector;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Lib;

class FrameBenchmark extends MusicBeatState {
    public override function create() {
        var e = new ChartNote(0, 0, 0);
        var note:DefaultNote = new DefaultNote(null, e, false);
        
        var sustains:Array<DefaultNote> = [];
        var oldNote:DefaultNote = null;

        for(i in 1...40) {
            var newNote:DefaultNote = new DefaultNote(null, e, true, 100 * i, 100, i == 39, note);
            if (oldNote != null) {
                newNote.prevNote = oldNote;
                oldNote.nextNote = newNote;
            }
            oldNote = newNote;
            sustains.push(oldNote);
        }

        note.nextNote = sustains[0];
        sustains[0].prevNote = note;

        sustains.insert(0, note);

        for(k=>n in sustains) {
            n.autoUpdateInput = false;
            n.autoUpdatePosition = false;
            n.setPosition(640 + (Math.sin(k * Math.PI / 8) * 100), (k+1) * 50);
            n.angle = 25 * (1 - Math.sin(k * Math.PI / 8));
            add(n);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        FlxG.camera.scroll.x = CoolUtil.fLerp(FlxG.camera.scroll.x, (-640 + (FlxG.mouse.screenX)) / 2, 0.125);
        FlxG.camera.scroll.y = CoolUtil.fLerp(FlxG.camera.scroll.y, (-360 + (FlxG.mouse.screenY)) / 2, 0.125);
    }
}