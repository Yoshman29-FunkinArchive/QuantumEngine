package game.weeks;

@:order(1)
class Week1 extends Week {
    public function new() {
        super("week1");
    }

    public override function showInMenu() {
        return true;
    }

    public override function getWeekSongs(context:SongContext) {
        return ["bopeebo", "fresh", "dadbattle"];
    }
}