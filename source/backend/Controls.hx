package backend;

import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction.FlxActionDigital;

class Controls {
	// UI
	public static var LEFT = new ActionControl("ui_left", [FlxKey.LEFT, FlxKey.A]);
	public static var DOWN = new ActionControl("ui_down", [FlxKey.DOWN, FlxKey.S]);
	public static var UP = new ActionControl("ui_up", [FlxKey.UP, FlxKey.W]);
	public static var RIGHT = new ActionControl("ui_right", [FlxKey.RIGHT, FlxKey.D]);
	public static var ACCEPT = new ActionControl("ui_accept", [FlxKey.ENTER]);
	public static var BACK = new ActionControl("ui_back", [FlxKey.ESCAPE, FlxKey.BACKSPACE]);

	// INGAME
	public static var LEFT_NOTE = new ActionControl("note_left", [FlxKey.LEFT, FlxKey.A]);
	public static var DOWN_NOTE = new ActionControl("note_down", [FlxKey.DOWN, FlxKey.S]);
	public static var UP_NOTE = new ActionControl("note_up", [FlxKey.UP, FlxKey.W]);
	public static var RIGHT_NOTE = new ActionControl("note_right", [FlxKey.RIGHT, FlxKey.D]);
	public static var PAUSE = new ActionControl("pause", [FlxKey.ENTER, FlxKey.P, FlxKey.ESCAPE]);
	public static var RESET = new ActionControl("reset", [FlxKey.R]);

	public static function init() {
		
	}
}

class ActionControl {
    public var __pressed:FlxActionDigital = new FlxActionDigital();
    public var __justPressed:FlxActionDigital = new FlxActionDigital();
    public var __justReleased:FlxActionDigital = new FlxActionDigital();

	public var saveID:String;

    public function new(saveID:String, defaultKeys:Array<FlxKey>) {
		this.saveID = saveID;
		// TODO: Save keybinds

		for(k in defaultKeys)
			addKey(k);
	}

	public var pressed(get, null):Bool;
	public var justPressed(get, null):Bool;
	public var justReleased(get, null):Bool;

	private inline function get_pressed()
		return __pressed.check();
	private inline function get_justPressed()
		return __justPressed.check();
	private inline function get_justReleased()
		return __justReleased.check();

	public function addKey(key:FlxKey) {
		__pressed.addKey(key, PRESSED);
		__justPressed.addKey(key, JUST_PRESSED);
		__justReleased.addKey(key, JUST_RELEASED);
	}

	public function addGamepad(InputID:FlxGamepadInputID, GamepadID:Int = FlxInputDeviceID.ALL) {
		__pressed.addGamepad(InputID, PRESSED, GamepadID);
		__justPressed.addGamepad(InputID, JUST_PRESSED, GamepadID);
		__justReleased.addGamepad(InputID, JUST_RELEASED, GamepadID);
	}
}