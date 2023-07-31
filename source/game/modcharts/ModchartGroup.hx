package game.modcharts;

class ModchartGroup extends Modchart {
    public var modcharts:Array<Modchart> = [];

    public override function update(elapsed:Float) {
        super.update(elapsed);
        for(e in modcharts)
            if (e.exists)
                e.update(elapsed);
    }

    public override function draw() {
        super.draw();
        for(e in modcharts)
            if (e.exists)
                e.draw();
    }

    /**
        EVENTS
    **/

    public override function beatHit(c:Int) {
        for(m in modcharts)
            m.beatHit(c);
    }
    public override function stepHit(c:Int) {
        for(m in modcharts)
            m.stepHit(c);
    }
    public override function measureHit(c:Int) {
        for(m in modcharts)
            m.measureHit(c);
    }

    public override function onSongFinished() {
        for(m in modcharts)
            m.onSongFinished();
    }
    public override function onPause() {
        for(m in modcharts)
            m.onPause();
    }
    public override function onResume() {
        for(m in modcharts)
            m.onResume();
    }
    public override function onHealthChange() {
        for(m in modcharts)
            m.onHealthChange();
    }
    public override function onMissed() {
        for(m in modcharts)
            m.onMissed();
    }
    public override function create() {
        for(m in modcharts)
            m.create();
    }
    public override function postCreate() {
        for(m in modcharts)
            m.postCreate();
    }
    public override function onRatingShown() {
        for(m in modcharts)
            m.onRatingShown();
    }
    public override function onEvent(event:SongEvent) {
        for(m in modcharts)
            m.onEvent(event);
    }
}