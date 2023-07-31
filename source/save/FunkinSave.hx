package save;

@:keep
class FunkinSave extends SaveData {
    public var scores:Map<ScoreType, Score> = [];

    public function setSongScore(name:String, diff:String, score:Score, force:Bool = false) {
        var savedScore = getSongScore(name, diff);

        if (force || savedScore.score < score.score || (savedScore.score == score.score && savedScore.accuracy < score.accuracy))
            scores[TSong(name, diff)] = score;

        SaveManager.flush();
    }

    public function getSongScore(name:String, diff:String):Score {
        if (scores.exists(TSong(name, diff)) && scores[TSong(name, diff)] != null)
            return scores[TSong(name, diff)];
        return {
            score: 0,
            misses: 0,
            accuracy: 0
        };
    }
}

enum ScoreType {
    TSong(name:String, diff:String);
}

typedef Score = {
    var score:Int;
    var misses:Int;
    var accuracy:Float;
}