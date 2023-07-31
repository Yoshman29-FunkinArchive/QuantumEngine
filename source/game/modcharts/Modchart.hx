package game.modcharts;

class Modchart extends FlxBasic {
    public function new() {
        super();
    }

    public function create() {}
    public function postCreate() {}

    public function beatHit(_:Int) {}
    public function stepHit(_:Int) {}
    public function measureHit(_:Int) {}

    public function onSongFinished() {}

    public function onPause() {}
    public function onResume() {}

    public function onHealthChange() {}
    public function onRatingShown() {}
    public function onMissed() {}

    public function onEvent(event:SongEvent) {}
}