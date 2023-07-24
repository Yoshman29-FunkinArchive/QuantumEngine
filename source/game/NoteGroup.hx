package game;

import flixel.util.FlxSort;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteGroup extends FlxTypedGroup<Note> {var __loopSprite:Note;
	var i:Int = 0;
	var __currentlyLooping:Bool = false;

    public inline function allocate(amount:Int) {
        @:privateAccess {
            members = CoolUtil.allocArray(amount);
            length = amount;
        }
    }

	public inline function sortNotes() {
		sort(function(i, n1, n2) {
            if (n1 == null)
                return -1;
            if (n2 == null)
                return 1;
			if (n1.time == n2.time)
				return n1.isSustainNote ? 1 : -1;
			return FlxSort.byValues(FlxSort.DESCENDING, n1.time, n2.time);
		});
	}
	public override function update(elapsed:Float) {
		i = members.length-1;
		__loopSprite = null;
		while(i >= 0) {
			__loopSprite = members[i--];
			if (__loopSprite == null || !__loopSprite.exists || !__loopSprite.active) {
				continue;
			}
			if (__loopSprite.time - Conductor.instance.songPosition > 1500)
				break;
			__loopSprite.update(elapsed);
		}
	}

	public override function draw() {
		@:privateAccess var oldDefaultCameras = FlxCamera._defaultCameras;
		@:privateAccess if (cameras != null) FlxCamera._defaultCameras = cameras;

		var oldCur = __currentlyLooping;
		__currentlyLooping = true;

		i = members.length-1;
		__loopSprite = null;
		while(i >= 0) {
			__loopSprite = members[i--];
			if (__loopSprite == null || !__loopSprite.exists || !__loopSprite.visible)
				continue;
			if (__loopSprite.time - Conductor.instance.songPosition > 1500) break;
			if (__loopSprite.isSustainNote)
				__loopSprite.draw();
		}

		

		i = members.length-1;
		__loopSprite = null;
		while(i >= 0) {
			__loopSprite = members[i--];
			if (__loopSprite == null || !__loopSprite.exists || !__loopSprite.visible)
				continue;
			if (__loopSprite.time - Conductor.instance.songPosition > 1500) break;
			if (!__loopSprite.isSustainNote)
				__loopSprite.draw();
		}

		__currentlyLooping = oldCur;

		@:privateAccess FlxCamera._defaultCameras = oldDefaultCameras;
	}

	public override function forEach(noteFunc:Note->Void, recursive:Bool = false) {
		i = members.length-1;
		__loopSprite = null;
		
		var oldCur = __currentlyLooping;
		__currentlyLooping = true;

		while(i >= 0) {
			__loopSprite = members[i--];
			if (__loopSprite == null || !__loopSprite.exists)
				continue;
			if (__loopSprite.time - Conductor.instance.songPosition > 1500) break;
			noteFunc(__loopSprite);
		}
		__currentlyLooping = oldCur;
	}
	public override function forEachAlive(noteFunc:Note->Void, recursive:Bool = false) {
		forEach(function(note) {
			if (note.alive) noteFunc(note);
		}, recursive);
	}
	
	public override function remove(Object:Note, Splice:Bool = false):Note
	{
		if (members == null)
			return null;

		var index:Int = members.indexOfFromLast(Object);

		if (index < 0)
			return null;

		// doesnt prevent looping from breaking
		if (Splice && __currentlyLooping && i >= index)
			i++;

		if (Splice)
		{
			members.splice(index, 1);
			length--;
		}
		else
			members[index] = null;

		if (_memberRemoved != null)
			_memberRemoved.dispatch(Object);

		return Object;
	}
}