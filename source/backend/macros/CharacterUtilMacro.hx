package backend.macros;

import haxe.macro.ComplexTypeTools;
#if macro
import haxe.macro.Printer;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.ComplexType;
import sys.FileSystem;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Compiler;
import sys.io.File;
import haxe.io.Path;
import haxe.macro.ExprTools;

class CharacterUtilMacro {
    public static var isDisplay:Bool = #if (display || display_details) true #else false #end;

    public static function build():Array<Field> {
        if (isDisplay)
            return Context.getBuildFields();

        var fields = [];

        fields.push(createCharacterField("getClassFromChar", "game/characters"));

        // throw "unfinished";
        
        return fields;
    }

    public static function createCharacterField(name:String, classesPath:String):Field {

        var classes = Context.resolvePath(classesPath);

        var retType = getType(macro var e:Class<Character> = null);

        trace(macro game.characters.presets.Character);

        var totalHits:Array<String> = [];

        var f:Field = {
            name: name,
            pos: Context.currentPos(),
            kind: FFun({
                args: [{
                    name: "name",
                    type: getType(macro var e:String = null)
                }],
                ret: retType,
                expr: isDisplay
                    ? macro {return null;}
                    : mk(EBlock([{
                        var cases:Array<Case> = [];
                        for(f in FileSystem.readDirectory(classes)) {
                            var path = Path.join([classes, f]);
                            if (FileSystem.isDirectory(path)) continue;
                            if (Path.extension(f).toLowerCase() != "hx") continue;
                            var clName = Path.withoutExtension(f);
                            if (clName == "import") continue;
                
                            var cl = Context.getType(StringTools.replace(Path.join([classesPath, clName]), "/", "."));
                            while(true) {
                                var brk = false;
                                switch(cl) {
                                    case TLazy(f):
                                        cl = f();
                                    default:
                                        brk = true;
                                }
                                if (brk)
                                    break;
                            }


                            var hits:Array<Expr> = [];
                            switch(cl) {
                                case TInst(t, params):
                                    var cl = t.get();
                                    hits.push(mk(EConst(CString(cl.name))));
                                    var meta:Metadata = cl.meta.get();
                                    for(m in meta) {
                                        if (m.name == "id") {
                                            for(c in m.params) {
                                                var strName = ExprTools.getValue(c);
                                                if (totalHits.contains(strName))
                                                    throw '${cl.name} - Another character has already been registered with the ID "$strName", or the ID has been registered twice.';
                                                hits.push(c);
                                                totalHits.push(strName);
                                            }
                                        }
                                    }
                                    
                                    var path = cl.pack.copy();
                                    path.push(cl.name);
                                    cases.push({values: hits, expr: macro return ${classToFields(path)}});
                                default:
                                    // nothing
                            }
                        }
                        null;

                        mk(ESwitch(macro name, cases, null));
                    }, macro return SpriteCharacter]))
            }),
            access: [APublic, AStatic]
        }

        
        // var p = new Printer();
        // trace("\n" + p.printField(f));


        return f;
    }

    public static function mk(e:ExprDef):Expr {
        return {
            expr: e,
            pos: Context.currentPos()
        }
    };

    public static function getType(e:Expr):ComplexType {
        return switch(e.expr) {
            case ExprDef.EVars(vars):
                vars[0].type;
            default:
                null;
        }
    }

    public static function classToFields(path:Array<String>):Expr {
        var e:Expr = null;

        for(i in path)
            e = mk(e == null ? EConst(CIdent(i)) : EField(e, i));

        return e;
    }
}
#end