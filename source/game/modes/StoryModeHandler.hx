package game.modes;

import menus.StoryMenuState;
import assets.chart.Chart;
import game.weeks.presets.Week;

class StoryModeHandler extends GameModeHandler {
    public var week:Week;
    public var difficulty:String;
    public var remainingSongs:Array<String> = [];

    public var isRestarting:Bool = false;

    public function new(week:Week, difficulty:String) {
        super();
        this.week = week;
        this.difficulty = difficulty;
        this.remainingSongs = week.getWeekSongs(InGame);
    }

    public override function loadSong() {
        if (!isRestarting) {
            var song = remainingSongs.shift();
            PlayState.SONG = Chart.loadFrom(song, difficulty);
        }
    }

    public override function restartSong() {
        isRestarting = true;
        super.restartSong();
    }

    public override function onSongFinished() {
        if (remainingSongs.length > 0) {
            FlxG.switchState(new PlayState(this)); // switch to the next song
        } else
            FlxG.switchState(new StoryMenuState()); // return to main menu
    }

    public override function saveScore() {
        super.saveScore(); // save Freeplay score
        if (remainingSongs.length <= 0) {
            // TODO: Week Score
            // SaveManager.save.setScore(TWeek(week.id, difficulty));
            trace("SAVE WEEK SCORE TODO!!");
        }
    }
	
	public override function getName():String {
		return "Story Mode";
	}
}