package assets.chart;

import flixel.util.FlxColor;

final class SongMeta {
	public static function getMeta(name:String):SongMetaData {
		var d:SongMetaData = Assets.getJson(Paths.json('songs/${name.toLowerCase()}/config'));
		if (d == null)
			d = {};

		if (d.name == null)
			d.name = name;
		if (d.color == null)
			d.color = GameConfig.defaultSongColor;
		if (d.icon == null)
			d.icon = "test";
		if (d.difficulties == null || d.difficulties.length <= 0)
			d.difficulties = ["easy", "normal", "hard"];
		if (d.stage == null)
			d.stage = "DefaultStage";
		if (d.healthBar == null)
			d.healthBar = "HealthBar";
		if (d.scripts == null)
			d.scripts = [];
		if (d.modcharts == null)
			d.modcharts = [];

		return d;
	}
	public static function getAdditionalDiffMeta(name:String, difficulty:String):SongMetaData {
		return Assets.getJsonIfExists(Paths.json('songs/${name.toLowerCase()}/${difficulty.toLowerCase()}/config'));
	}

	public static function applyMetaChanges(base:SongMetaData, additional:SongMetaData) {
		base.name = additional.name ?? base.name;
		base.color = additional.color ?? base.color;
		base.icon = additional.icon ?? base.icon;
		base.stage = additional.stage ?? base.stage;
		
		if (additional.difficulties?.length > 0) base.difficulties = additional.difficulties;
		if (additional.scripts != null) for(s in additional.scripts) base.scripts.push(s);
	}
}
typedef SongMetaData = {
	@:optional var name:String;
	@:optional var color:FlxColor;
	@:optional var icon:String;
	@:optional var difficulties:Array<String>;
	@:optional var modcharts:Array<String>;

	@:optional var stage:String;
	@:optional var healthBar:String;
	@:optional var scripts:Array<String>;
}