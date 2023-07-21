package assets.chart;

import game.Character;
import game.Note;
import game.SongEvent;
import haxe.Json;
import game.stages.Stage;
import assets.chart.SongMeta.SongMetaData;
import flixel.group.FlxGroup;

class Chart {
    /**
     * Stage used in this song
     */
    public var stage:Class<Stage>;

    /**
     * All audio files paths used for the instrumental of this song (do not put in Paths.sound)
     */
    public var instPath:String = null;

    /**
     * Strumlines that this chart contains
     */
    public var strumLines:Array<ChartStrumLine> = [];

    /**
     * All the BPM changes this chart contains. The first BPM change defines the BPM the intro will use.
     */
    public var bpmChanges:Array<BPMChange> = [];

    /**
     * Name of the song
     */
    public var songMeta:SongMetaData = null;

    /**
     * Song events
     */
    public var events:Array<SongEvent> = [];

    /**
     * Load a chart from a specified song
     * @param song Song
     * @param difficulty Difficulty
     */
    public static function loadFrom(song:String, difficulty:String) {
        var chartFile = new Chart(song);

        var lSong = song.toLowerCase();
        var lDiff = difficulty.toLowerCase();

        function fixPath(path, pathFunc:String->String):String {
            var diffPath = pathFunc('songs/${lSong}/$lDiff/$path');
            if (Assets.exists(diffPath))
                return 'songs/${lSong}/$lDiff/$path';
            return 'songs/$lSong/$path';
        };

        chartFile.instPath = fixPath('Inst', Paths.sound);

        var additionalMeta = SongMeta.getAdditionalDiffMeta(lSong, lDiff);
        if (additionalMeta != null)
            SongMeta.applyMetaChanges(chartFile.songMeta, additionalMeta);

        chartFile.bpmChanges = Conductor.parseBpmDefinitionFromFile(Paths.bpmDef(fixPath('Inst', Paths.bpmDef)));

        var cl:Class<Stage> = null;
        for(classPath in ['game.stages.${chartFile.songMeta.stage}', chartFile.songMeta.stage])
            if ((cl = cast Type.resolveClass(classPath)) != null)
                break;

        chartFile.stage = (cl == null) ? Stage : cl;

        var jsonData:Dynamic = Assets.getJsonIfExists(Paths.json(fixPath('chart', Paths.json)));

        if (jsonData == null) {
            return chartFile;
        }

        if (Reflect.hasField(jsonData, "song") && jsonData.song != null && !(jsonData.song is String))
            jsonData = jsonData.song;

        if (Reflect.hasField(jsonData, "notes") && Reflect.hasField(jsonData, "player1")) {
            // PSYCH / BASE GAME FORMAT
            BaseGameParser.parse(chartFile, jsonData);
        }

        #if html5
        js.Browser.console.log(chartFile);
        js.Browser.console.log(jsonData);
        #end

        return chartFile;
    }

    public function new(song:String) {
        songMeta = SongMeta.getMeta(song);
    }
}

class ChartStrumLine {
    public var cpu:Bool = true;
    public var xPos:Float = 0.25;
    public var character:ChartCharacter = new ChartCharacter();
    public var visible:Bool = true;

    public var notes:Array<ChartNote> = [];

    public function new(cpu:Bool = true) {
        this.cpu = cpu;
    }
}

class ChartNote {
    public var time:Float;
    public var strum:Int;
    public var sustainLength:Float;
    public var type:Class<Note> = Note;

    public function new(time:Float, strum:Int, sustainLength:Float, type:Class<Note> = null) {
        if (type == null)
            type = Note;

        this.time = time;
        this.type = type;
        this.sustainLength = sustainLength;
    }
}

class ChartCharacter {
    public var character:String;
    public var position:String;

    public function new(character:String = "bf", position:CharPosName = PLAYER) {
        this.character = character;
        this.position = position;
    }
}