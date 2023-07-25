package backend.cache;

import lime.utils.AssetLibrary;

class AssetLibraryTree extends AssetLibrary {
	public var libraries:Array<AssetLibrary> = [];

	public static var instance:AssetLibraryTree = null;

	public static function init() {
		var lib = new openfl.utils.AssetLibrary();
		@:privateAccess
		lib.__proxy = (instance = new AssetLibraryTree());
		openfl.utils.Assets.registerLibrary('default', lib);
	}

	public function new() {
		super();

		#if (sys && debug)
			var pathBack = #if windows
				"../../../../"
			#elseif mac
				"../../../../../../../"
			#else
				""
			#end;

			libraries.push(new FolderAssetLibrary('./${pathBack}assets/', 'assets'));
		#end
		libraries.push(openfl.utils.Assets.getLibrary("default"));
	}

	public override function getPath(id:String) {
		for(e in libraries) {
			if (e.exists(id, e.types.get(id))) {
				var path = e.getPath(id);
				if (path != null)
					return path;
			}
		}
		return null;
	}

	public override function exists(id:String, type:String):Bool {
		for(e in libraries)
			if (e.exists(id, type))
				return true;
		return false;
	}

	public override inline function getAsset(id:String, type:String):Dynamic {
		for(e in libraries) {
			var a = e.getAsset(id, type);
			if (a != null)
				return a;
		}
		return null;
	}

	public override function isLocal(id:String, type:String) {
		for(e in libraries)
			if (e.exists(id, type))
				return e.isLocal(id, type);
		return true;
	}
}