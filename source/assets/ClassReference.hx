package assets;

class ClassReference<T> {
    public var cls:Class<T>;
    public var param:String;

    public function new(str:String, defaultPackage:String, defaultClass:Class<T>) {
        var className:String = str;
        var paramName:String = null;
        var prmLimiterIndex:Int = str.indexOf("#");
        if (prmLimiterIndex >= 0) {
            className = str.substr(0, prmLimiterIndex);
            paramName = str.substr(prmLimiterIndex + 1);
        }

		var cl:Class<T> = null;
		for(classPath in ['${defaultPackage}.${className}', className])
			if ((cl = cast Type.resolveClass(classPath)) != null)
				break;

		cls = (cl == null) ? defaultClass : cl;

        this.param = paramName;
    }

    public function createInstance(args:Array<Dynamic>):T {
        args.push(param);

        var instance:T = Type.createInstance(cls, args);
        
        return instance;
    }
}