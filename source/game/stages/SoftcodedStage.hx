package game.stages;

class SoftcodedStage extends Stage {
    public override function create() {
        super.create();
        FlxG.log.notice('Loading Softcoded Stage from name ${param}');
        // i'll let ne_eo continue from here
    }
}