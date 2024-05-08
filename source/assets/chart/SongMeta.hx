package assets.chart;

import flixel.util.FlxColor;

final class SongMeta {
	public static function getMeta(name:String):SongMetaData {
		var d:SongMetaData = Assets.getJson(Paths.json('songs/${name.toLowerCase()}/config')) ?? {};

		d.name = d.name ?? name;
		d.color = d.color ?? GameConfig.defaultSongColor;
		d.icon = d.icon ?? "test";
		d.stage = d.stage ?? "DefaultStage";
		d.healthBar = d.healthBar ?? "HealthBar";

		d.scripts = d.scripts ?? [];
		d.modcharts = d.modcharts ?? [];

		if (d.difficulties == null || d.difficulties.length <= 0)
			d.difficulties = ["easy", "normal", "hard"];

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
		base.healthBar = additional.healthBar ?? base.healthBar;
		
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
	@:optional var folders:Dynamic;
}