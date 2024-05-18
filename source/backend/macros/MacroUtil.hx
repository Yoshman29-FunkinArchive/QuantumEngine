package backend.macros;

import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr;

class MacroUtil {
    public static var isDisplay:Bool = #if (display || display_details) true #else false #end;

    public static function getType(e:Expr):ComplexType {
        return switch(e.expr) {
            case ExprDef.EVars(vars):
                vars[0].type;
            default:
                null;
        }
    }
}