package assets;

import assets.chart.SongMeta;
import assets.chart.SongMeta.SongMetaData;
import save.FunkinSave.ScoreType;

class FreeplaySonglist {
    public function new(songs:Array<String>) {
        this.songs = [for(s in songs) s.toLowerCase()];

        for(s in this.songs)
            if (configs[TSong(s, "normal")] == null)
                configs[TSong(s, "normal")] = SongMeta.getMeta(s);
    }
    
    public var configs:Map<ScoreType, SongMetaData> = [];
    public var songs:Array<String> = [];

    public static function load() {
        return new FreeplaySonglist(Assets.getCoolTextFile(Paths.txt('config/freeplaySonglist')));
    }
}