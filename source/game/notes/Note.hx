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
		if (autoUpdatePosition) {
			updatePosition(parent.members[strumID]);
			if (isSustainNote && prevNote != null && prevNote.autoUpdatePosition && !prevNote.exists) {
				prevNote.updatePosition(parent.members[strumID]);
			}
		}

		centerOffsets();
		centerOrigin();
		offset.x += width / 2;
		offset.y += height / 2;
	}

	public function updateInput() {
		if (endSustain) {
			canBeHit = tooLate = false;
			if (Conductor.instance.songPosition > time + __endSusLen)
				delete();
			return;
		}

		canBeHit = (time > Conductor.instance.songPosition - latePressWindow && time < Conductor.instance.songPosition + earlyPressWindow);

		if (time < Conductor.instance.songPosition - missWindow && !wasGoodHit)
			tooLate = true;
	}

	var __lastStrum:Strum;
	var __endSusLen:Float = 0;
	public function updatePosition(strum:Strum) {
		__lastStrum = strum;
		if (angle != strum.angle)
			angle = strum.angle;

		if (endSustain)
			__endSusLen = ((_frame.frame.height * scale.y) / (prevNote.sustainLength * __lastStrum.speed) * prevNote.sustainLength);
		// TODO: scroll speed and angle support
		var yOffset:Float = ((time - Conductor.instance.songPosition) * strum.speed);
		this.setPosition(strum.x - (yOffset * __angleSin), strum.y + (yOffset * __angleCos));
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
		if (parent != null)
			parent.notes.updateUpdateID();
	}


	var __triangles = Vector.ofArray([0, 1, 2, /**/ 1, 2, 3]);
	var __vertexPos = Vector.ofArray([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);
	var __colors = Vector.ofArray([0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF, 0xFFFFFFFF]);
	var __uv = Vector.ofArray([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]);

	public var __angleSin:Float = 0;
	public var __angleCos:Float = 0;
	private override function set_angle(v:Float) {
		__angleSin = Math.sin(v * FlxAngle.TO_RAD);
		__angleCos = Math.cos(v * FlxAngle.TO_RAD);
		return super.set_angle(v);
	}

	public override function draw() {
		if (isSustainNote && prevNote != null) {
			#if debug
			FlxBasic.visibleCount++;
			#end	
			for(c in cameras) {
				var topPos:FlxPoint;
				var bottomPos:FlxPoint;
				var xOffsetTop:Float = 0;
				var yOffsetTop:Float = 0;
				var xOffsetBottom:Float = 0;
				var yOffsetBottom:Float = 0;
				var ratio:Float = 0;
				
				if (endSustain) {
					topPos = getScreenPosition(FlxPoint.get(), c);
					bottomPos = FlxPoint.get(topPos.x - (__angleSin * _frame.frame.height * scale.y), topPos.y + (__angleCos * _frame.frame.height * scale.y));

					ratio = FlxMath.bound((Conductor.instance.songPosition - time) / __endSusLen, 0, 1);

					topPos.x = FlxMath.lerp(topPos.x, bottomPos.x, ratio);
					topPos.y = FlxMath.lerp(topPos.y, bottomPos.y, ratio);


					xOffsetTop = xOffsetBottom = (width / 2) * __angleCos;
					yOffsetTop = yOffsetBottom = (width / 2) * __angleSin;
				} else {
					topPos = prevNote.getScreenPosition(FlxPoint.get(), c);
					bottomPos = getScreenPosition(FlxPoint.get(), c);

					if (!prevNote.exists) {
						ratio = FlxMath.bound((Conductor.instance.songPosition - prevNote.time) / (time - prevNote.time), 0, 1);

						topPos.x = FlxMath.lerp(topPos.x, bottomPos.x, ratio);
						topPos.y = FlxMath.lerp(topPos.y, bottomPos.y, ratio);
					}

					xOffsetTop = (width / 2) * prevNote.__angleCos;
					yOffsetTop = (width / 2) * prevNote.__angleSin;
					xOffsetBottom = (width / 2) * __angleCos;
					yOffsetBottom = (width / 2) * __angleSin;
					
				}

				var uv = _frame.uv;
				var uvY = FlxMath.lerp(uv.y, uv.height, ratio);

				// tl
				__uv[0] = uv.x;
				__uv[1] = uvY;
				// tr
				__uv[2] = uv.width;
				__uv[3] = uvY;
				// bl
				__uv[4] = uv.x;
				__uv[5] = uv.height;
				// br
				__uv[6] = uv.width;
				__uv[7] = uv.height;

				// tl
				__vertexPos[0] = topPos.x - xOffsetTop;
				__vertexPos[1] = topPos.y - yOffsetTop;
				// tr
				__vertexPos[2] = topPos.x + xOffsetTop;
				__vertexPos[3] = topPos.y + yOffsetTop;
				// bl
				__vertexPos[4] = bottomPos.x - xOffsetBottom;
				__vertexPos[5] = bottomPos.y - yOffsetBottom;
				// br
				__vertexPos[6] = bottomPos.x + xOffsetBottom;
				__vertexPos[7] = bottomPos.y + yOffsetBottom;

				c.drawTriangles(_frame.parent, __vertexPos, __triangles, __uv, null, null, blend, false, antialiasing, colorTransform, shader);
				
				topPos.put();
				bottomPos.put();

				topPos.put();
				bottomPos.put();
			}

			return;
		}
		super.draw();
	}
}