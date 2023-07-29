package game.modcharts;

class TestModchart extends Modchart {
    public override function update(elapsed:Float) {
        super.update(elapsed);

        for(k=>strLine in PlayState.instance.strumLines.members) {
            for(k2=>s in strLine.members) {
                s.angle = Math.sin(Math.PI * Conductor.instance.curBeatFloat + (((k * 4) + k2) * 0.12)) * 15;
            }
        }
    }
}