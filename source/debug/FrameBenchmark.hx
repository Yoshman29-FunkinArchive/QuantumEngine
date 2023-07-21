package debug;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.Lib;

class FrameBenchmark extends MusicBeatState {
    public override function create() {

        FlxG.bitmap.add('assets/debug/NOTE_assets.png');
        FlxG.bitmap.add('assets/debug/NOTE_assets_autogen.png');

        var curTime = Lib.getTimer();

        for(_ in 0...10000) {
            var spr = new FlxSprite(320, 360);
            spr.frames = FlxAtlasFrames.fromSparrow('assets/debug/NOTE_assets.png', 'assets/debug/NOTE_assets.xml');

            spr.animation.addByPrefix('greenScroll', 'green0');
            spr.animation.addByPrefix('redScroll', 'red0');
            spr.animation.addByPrefix('blueScroll', 'blue0');
            spr.animation.addByPrefix('purpleScroll', 'purple0');

            spr.animation.addByPrefix('purpleholdend', 'pruple end hold');
            spr.animation.addByPrefix('greenholdend', 'green hold end');
            spr.animation.addByPrefix('redholdend', 'red hold end');
            spr.animation.addByPrefix('blueholdend', 'blue hold end');

            spr.animation.addByPrefix('purplehold', 'purple hold piece');
            spr.animation.addByPrefix('greenhold', 'green hold piece');
            spr.animation.addByPrefix('redhold', 'red hold piece');
            spr.animation.addByPrefix('bluehold', 'blue hold piece');

            add(spr);
        }
        var elapsed = Lib.getTimer() - curTime;
        trace('No JSON: ${elapsed}');
        
        curTime = Lib.getTimer();

        for(_ in 0...10000) {
            var spr = new FlxSprite(960, 360);
            spr.loadFrames('debug/NOTE_assets_autogen');
            add(spr);
        }
        elapsed = Lib.getTimer() - curTime;
        trace('JSON: ${elapsed}');
    }
}