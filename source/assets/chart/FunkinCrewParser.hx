package assets.chart;

import game.characters.presets.Character.CharacterUtil;
import assets.chart.Chart.ChartState;

class FunkinCrewParser {
    public static function parse(chart:ChartState) {
        var result = chart.result;
        var data:FunkinChart = chart.data;

        /**
         * CHART FILE PARSING
         */
        // all funkin charts seems to be 2 strumlines, sooo
        var player:ChartStrumLine = new ChartStrumLine(false);
        var opponent:ChartStrumLine = new ChartStrumLine(true);


        result.strumLines.push(player);
        result.strumLines.push(opponent);

        var notes:Array<FunkinNote> = getDifficultyNotes(data.notes, chart.difficulty);
        trace(notes);
        for(n in notes) {
            var i = n.d % 4;
            var s = n.d >= 4 ? player : opponent;

            s.notes.push(new ChartNote(n.t, i, n.l));
        }

        for(e in data.events) {
            switch(e.e) {
                case FunkinChartEvent.FocusCamera:
                    // FOCUS CAMERA EVENT
                    // TODO: add smoothing options
                    result.events.push(new SongEvent(e.t, ECameraMove(e.v.char)));
                default:
                    // NOT IMPLEMENTED, TODO
            }
        }

        /**
         * META FILE PARSING
         */
        var meta:FunkinChartMetadata = Assets.getJsonIfExists(chart.fixPath('chart-metadata', Paths.json));
        #if (debug && html5)
        trace(meta);
        #end
        if (meta == null)
            return;

        // characters
        player.character = new ChartCharacter(CharacterUtil.getClassFromChar(meta.playData.characters.player), PLAYER);
        opponent.character = new ChartCharacter(CharacterUtil.getClassFromChar(meta.playData.characters.opponent), OPPONENT);

        if (meta.playData.characters.girlfriend != null) {
            var gfStrumLine = new ChartStrumLine(true);
            gfStrumLine.visible = false;
            gfStrumLine.character = new ChartCharacter(CharacterUtil.getClassFromChar(meta.playData.characters.girlfriend), GIRLFRIEND);
            result.strumLines.push(gfStrumLine);
        }

        // audio vocals
        var p1VocalTrack = getVocalPath(chart, meta.playData.characters.player, PLAYER);
        var p2VocalTrack = getVocalPath(chart, meta.playData.characters.opponent, OPPONENT);
        if (p1VocalTrack != null) player.vocalTracks.push(p1VocalTrack);
        if (p2VocalTrack != null) opponent.vocalTracks.push(p2VocalTrack);
    }

    public static function getVocalPath(chart:ChartState, charID:String, type:CharPosName) {
        var paths = ['Voices-$charID', 'Voices-$type'];
        for(p in paths) {
            var path = chart.fixPath(p, Paths.sound);
            if (Assets.exists(path))
                return path;
        }
        return null;
    }

    public static function getDifficultyNotes(a:FunkinDifficulties<Array<FunkinNote>>, diff:String) {
        var diffsToCheck = [diff, "normal", "hard", "erect", "nightmare", "easy"];

        for(d in diffsToCheck) {
            var data = Reflect.field(a, d);
            if (data != null)
                return data;
        }

        return [];
    }
}

enum abstract FunkinChartEvent(String) from String to String {
    public static inline var FocusCamera = "FocusCamera";
    public static inline var SetCameraBop = "SetCameraBop";
    public static inline var ZoomCamera = "ZoomCamera";
}

/**
 * SONG-METADATA.JSON
 */
typedef FunkinChartMetadata = {
    /**
     * CHART METADATA VERSION
     */
    var version:String;

    /**
     * SONG NAME
     */
    var songName:String;

    /**
     * ARTIST
     */
    var artist:String;

    /**
     * (unused)
     */
    var divisions:Int;

    /**
     * (unused)
     */
    var looped:Bool;

    /**
     * (unused)
     */
    var offsets:Dynamic;

    /**
     * Chart play data
     */
    var playData:FunkinChartPlayData;

    // (unused)
    var generatedBy:String;

    // (unused) TODO: use that
    var timeFormat:String;

    // (only used in helper editors (if theres any))
    var timeChanges:Array<FunkinChartTimeChange>;
}

typedef FunkinChartTimeChange = {
    // time change time
    var t:Float;
    // time change beat (?)
    var b:Float;
    // new BPM
    var bpm:Float;
    
    // UNKNOWN - needs research
    var n:Int;
    var d:Int;
    var bt:Array<Int>;
}

typedef FunkinChartPlayData = {
    // (unused)
    var songVariations:Array<String>;

    // (unused)
    var difficulties:Array<String>;

    /**
     * Characters
     */
    var characters:FunkinChartCharacters;

    /**
     * Stage
     */
    var stage:String;

    /**
     * Note style name
     */
    var noteStyle:String;

    // (unused)
    var ratings:Dynamic;
    // (unused)
    var previewStart:Float;
    // (unused)
    var previewEnd:Float;
}

typedef FunkinChartCharacters = {
    /**
     * Player
     */
    var player:String;
    /**
     * Girlfriend
     */
    var girlfriend:String;
    /**
     * Opponent
     */
    var opponent:String;
    /**
     * (unused) Instrumental variation
     */
    var instrumental:String;
}

/**
 * SONG-CHART.JSON
 */
typedef FunkinChart = {
    /**
     * Chart version
     */
    var version:String;

    /**
     * Dynamic containing every scroll speed for every difficulties
     */
    var scrollSpeed:FunkinDifficulties<Null<Float>>;

    /**
     * Song events
     */
    var events:Array<FunkinEvent>;

    /**
     * Song notes
     */
    var notes:FunkinDifficulties<Array<FunkinNote>>;

    /**
     * Generated by metadata
     */
    var generatedBy:String;
}

typedef FunkinDifficulties<T> = {
    var easy:T;
    var normal:T;
    var hard:T;
    var erect:T;
    var nightmare:T;
}

typedef FunkinEvent = {
    /**
     * Event time
     */
    var t:Float;
    /**
     * Event name
     */
    var e:String;
    /**
     * Event data
     */
    var v:Dynamic;
}

typedef FunkinNote = {
    /**
     * Time of note (ms)
     */
    var t:Float;
    /**
     * Strum ID
     */
    var d:Int;
    /**
     * Sustain length (ms)
     */
    var l:Float;
    /**
     * UNKNOWN - Note type??
     */
    var k:String;
}