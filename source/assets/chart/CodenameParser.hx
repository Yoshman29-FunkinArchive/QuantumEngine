package assets.chart;

import game.characters.presets.Character.CharacterUtil;
import flixel.util.FlxColor;

class CodenameParser {
    public static function parse(chart:Chart, jsonData:CodenameData, fixPath:String->(String->String)->String) {
        if (jsonData.meta == null)
            jsonData.meta = Assets.getJsonIfExists(fixPath('meta', Paths.json));
        
        for(strLine in jsonData.strumLines) {
            var charName = (strLine.characters == null ? null : strLine.characters[0]);
            var strumLine = new ChartStrumLine();
            strumLine.visible = strLine.visible ?? true;
            strumLine.character = new ChartCharacter(
                CharacterUtil.getClassFromChar(charName ?? "bf"),
                switch(strLine.position.toLowerCase()) {
                    case "boyfriend": PLAYER;
                    case "girlfriend": GIRLFRIEND;
                    case "opponent" | "dad": OPPONENT;
                    default: strLine.position;
                }
            );
            strumLine.cpu = strLine.type != PLAYER;
            strumLine.notes = [for(n in strLine.notes) new ChartNote(n.time, n.id, n.sLen, Chart.parseNoteType(jsonData.noteTypes == null ? null : jsonData.noteTypes[n.type]))];
            strumLine.xPos = strLine.strumLinePos ?? (strumLine.cpu ? 0.25 : 0.75);
            strumLine.speed = jsonData.scrollSpeed * 0.45;
            strumLine.vocalTracks = (jsonData.meta?.needsVoices ?? true) ? [fixPath('Voices', Paths.sound)] : [];

            switch(strLine.type) {
                case PLAYER:
                    if (chart.playerIcon == "test") chart.playerIcon = charName ?? "face";
                case OPPONENT:
                    if (chart.opponentIcon == "test") chart.opponentIcon = charName ?? "face";
                default:
                    // nothing
            }

            chart.strumLines.push(strumLine);
        }

        chart.events = [for(e in jsonData.events) if (e != null && e.name != "BPM Change") new SongEvent(e.time, switch(e.name) {
            case "Camera Movement": ECameraMove(e.params[0]);
            case "HScript Call":
                if(e.params[0] is String && e.params[1] is Array)
                    EHScriptCall(e.params[0], [for(e in cast(e.params[1], Array<Dynamic>).copy()) Std.string(e)]);
                else if (e.params[0] is String && e.params[1] is String)
                    EHScriptCall(e.name, Std.string(e.params[1]).split(","));
                else
                    ECodenameEvent(e.name, e.params.copy()); // cast(e.params[1], String).split(",")
            default: ECodenameEvent(e.name, e.params.copy());
        })];
    }
}

typedef CodenameData = {
	public var strumLines:Array<CodenameStrumLine>;
	public var events:Array<CodenameEvent>;
	public var meta:CodenameMetaData;
	public var codenameCodename:Bool;
	public var stage:String;
	public var scrollSpeed:Float;
	public var noteTypes:Array<String>;

	public var ?fromMods:Bool;
}

typedef CodenameMetaData = {
	public var name:String;
	public var ?bpm:Float;
	public var ?displayName:String;
	public var ?beatsPerMesure:Float;
	public var ?stepsPerBeat:Float;
	public var ?needsVoices:Bool;
	public var ?icon:String;
	public var ?color:Dynamic;
	public var ?difficulties:Array<String>;
	public var ?coopAllowed:Bool;
	public var ?opponentModeAllowed:Bool;

	// NOT TO BE EXPORTED
	public var ?parsedColor:FlxColor;
}

typedef CodenameStrumLine = {
	var characters:Array<String>;
	var type:CodenameStrumLineType;
	var notes:Array<CodenameNote>;
	var position:String;
	var ?strumLinePos:Float; // 0.25 = default opponent pos, 0.75 = default boyfriend pos
	var ?visible:Null<Bool>;
}

typedef CodenameNote = {
	var time:Float; // time at which the note will be hit (ms)
	var id:Int; // strum id of the noteS
	var type:Int; // type (int) of the note
	var sLen:Float; // sustain length of the note (ms)
}

typedef CodenameEvent = {
	var name:String;
	var time:Float;
	var params:Array<Dynamic>;
}

enum abstract CodenameStrumLineType(Int) from Int to Int {
	/**
	 * STRUMLINE IS MARKED AS OPPONENT - WILL BE PLAYED BY CPU, OR PLAYED BY PLAYER IF OPPONENT MODE IS ON
	 */
	var OPPONENT = 0;
	/**
	 * STRUMLINE IS MARKED AS PLAYER - WILL BE PLAYED AS PLAYER, OR PLAYED AS CPU IF OPPONENT MODE IS ON
	 */
	var PLAYER = 1;
	/**
	 * STRUMLINE IS MARKED AS ADDITIONAL - WILL BE PLAYED AS CPU EVEN IF OPPONENT MODE IS ENABLED
	 */
	var ADDITIONAL = 2;
}