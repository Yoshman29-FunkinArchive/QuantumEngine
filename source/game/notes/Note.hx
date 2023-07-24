package game.notes;

import flixel.math.FlxRect;
import flixel.math.FlxAngle;
import openfl.Vector;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import assets.chart.Chart.ChartNote;

using StringTools;

class Note extends FlxSprite
{
	// NOTE METADATA
	public var parent:StrumLine = null;
	public var time:Float = 0;
	public var strumID:Int = 0;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var endSustain:Bool = false;
	public var sustainOffset:Float = 0;

	// NOTE IN-GAME
	public var mustPress:Bool = false;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;

	public var mustHitCPU:Bool = true;
	public var autoUpdateInput:Bool = true;
	public var autoUpdatePosition:Bool = true;

	public var nextNote:Note = null;
	public var prevNote:Note = null;

	public static var swagWidth:Float = 160 * 0.7;
	
	// The * 0.5 is so that it's easier to hit them too late, instead of too early
	public var earlyPressWindow:Float = 125;
	public var latePressWindow:Float = 250;
	public var missWindow:Float = 250;

	public function new(parent:StrumLine, data:ChartNote, isSustainNote:Bool = false, sustainOffset:Float = 0, sustainLength:Float = 0, endSustain:Bool = false, prevNote:Note = null, nextNote:Note = null)
	{
		super();
		this.parent = parent;
		this.strumID = (parent == null) ? data.strum : (data.strum % parent.members.length);
		this.time = data.time + sustainOffset;
		this.isSustainNote = isSustainNote;
		this.sustainOffset = sustainOffset;
		this.sustainLength = sustainLength;
		this.endSustain = endSustain;
		this.prevNote = prevNote;
		this.nextNote = nextNote;

		create();

		if (isSustainNote) {
			if (endSustain) {
				animation.play("holdend");
			} else {
				animation.play("hold");
				scale.y = sustainLength / frameHeight;
				height = Math.abs(scale.y) * frameHeight;
				offset.y = -0.5 * (height - frameHeight);
			}
			alpha *= 0.6;
		} else {
			animation.play("scroll");
		}
		updateHitbox();
	}

	public override function update(elapsed:Float) {
		super.update(elapsed);
		
		if (autoUpdateInput)
			updateInput();
		if (autoUpdatePosition)
			updatePosition(parent.members[strumID]);
		if (isSustainNote && prevNote != null && prevNote.autoUpdatePosition && !prevNote.exists)
			prevNote.updatePosition(parent.members[strumID]);
        
        centerOffsets();
        centerOrigin();
        offset.x += width / 2;
        offset.y += height / 2;
	}

	public function updateInput() {
		canBeHit = (time > Conductor.instance.songPosition - latePressWindow && time < Conductor.instance.songPosition + earlyPressWindow);

		if (time < Conductor.instance.songPosition - missWindow && !wasGoodHit)
			tooLate = true;
	}

	public function updatePosition(strum:Strum) {
		// TODO: scroll speed and angle support
		var yOffset:Float = ((time - Conductor.instance.songPosition) / 1);
		this.setPosition(strum.x, strum.y + yOffset);
	}

	public function create() {}

	public function onHit(strumLine:StrumLine) {
		strumLine.character.playSingAnim(strumID, this);
		strumLine.members[strumID].confirm();
		if (!strumLine.cpu)
			PlayState.instance.stats.calculateRating(this);
		delete();
	}

	public function onMiss(strumLine:StrumLine) {
		strumLine.character.playMissAnim(strumID, this);
		if (!strumLine.cpu)
			PlayState.instance.stats.miss();
		delete();
	}

	public function delete() {
		exists = false;
	}

	public override function draw() {
		if (isSustainNote && prevNote != null) {
			

			// TODO: angle
			for(c in cameras) {
				var topPos = prevNote.getScreenPosition(FlxPoint.get(), c);
				var bottomPos = getScreenPosition(FlxPoint.get(), c);

				var ratio:Float = 0;
				if (!prevNote.exists) {
					ratio = FlxMath.bound((Conductor.instance.songPosition - prevNote.time) / (time - prevNote.time), 0, 1);

					topPos.x = FlxMath.lerp(topPos.x, bottomPos.x, ratio);
					topPos.y = FlxMath.lerp(topPos.y, bottomPos.y, ratio);
				}

				var xOffsetTop = (width / 2) * Math.cos(prevNote.angle * FlxAngle.TO_RAD);
				var yOffsetTop = (width / 2) * Math.sin(prevNote.angle * FlxAngle.TO_RAD);
				var xOffsetBottom = (width / 2) * Math.cos(angle * FlxAngle.TO_RAD);
				var yOffsetBottom = (width / 2) * Math.sin(angle * FlxAngle.TO_RAD);

				var uv = frame.uv;
				var uvY = FlxMath.lerp(uv.y, uv.height, ratio);



				// TODO: cache arrays and optimize
				c.drawTriangles(graphic, Vector.ofArray([
					topPos.x - xOffsetTop, topPos.y - yOffsetTop,
					topPos.x + xOffsetTop, topPos.y + yOffsetTop,
					bottomPos.x - xOffsetBottom, bottomPos.y - yOffsetBottom,
					bottomPos.x + xOffsetBottom, bottomPos.y + yOffsetBottom]),
					Vector.ofArray([
						0, 1, 2,
						1, 2, 3]),
					Vector.ofArray([
						uv.x, uvY,
						uv.width, uvY,
						uv.x, uv.height,
						uv.width, uv.height]),
					Vector.ofArray([0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF]),
					FlxPoint.weak(0, 0),
					blend, false, antialiasing, colorTransform, shader);
			}
			

			return;
		}
		super.draw();
	}
}