package;

import backend.plugins.Conductor.BPMChangeEvents;

/**
 * Class containing all of the game's configuration.
 */
class GameConfig {
    // TODO: BPMDEF FROM FILE
    public static final MENU_MUSIC_BPMDEF:BPMChangeEvents = [
        0 => {bpm: 102}
    ];

    public static final GAMEOVER_MUSIC_BPMDEF:BPMChangeEvents = [
        0 => {bpm: 100}
    ];
}