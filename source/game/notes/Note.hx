package game.notes;

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

	public static var swagWidth:Float = 160 * 0.7;
	
	// The * 0.5 is so that it's easier to hit them too late, instead of too early
	public var earlyPressWindow:Float = 125;
	public var latePressWindow:Float = 250;
	public var missWindow:Float = 250;

	public function new(parent:StrumLine, data:ChartNote, isSustainNote:Bool = false, sustainOffset:Float = 0, sustainLength:Float = 0, endSustain:Bool = false)
	{
		super();
		this.parent = parent;
		this.strumID = data.strum % parent.members.length;
		this.time = data.time + sustainOffset;
		this.isSustainNote = isSustainNote;
		this.sustainOffset = sustainOffset;
		this.sustainLength = sustainLength;
		this.endSustain = endSustain;

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
		updatePosition(parent.members[strumID]);
        
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
		if (isSustainNote) {
			if (endSustain) {
				yOffset -= ((1 - scale.y) / 2) * frameHeight;
				yOffset += scale.y * frameHeight;
			}
			else
				yOffset += swagWidth / 2;
		}

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
			PlayState.instance.stats.misses++;
		delete();
	}

	public function delete() {
		destroy();
		exists = false;
	}
}