package game;

import flixel.util.FlxSort;

class EventHandler extends FlxBasic {
	public var events:Array<SongEvent> = [];
	public var curEvent:Int = 0;

	public var callback:SongEvent->Void;

	public function new(events:Array<SongEvent>, callback:SongEvent->Void) {
		super();
		this.events = events;
		this.callback = callback;

		events.sort((n1, n2) -> FlxSort.byValues(FlxSort.ASCENDING, n1.time, n2.time));
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		while(events[curEvent] != null && (events[curEvent].time < Conductor.instance.songPosition || events[curEvent].time <= 0)) {
			callback(events[curEvent]);
			curEvent++;
		}
	}
}