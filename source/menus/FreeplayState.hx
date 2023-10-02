package menus;

import openfl.Vector;
import assets.chart.SongMeta.SongMetaData;
import assets.FreeplaySonglist;
import assets.chart.Chart;
import game.PlayState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import save.FunkinSave.ScoreType;
import openfl.geom.Rectangle;

using StringTools;

class FreeplayState extends MusicBeatState
{
	public var songList:FreeplaySonglist;
	private var grpSongs:FlxTypedGroup<Alphabet>;

	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;

	var scoreBG:FlxSprite;
	
	var cacheRect:Rectangle = new Rectangle();

	private var curSongName:String = "tutorial";
	private var curSongMeta:SongMetaData;
	private var curSongDifficulty:String = "normal";
	private var bg:FlxSprite;

	private var curColor:Vector<Float> = new Vector<Float>(4);

	override function create()
	{
		songList = FreeplaySonglist.load();

		bg = new FlxSprite().loadGraphic(Paths.image('menus/menuDesat'));
		add(bg);

		for(i=>c in [GameConfig.defaultSongColor.redFloat, GameConfig.defaultSongColor.greenFloat, GameConfig.defaultSongColor.blueFloat, GameConfig.defaultSongColor.alphaFloat])
			curColor[i] = c;

		bg.colorTransform.redMultiplier = curColor[0];
		bg.colorTransform.greenMultiplier = curColor[1];
		bg.colorTransform.blueMultiplier = curColor[2];
		bg.colorTransform.alphaMultiplier = curColor[3];

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (k=>s in songList.songs)
		{
			var songText:Alphabet = new Alphabet(0, (70 * k) + 30, s, true, false);
			songText.isMenuItem = true;
			songText.targetY = k;
			grpSongs.add(songText);
		}

		scoreText = new FlxText(5, 5, FlxG.width - 10, "PERSONAL BEST:0", 32);
		scoreText.alignment = RIGHT;
		scoreText.setFormat(Paths.font(GameConfig.defaultFont), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 640, "", 24);
		diffText.alignment = CENTER;
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();

		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Conductor.instance.sounds.volume < 0.7)
			Conductor.instance.sounds.volume += 0.5 * FlxG.elapsed;

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		else
			lerpScore = CoolUtil.fLerp(lerpScore, intendedScore, 0.4);


		for(i=>c in [curSongMeta.color.redFloat, curSongMeta.color.greenFloat, curSongMeta.color.blueFloat, curSongMeta.color.alphaFloat])
			curColor[i] = CoolUtil.fLerp(curColor[i], c, 0.0625);

		bg.colorTransform.redMultiplier = curColor[0];
		bg.colorTransform.greenMultiplier = curColor[1];
		bg.colorTransform.blueMultiplier = curColor[2];
		bg.colorTransform.alphaMultiplier = curColor[3];

		scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
		
		@:privateAccess
		scoreText.textField.__getCharBoundaries(0, cacheRect);

		var width = scoreText.frameWidth - cacheRect.x;
		scoreBG.scale.set(width + 10, 66);
		scoreBG.updateHitbox();
		scoreBG.x = FlxG.width - width - 10;

		diffText.x = scoreBG.x + (scoreBG.width - diffText.width) / 2;
		

		if (Controls.justPressed.UP)	changeSelection(-1);
		if (Controls.justPressed.DOWN)	changeSelection(1);
		if (Controls.justPressed.LEFT)	changeDiff(-1);
		if (Controls.justPressed.RIGHT)	changeDiff(1);
		if (Controls.justPressed.BACK)	FlxG.switchState(new MainMenuState());

		if (Controls.justPressed.ACCEPT)
		{
			PlayState.SONG = Chart.loadFrom(curSongName, curSongDifficulty); // TODO
			PlayState.songName = curSongName;
			PlayState.difficulty = curSongDifficulty;
			PlayState.isStoryMode = false;
			FlxG.switchState(new PlayState());
			Conductor.instance.stop();
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty = (curDifficulty + change).mod(curSongMeta.difficulties.length);

		curSongDifficulty = curSongMeta.difficulties[curDifficulty].toLowerCase();

		#if !switch
		intendedScore = SaveManager.save.getSongScore(curSongName, curSongDifficulty).score;
		#end

		diffText.text = curSongMeta.difficulties.length > 1 ? '< ${curSongDifficulty.toUpperCase()} >' : curSongDifficulty.toUpperCase();
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('menus/sfx/scroll'), 0.4);

		curSelected = (curSelected + change).mod(songList.songs.length);

		curSongName = songList.songs[curSelected].toLowerCase();
		curSongMeta = songList.configs[TSong(curSongName, "normal")];

		Conductor.instance.loadAndPlay('songs/$curSongName/Inst', true);

		for(i=>item in grpSongs.members)
			item.alpha = (item.targetY = i - curSelected) == 0 ? 1 : 0.6;

		changeDiff(0);
	}
}
