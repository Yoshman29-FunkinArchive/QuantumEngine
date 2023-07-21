package assets.chart;

class BaseGameParser {
    public static function parse(chart:Chart, data:SwagSong) {
        
    }
}


typedef SwagSong = {
	var notes:Array<SwagSection>; // i forgot sections existed
	var events:Array<Dynamic>;
	var speed:Float; // scroll speed, might need to convert???

	var song:String; // config.json
	var player1:String; // bf
	var player2:String; // dad
	var gfVersion:String; // "none" for no gf since psych only supports it in stage.json

	var bpm:Float;
	var needsVoices:Bool;

	var stage:String; // already in config.json
	var arrowSkin:String; // maybe??
	var splashSkin:String; // maybe not actually WAIT MAYBE IN STRUMLINES
}

typedef SwagSection = {
	var sectionNotes:Array<Dynamic>; // Array of numbers (or string due to psych)
	var mustHitSection:Bool;
	var gfSection:Bool; // camera focuses
	var bpm:Float;
	var changeBPM:Bool; // might be useful???? i mean bpm file...
	var altAnim:Bool; // alter note type maybe
}