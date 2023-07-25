package assets;

class Paths {
	public static var audioExt:String = #if web "mp3" #else "ogg" #end;
	public static var prefix:String = "assets";

	private static inline function pathToExt(path:String, ext:String, ?additionalExtensions:Array<String>)
		return '$prefix/$path.$ext';

	public static inline function txt(path:String)
		return pathToExt(path, "txt");

	public static inline function json(path:String)
		return pathToExt(path, "json");

	public static inline function sound(path:String)
		return pathToExt(path, audioExt);

	public static inline function xml(path:String)
		return pathToExt(path, "xml");

	public static inline function image(path:String)
		return pathToExt(path, "png", ["jpg", "jpeg"]);

	public static inline function font(path:String)
		return pathToExt(path, "ttf", ["otf"]);



	// NOT IMPLEMENTED YET BUT COULD BE IN THE FUTURE
	public static inline function frag(path:String)
		return pathToExt(path, "frag");

	public static inline function vert(path:String)
		return pathToExt(path, "vert");

	public static inline function bpmDef(path:String)
		return pathToExt(path, "bpm");

	public static inline function atlas(path:String)
		return '$prefix/$path';
}