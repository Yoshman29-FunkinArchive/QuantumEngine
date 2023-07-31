package game.modcharts;

import backend.DefinesMacro;
import hscript.Parser;
import hscript.Expr;
import hscript.Interp;
import hscript.Expr.Error;

class HScriptModchart extends Modchart {
    var interp:Interp;

    var path:String;
    var fileName:String;
    
    public function new(path:String) {
        super();

        this.path = Paths.hx(path);

        var splitPath = this.path.split("/");
        this.fileName = splitPath[splitPath.length-1];
        
        interp = new Interp();
        interp.errorHandler = onError;
		interp.variables.set("trace", Reflect.makeVarArgs((args) -> {
			FlxG.log.notice(args.join(", "));
		}));
        
	    var expr:Expr = null;
		var code = AssetsFL.getText(this.path);

	    var parser:Parser = new Parser();
        parser.preprocesorValues = DefinesMacro.defines;
		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
		interp.scriptObject = PlayState.instance;

		try {
			if (code != null && code.trim() != "") {
				expr = parser.parseString(code, fileName);
                interp.execute(expr);
            }
		} catch(e:Error) {
			onError(e);
		} catch(e) {
			onError(new Error(ECustom(e.toString()), 0, 0, fileName, 0));
		}
    }

    private function onError(error:Error) {
		var fn = '$fileName:${error.line}: ';
		var err = error.toString();
		if (err.startsWith(fn)) err = err.substr(fn.length);

        FlxG.log.error('${fileName}:${error.line}: $err');
    }

    private function call(funcName:String, parameters:Array<Dynamic>):Dynamic {
		if (interp == null) return null;
		if (!interp.variables.exists(funcName)) return null;

		var func = interp.variables.get(funcName);
		if (func != null && Reflect.isFunction(func))
			return Reflect.callMethod(null, func, parameters);

		return null;
	}

    /**
        HANDLERS
    **/
    
    public override function create() {call("create", []);}
    public override function postCreate() {call("postCreate", []);}
    public override function update(elapsed:Float) {super.update(elapsed);call("update", [elapsed]);}
    public override function draw() {super.draw();call("draw", []);}

    public override function beatHit(i:Int) {call("beatHit", [i]);}
    public override function stepHit(i:Int) {call("stepHit", [i]);}
    public override function measureHit(i:Int) {call("measureHit", [i]);}

    public override function onSongFinished() {call("onSongFinished", []);}

    public override function onPause() {call("onPause", []);}
    public override function onResume() {call("onResume", []);}

    public override function onHealthChange() {call("onHealthChange", []);}
    public override function onRatingShown() {call("onRatingShown", []);}
    public override function onMissed() {call("onMissed", []);}

    public override function onEvent(event:SongEvent) {
        switch(event.type) {
            case EHScriptCall(name, params):
                call(name, params);
            default:
                call("onEvent", [event]);
        }
    }
}