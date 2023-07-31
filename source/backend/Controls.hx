package backend;

import save.EngineSettings.ControlData;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction.FlxActionDigital;

class Controls {
	public static var controls:Map<String, ActionControl> = [];

	public static function init() {
		controls = [
			// UI
			"LEFT" => new ActionControl("ui_left", [FlxKey.LEFT, FlxKey.A]),
			"DOWN" => new ActionControl("ui_down", [FlxKey.DOWN, FlxKey.S]),
			"UP" => new ActionControl("ui_up", [FlxKey.UP, FlxKey.W]),
			"RIGHT" => new ActionControl("ui_right", [FlxKey.RIGHT, FlxKey.D]),
			"ACCEPT" => new ActionControl("ui_accept", [FlxKey.ENTER]),
			"BACK" => new ActionControl("ui_back", [FlxKey.ESCAPE, FlxKey.BACKSPACE]),
	
			// INGAME
			"NOTE_LEFT" => new ActionControl("note_left", [FlxKey.LEFT, FlxKey.A]),
			"NOTE_DOWN" => new ActionControl("note_down", [FlxKey.DOWN, FlxKey.S]),
			"NOTE_UP" => new ActionControl("note_up", [FlxKey.UP, FlxKey.W]),
			"NOTE_RIGHT" => new ActionControl("note_right", [FlxKey.RIGHT, FlxKey.D]),
			"PAUSE" => new ActionControl("pause", [FlxKey.ENTER, FlxKey.P, FlxKey.ESCAPE]),
			"RESET" => new ActionControl("reset", [FlxKey.R]),
		];
	}

	public static var pressed:ControlResolver = new ControlResolver(PRESSED);
	public static var released:ControlResolver = new ControlResolver(RELEASED);
	public static var justPressed:ControlResolver = new ControlResolver(JUST_PRESSED);
	public static var justReleased:ControlResolver = new ControlResolver(JUST_RELEASED);
}


class ControlResolver {
	public var state:FlxInputState;
	public function new(state:FlxInputState) {
		this.state = state;
	}

	/**
	 * UI
	 */
	public var LEFT(get, null):Bool;
	private inline function get_LEFT()
		return Controls.controls["LEFT"].getState(state);

	public var DOWN(get, null):Bool;
	private inline function get_DOWN()
		return Controls.controls["DOWN"].getState(state);

	public var UP(get, null):Bool;
	private inline function get_UP()
		return Controls.controls["UP"].getState(state);

	public var RIGHT(get, null):Bool;
	private inline function get_RIGHT()
		return Controls.controls["RIGHT"].getState(state);

	public var ACCEPT(get, null):Bool;
	private inline function get_ACCEPT()
		return Controls.controls["ACCEPT"].getState(state);

	public var BACK(get, null):Bool;
	private inline function get_BACK()
		return Controls.controls["BACK"].getState(state);

	/**
	 * IN-GAME
	 */
	public var LEFT_NOTE(get, null):Bool;
	private inline function get_LEFT_NOTE()
		return Controls.controls["LEFT_NOTE"].getState(state);

	public var DOWN_NOTE(get, null):Bool;
	private inline function get_DOWN_NOTE()
		return Controls.controls["DOWN_NOTE"].getState(state);

	public var UP_NOTE(get, null):Bool;
	private inline function get_UP_NOTE()
		return Controls.controls["UP_NOTE"].getState(state);

	public var RIGHT_NOTE(get, null):Bool;
	private inline function get_RIGHT_NOTE()
		return Controls.controls["RIGHT_NOTE"].getState(state);

	public var PAUSE(get, null):Bool;
	private inline function get_PAUSE()
		return Controls.controls["PAUSE"].getState(state);

	public var RESET(get, null):Bool;
	private inline function get_RESET()
		return Controls.controls["RESET"].getState(state);
}

class ActionControl {
	public var __pressed:FlxActionDigital = new FlxActionDigital();
	public var __justPressed:FlxActionDigital = new FlxActionDigital();
	public var __justReleased:FlxActionDigital = new FlxActionDigital();
	public var __released:FlxActionDigital = new FlxActionDigital();

	public var saveID:String;

	public var controlData:ControlData = {
		keybinds: null
	};

	public function new(saveID:String, defaultKeys:Array<FlxKey>) {
		this.saveID = saveID;

		// try to load 
		var savedData = SaveManager.settings.controls[saveID];

		if (savedData != null) {
			controlData.keybinds = savedData.keybinds == null ? defaultKeys.copy() : savedData.keybinds;
		} else {
			controlData.keybinds = defaultKeys;
		}
		
		// save new settings
		SaveManager.settings.controls[saveID] = controlData;

		// load
		for(k in controlData.keybinds)
			addKey(k);
	}

	public inline function getState(state:FlxInputState)
		return (switch(state) {
			case PRESSED: __pressed;
			case JUST_PRESSED: __justPressed;
			case JUST_RELEASED: __justReleased;
			case RELEASED: __released;
			default: __pressed;
		}).check();

	public function addKey(key:FlxKey) {
		__pressed.addKey(key, PRESSED);
		__justPressed.addKey(key, JUST_PRESSED);
		__justReleased.addKey(key, JUST_RELEASED);
		__released.addKey(key, JUST_RELEASED);
	}

	public function addGamepad(InputID:FlxGamepadInputID, GamepadID:Int = FlxInputDeviceID.ALL) {
		__pressed.addGamepad(InputID, PRESSED, GamepadID);
		__justPressed.addGamepad(InputID, JUST_PRESSED, GamepadID);
		__justReleased.addGamepad(InputID, JUST_RELEASED, GamepadID);
		__released.addGamepad(InputID, JUST_RELEASED, GamepadID);
	}

	public var pressed(get, null):Bool;
	public var justPressed(get, null):Bool;
	public var justReleased(get, null):Bool;

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}
	private inline function get_pressed()
		return __pressed.check();
	private inline function get_justPressed()
		return __justPressed.check();
	private inline function get_justReleased()
		return __justReleased.check();
}