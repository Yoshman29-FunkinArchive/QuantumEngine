package backend.macros;

import haxe.macro.Printer;
import haxe.macro.Expr;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Compiler;
import haxe.macro.ExprTools;
import haxe.macro.ComplexTypeTools;

class ControlsMacro {
    public static var controlList:Array<String> = null;
    public static function buildControls() {
        var fields:Array<Field> = Context.getBuildFields();

        if (MacroUtil.isDisplay)
            return fields;

        controlList = [];

        var initField = null;
        for(f in fields)
            if (f.name.toUpperCase() == f.name)
                controlList.push(f.name);
            else if (f.name == "init")
                initField = f;

        switch(initField.kind) {
            case FFun(f):
                var exprs:Array<Expr> = [];
                for(c in controlList)
                    exprs.push(macro $i{c}.init());

                f.expr = {
                    expr: EBlock(exprs),
                    pos: Context.currentPos()
                };
            default:
        }

        return fields;
    }

    public static function loadControlList() {
        controlList = [];

        var t = Context.getType("backend.Controls.Controls");

        switch(t) {
            case TLazy(f):
                t = f();
            default:
        }

        switch(t) {
            case TInst(clRef, _):
                var c = clRef.get();
                for(f in c.statics.get())
                    if (f.name.toUpperCase() == f.name && !controlList.contains(f.name))
                        controlList.push(f.name);
            default:

        }

    }

    public static function buildControlResolver() {
        var fields:Array<Field> = Context.getBuildFields();

        loadControlList();

        var boolType = MacroUtil.getType(macro var e:Bool = null);
        
        for(c in controlList) {
            fields.push({
                name: c,
                access: [APublic],
                kind: FProp("get", "null", boolType),
                pos: Context.currentPos()
            });

            fields.push({
                name: "get_" + c,
                access: [APrivate, AInline],
                kind: FFun({
                    args: [],
                    ret: boolType,
                    expr: macro return ${{
                        expr: EField({
                            expr: EConst(CIdent("Controls")),
                            pos: Context.currentPos()
                        }, c),
                        pos: Context.currentPos()
                    }}.getState(state)
                }),
                pos: Context.currentPos()
            });
        }

        // for(f in fields) {
        //     var p = new Printer();
        //     trace(p.printField(f));
        // }
        return fields;
    }
}