package assets.chart;

import game.stages.Stage;
import assets.chart.SongMeta.SongMetaData;
import flixel.group.FlxGroup;

class Chart {
    /**
     * Stage used in this song
     */
    public var stage:Class<Stage>; // TODO: Stage

    /**
     * All audio files paths used for the instrumental of this song (do not put in Paths.sound)
     */
    public var audioFiles:Array<String> = [];

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

        chartFile.audioFiles = [fixPath('Inst', Paths.sound)];

        var additionalMeta = SongMeta.getAdditionalDiffMeta(lSong, lDiff);
        if (additionalMeta != null)
            SongMeta.applyMetaChanges(chartFile.songMeta, additionalMeta);

        chartFile.bpmChanges = Conductor.parseBpmDefinitionFromFile(Paths.bpmDef(fixPath('Inst', Paths.bpmDef)));

        var cl:Class<Stage> = null;
        for(classPath in ['game.stages.${chartFile.songMeta.stage}', chartFile.songMeta.stage])
            if ((cl = cast Type.resolveClass(classPath)) != null)
                break;

        chartFile.stage = (cl == null) ? Stage : cl;

        return chartFile;
    }

    public function new(song:String) {
        songMeta = SongMeta.getMeta(song);
    }
}

class ChartStrumLine {
    public var cpu:Bool = false;
    public var xPos:Float = 0.25;
    
    public var character:String = "bf";

    public function new(cpu:Bool = false) {
        this.cpu = cpu;
    }
}