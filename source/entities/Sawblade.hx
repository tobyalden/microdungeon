package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;

class Sawblade extends MiniEntity
{
    private var sprite:Spritemap;
    private var path:LinearPath;

    public function new(
        startX:Float, startY:Float, speed:Float, pathPoints:Array<Vector2>
    ) {
        super(startX, startY);
        layer = 1;
        type = "hazard";
        mask = new Circle(24);
        sprite = new Spritemap("graphics/sawblade.png", 48, 48);
        sprite.add("idle", [0]);
        graphic = sprite;
        path = new LinearPath(TweenType.Looping);
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(speed);
        addTween(path, true);
    }

    override public function update() {
        super.update();
        moveTo(path.x, path.y);
    }
}
