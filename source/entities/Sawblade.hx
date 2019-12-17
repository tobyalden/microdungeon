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
    public static inline var CYCLE_TIME = 2.5;

    private var sprite:Spritemap;
    private var path:LinearMotion;

    public function new(startX:Float, startY:Float, pathEnd:Vector2) {
        super(startX, startY);
        type = "hazard";
        mask = new Circle(25);
        sprite = new Spritemap("graphics/sawblade.png", 50, 50);
        sprite.add("idle", [0]);
        graphic = sprite;
        path = new LinearMotion(TweenType.PingPong);
        path.setMotion(
            startX, startY, pathEnd.x, pathEnd.y, CYCLE_TIME
        );
        addTween(path, true);
    }

    override public function update() {
        moveTo(path.x, path.y);
        super.update();
    }
}
