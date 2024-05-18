package game;

import assets.chart.Chart.ChartStrumLine;
import flixel.group.FlxGroup;

class StrumLineGroup extends FlxTypedGroup<StrumLine> {
    public function generate(strLine:ChartStrumLine):StrumLine {
        var strumLine:StrumLine = null;
        add(strumLine = new StrumLine(FlxG.width * strLine.xPos, 50 + (Note.swagWidth / 2), strLine));
        strumLine.visible = strLine.visible;

        var requiredNotes = 0;
        for(note in strLine.notes) {
            if (note.type == null) continue;
            requiredNotes += 1;

            if (note.sustainLength > 1) {
                var curCrochet = PlayState.SONG.bpmChanges.getTimeForBeat(PlayState.SONG.bpmChanges.getBeatForTime(note.time) + 1) - note.time;
                requiredNotes += Math.ceil(note.sustainLength / curCrochet);
            }
        }

        strumLine.notes.allocate(requiredNotes);

        var i = 0;
        var n:Note = null;

        for(note in strLine.notes) {
            if (note.type == null) continue;

            n = Type.createInstance(note.type, [strumLine, note, false]);
            strumLine.notes.members[i++] = n;

            if (note.sustainLength > 1) {
                var curCrochet:Float = (PlayState.SONG.bpmChanges.getTimeForStep(PlayState.SONG.bpmChanges.getStepForTime(note.time) + 1) - note.time);
                var am = Math.ceil(note.sustainLength / curCrochet);
                for(index in 1...am) {
                    n = Type.createInstance(note.type, [strumLine, note, true, index * curCrochet, curCrochet, false]);
                    strumLine.notes.members[i++] = n;
                }
                n = Type.createInstance(note.type, [strumLine, note, true, (am-1) * curCrochet, curCrochet, true]);
                strumLine.notes.members[i++] = n;
            }
        }

        var old:Note = null;
        for(n in strumLine.notes.members) {
            if (old != null) {
                old.nextNote = n;
                n.prevNote = old;
            }
            old = n;
        }

        strumLine.notes.sortNotes();

        #if debug
        FlxG.debugger.track(strumLine, 'Strumline #${PlayState.instance.strumLines.length} - ${strLine.character != null ? Type.getClassName(strLine.character.character).replace("game.characters.", null) : "(No char)"}');
        #end

        return strumLine;
    }
}