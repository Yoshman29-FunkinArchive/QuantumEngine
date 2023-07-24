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
        var sustain1:DefaultNote = new DefaultNote(null, e, true, 100, 100, false, note);
        var sustain2:DefaultNote = new DefaultNote(null, e, true, 200, 100, false, note);
        var sustain3:DefaultNote = new DefaultNote(null, e, true, 300, 100, false, note);
        var sustain4:DefaultNote = new DefaultNote(null, e, true, 400, 100, false, note);
        var sustain5:DefaultNote = new DefaultNote(null, e, true, 500, 100, false, note);
        var sustain6:DefaultNote = new DefaultNote(null, e, true, 600, 100, true, note);

        note.nextNote = sustain1;
        sustain1.prevNote = note;

        sustain1.nextNote = sustain2;
        sustain2.prevNote = sustain1;

        sustain2.nextNote = sustain3;
        sustain3.prevNote = sustain2;

        sustain3.nextNote = sustain4;
        sustain4.prevNote = sustain3;

        sustain4.nextNote = sustain5;
        sustain5.prevNote = sustain4;

        sustain5.nextNote = sustain6;
        sustain6.prevNote = sustain5;

        for(k=>n in [note, sustain1, sustain2, sustain3, sustain4, sustain5, sustain6]) {
            n.autoUpdateInput = false;
            n.autoUpdatePosition = false;
            n.setPosition(640 + (Math.sin(k * Math.PI / 4) * 100), (k+1) * 125);
            n.angle = 25 * (1 - Math.sin(k * Math.PI / 4));
            add(n);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        FlxG.camera.scroll.x = CoolUtil.fLerp(FlxG.camera.scroll.x, (-640 + (FlxG.mouse.screenX)) / 2, 0.125);
        FlxG.camera.scroll.y = CoolUtil.fLerp(FlxG.camera.scroll.y, (-360 + (FlxG.mouse.screenY)) / 2, 0.125);
    }
}