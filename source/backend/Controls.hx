package backend;

import save.EngineSettings.ControlData;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction.FlxActionDigital;

@:build(backend.macros.ControlsMacro.buildControls())
class Controls {
	public static var pressed:ControlResolver = new ControlResolver(PRESSED);
	public static var released:ControlResolver = new ControlResolver(RELEASED);
	public static var justPressed:ControlResolver = new ControlResolver(JUST_PRESSED);
	public static var justReleased:ControlResolver = new ControlResolver(JUST_RELEASED);
	
	public static function init() {}

	/**
	 * CONTROLS HERE
	 * CONTROLS MUST BE FULLY CAPITALIZED FOR IT TO BE RECOGNIZED BY THE MACRO
	 */
	public static var LEFT = new ActionControl("ui_left", [FlxKey.LEFT, FlxKey.A]);
	public static var DOWN = new ActionControl("ui_down", [FlxKey.DOWN, FlxKey.S]);
	public static var UP = new ActionControl("ui_up", [FlxKey.UP, FlxKey.W]);
	public static var RIGHT = new ActionControl("ui_right", [FlxKey.RIGHT, FlxKey.D]);
	public static var ACCEPT = new ActionControl("ui_accept", [FlxKey.ENTER]);
	public static var BACK = new ActionControl("ui_back", [FlxKey.ESCAPE, FlxKey.BACKSPACE]);

	public static var NOTE_LEFT = new ActionControl("note_left", [FlxKey.LEFT, FlxKey.A]);
	public static var NOTE_DOWN = new ActionControl("note_down", [FlxKey.DOWN, FlxKey.S]);
	public static var NOTE_UP = new ActionControl("note_up", [FlxKey.UP, FlxKey.W]);
	public static var NOTE_RIGHT = new ActionControl("note_right", [FlxKey.RIGHT, FlxKey.D]);
	public static var PAUSE = new ActionControl("pause", [FlxKey.ENTER, FlxKey.P, FlxKey.ESCAPE]);
	public static var RESET = new ActionControl("reset", [FlxKey.R]);

}

@:build(backend.macros.ControlsMacro.buildControlResolver())
class ControlResolver {
	public var state:FlxInputState;
	public function new(state:FlxInputState) {
		this.state = state;
	}
}

class ActionControl {
	public var __pressed:FlxActionDigital = new FlxActionDigital();
	public var __justPressed:FlxActionDigital = new FlxActionDigital();
	public var __justReleased:FlxActionDigital = new FlxActionDigital();
	public var __released:FlxActionDigital = new FlxActionDigital();

	public var saveID:String;
	public var defaultKeys:Array<FlxKey> = [];

	public var controlData:ControlData = {
		keybinds: null
	};

	public function new(saveID:String, defaultKeys:Array<FlxKey>) {
		this.saveID = saveID;
		this.defaultKeys = defaultKeys;
	}

	public function init() {
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