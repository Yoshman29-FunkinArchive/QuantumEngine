package backend;

#if macro
import sys.io.Process;
import haxe.macro.Context;
import haxe.macro.Compiler;
import haxe.macro.Expr;
#end

class DefinesMacro {
	/**
	 * Returns the defined values
	 */
	public static var defines(get, null):Map<String, Dynamic>;

	// GETTERS
	private static inline function get_defines()
		return __getDefines();

	// INTERNAL MACROS
	private static macro function __getDefines() {
		#if display
		return macro $v{[]};
		#else
		return macro $v{Context.getDefines()};
		#end
	}
}