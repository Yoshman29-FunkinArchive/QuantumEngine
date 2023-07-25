package backend;

import flixel.FlxCamera;

class FunkinCamera extends FlxCamera {
	/**
	* Updates camera's scroll.
	* Called every frame by camera's `update()` method (if camera's `target` isn't `null`).
	*/
	public override function updateFollow():Void
	{
	   // Either follow the object closely,
	   // or double check our deadzone and update accordingly.
	   if (deadzone == null)
	   {
		   target.getMidpoint(_point);
		   _point.addPoint(targetOffset);
		   focusOn(_point);
	   }
	   else
	   {
		   var edge:Float;
		   var targetX:Float = target.x + targetOffset.x;
		   var targetY:Float = target.y + targetOffset.y;

		   if (style == SCREEN_BY_SCREEN)
		   {
			   if (targetX >= (scroll.x + width))
			   {
				   _scrollTarget.x += width;
			   }
			   else if (targetX < scroll.x)
			   {
				   _scrollTarget.x -= width;
			   }

			   if (targetY >= (scroll.y + height))
			   {
				   _scrollTarget.y += height;
			   }
			   else if (targetY < scroll.y)
			   {
				   _scrollTarget.y -= height;
			   }
		   }
		   else
		   {
			   edge = targetX - deadzone.x;
			   if (_scrollTarget.x > edge)
			   {
				   _scrollTarget.x = edge;
			   }
			   edge = targetX + target.width - deadzone.x - deadzone.width;
			   if (_scrollTarget.x < edge)
			   {
				   _scrollTarget.x = edge;
			   }

			   edge = targetY - deadzone.y;
			   if (_scrollTarget.y > edge)
			   {
				   _scrollTarget.y = edge;
			   }
			   edge = targetY + target.height - deadzone.y - deadzone.height;
			   if (_scrollTarget.y < edge)
			   {
				   _scrollTarget.y = edge;
			   }
		   }

		   if ((target is FlxSprite))
		   {
			   if (_lastTargetPosition == null)
			   {
				   _lastTargetPosition = FlxPoint.get(target.x, target.y); // Creates this point.
			   }
			   _scrollTarget.x += (target.x - _lastTargetPosition.x) * followLead.x;
			   _scrollTarget.y += (target.y - _lastTargetPosition.y) * followLead.y;

			   _lastTargetPosition.x = target.x;
			   _lastTargetPosition.y = target.y;
		   }

		   if (followLerp >= 1)
		   {
			   scroll.copyFrom(_scrollTarget); // no easing
		   }
		   else
		   {
			   scroll.x = FlxMath.lerp(scroll.x, _scrollTarget.x, followLerp * FlxG.elapsed * 60);
			   scroll.y = FlxMath.lerp(scroll.y, _scrollTarget.y, followLerp * FlxG.elapsed * 60);
		   }
	   }
	}
}