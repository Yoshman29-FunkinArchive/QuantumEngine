package game;

import flixel.text.FlxText;

class ScoreText extends FlxText {
    public function new(stats:GameStats) {
		super(0, (FlxG.height * 0.9) + 30, FlxG.width, "Score:0 - Misses:0 - Accuracy: 100%", 16);
		font = Paths.font(GameConfig.defaultFont);
		alignment = CENTER;
		borderSize = 1;
		borderColor = 0xFF000000;
		borderStyle = OUTLINE;

        stats.onChange.add(updateScore);
    }

	public function updateScore(stats:GameStats) {
		text = stats.toString();
	}
}