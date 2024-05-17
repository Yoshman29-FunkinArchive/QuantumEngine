package game.weeks;

@:order(0)
class Tutorial extends Week {
    public function new() {
        super("tutorial");
    }

    public override function getWeekSongs(context:SongContext) {
        return ["tutorial"];
    }
}