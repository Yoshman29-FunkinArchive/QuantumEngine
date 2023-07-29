package save;

@:keep
class FunkinSave extends SaveData {
    public var scores:Map<ScoreType, Score> = [];
}

enum ScoreType {
    TSong(name:String, diff:String);
}

typedef Score = {
    var score:Int;
    var misses:Int;
    var accuracy:Float;
}