package game;

class SongEvent {
	public var time:Float;
	public var type:SongEventType;

	public function new(time:Float, type:SongEventType) {
		this.time = time;
		this.type = type;
	}
}
enum SongEventType {
	ECameraMove(target:Int);
	EPsychEvent(name:String, p1:String, p2:String);
}