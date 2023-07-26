package game.stages;

import openfl.Vector;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxStrip;

@:keep
class Stage25DTest extends Stage {
	public override function create() {
		add(new FlxSprite25D(0, 0, 1000, 500, 0.25, 0.25, 'assets/kkmq9926w4g41.jpg'));
		var top = new FlxSprite25D(0, 0, 1000, 0, 0.25, 0.25, 'assets/kkmq9926w4g41.jpg');
		top.points[0].scrollX = 0;
		top.points[0].scrollY = 0;
		top.points[1].scrollX = 0;
		top.points[1].scrollY = 0;
		top.points[1].x = FlxG.width;
		add(top);

		var right = new FlxSprite25D(1000, 0, 0, 500, 0.25, 0.25, 'assets/kkmq9926w4g41.jpg');
		right.points[1].scrollX = 0;
		right.points[1].scrollY = 0;
		right.points[1].x = FlxG.width;
		right.points[3].scrollX = 0;
		right.points[3].scrollY = 0;
		right.points[3].x = FlxG.width;
		right.points[3].y = FlxG.height;
		add(right);

		var left = new FlxSprite25D(0, 0, 0, 500, 0.25, 0.25, 'assets/kkmq9926w4g41.jpg');
		left.points[0].scrollX = 0;
		left.points[0].scrollY = 0;
		left.points[3].scrollX = 0;
		left.points[3].scrollY = 0;
		left.points[3].y = FlxG.height;
		add(left);

		var down = new FlxSprite25D(0, 500, 1000, 0, 0.25, 0.25, 'assets/kkmq9926w4g41.jpg');
		down.points[2].scrollX = 0;
		down.points[2].scrollY = 0;
		down.points[3].scrollX = 0;
		down.points[3].scrollY = 0;

		down.points[2].y = FlxG.height;
		down.points[3].y = FlxG.height;
		down.points[3].x = FlxG.width;
		add(down);

		addCharGroup(400, 130, "girlfriend", false, 0.95, 0.95);
		addCharGroup(100, 100, "opponent");
		addCharGroup(770, 100, "player", true);
	}
}

class FlxSprite25D extends FlxStrip {
	public var points:Array<Flx25DPoint> = [
		{
			x: 0,
			y: 0,
			scrollX: 1,
			scrollY: 1
		},
		{
			x: 1000,
			y: 0,
			scrollX: 1,
			scrollY: 1
		},
		{
			x: 1000,
			y: 500,
			scrollX: 1,
			scrollY: 1
		},
		{
			x: 0,
			y: 500,
			scrollX: 1,
			scrollY: 1
		}
	];

	public function new(x:Float, y:Float, width:Float, height:Float, scrollX:Float, scrollY:Float, graphic:FlxGraphicAsset) {
		super(x, y, graphic);
		colors = Vector.ofArray([-1, -1, -1, -1]);
		indices = Vector.ofArray([0, 1, 2, 1, 2, 3]);
		repeat = true;
		scrollFactor.set(0, 0);
		setPosition(0, 0);
		uvtData = Vector.ofArray([0.0, 0, 1, 0, 0, 1, 1, 1]);
		vertices = Vector.ofArray([0.0, 0, 0, 0, 0, 0, 0, 0]);
		
		points[0].x = x;
		points[0].y = y;

		points[1].x = x + width;
		points[1].y = y;

		points[2].x = x;
		points[2].y = y + height;

		points[3].x = x + width;
		points[3].y = y + height;

		for(p in points) {
			p.scrollX = scrollX;
			p.scrollY = scrollY;
		}
	}

	public override function draw() {
		for(c in cameras) {
			if (!camera.visible || !camera.exists)
				continue;

			for(k=>p in points) {
				vertices[k*2] = p.x - (c.scroll.x * p.scrollX);
				vertices[(k*2)+1] = p.y - (c.scroll.y * p.scrollY);
			}

			#if !flash
			camera.drawTriangles(graphic, vertices, indices, uvtData, colors, null, blend, repeat, antialiasing, colorTransform, shader);
			#else
			camera.drawTriangles(graphic, vertices, indices, uvtData, colors, null, blend, repeat, antialiasing);
			#end
		}
	}
}

typedef Flx25DPoint = {
	var x:Float;
	var y:Float;
	var scrollX:Float;
	var scrollY:Float;
}