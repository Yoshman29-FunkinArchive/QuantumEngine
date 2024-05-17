package save;

@:keep
class FunkinSave extends SaveData {
    public var scores:Map<ScoreType, Score> = [];

    public function saveScore(type:ScoreType, score:Score, force:Bool = false) {
        var savedScore = getScore(type);

        if (force || savedScore.score < score.score || (savedScore.score == score.score && savedScore.accuracy < score.accuracy))
            scores[type] = score;

        SaveManager.flush();
    }

    public function getScore(type:ScoreType):Score {
        if (scores.exists(type) && scores[type] != null)
            return scores[type];
        return {
            score: 0,
            misses: 0,
            accuracy: 0
        };
    }
}

enum ScoreType {
    TSong(name:String, diff:String);
    TWeek(id:String, diff:String);
}

typedef Score = {
    var score:Int;
    var misses:Int;
    var accuracy:Float;
}