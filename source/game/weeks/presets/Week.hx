package game.weeks.presets;

import game.modes.GameModeHandler;
import game.modes.StoryModeHandler;

/**
 * This class contains all the data for an in-game Week.
 */
class Week {
    /**
     * Week ID
     */
    public var id:String;

    public function new(id:String) {
        this.id = id;
    }
    
    /**
     * Returns the name of the week, shown in Story Menu.
     * @return String
     */
    public function getWeekName():String {
        return "UNTITLED WEEK";
    }

    /**
     * Returns a list of all songs for this week.
     * @param context Context in which this method is called.
     * @return Array<String>
     */
    public function getWeekSongs(context:SongContext):Array<String> {
        return [];
    }

    /**
     * Whenever the week should show in the Story Mode menu
     * @return Bool
     */
    public function showInMenu():Bool {
        return true;
    }

    /**
     * Returns whenever the week is unlocked or not.
     * @return Bool
     */
    public function isUnlocked():Bool {
        return true;
    }

    /**
     * Returns all week difficulties.
     * @return Array<String> Difficulties
     */
    public function getDifficulties():Array<String> {
        return ["easy", "normal", "hard"];
    }

    /**
     * Allows you to return a custom game mode handler for this week.
     * Returns a StoryModeHandler by default.
     * @return GameModeHandler handler
     */
    public function getGameMode(difficulty:String):GameModeHandler {
        return new StoryModeHandler(this, difficulty);
    }
}

enum SongContext {
    InGame;
    DisplayStoryMenu;
    Freeplay;
}