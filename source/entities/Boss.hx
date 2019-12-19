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

class Boss extends MiniEntity
{
    public var health(default, null):Int;
    public var startingHealth(default, null):Int;
    private var startPosition:Vector2;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        type = "boss";
        startPosition = new Vector2(startX, startY);
    }

    public function takeHit() {
        health -= 1;
        if(health <= 0) {
            scene.remove(this);
        }
    }

    public function getSpreadAngles(numAngles:Int, maxSpread:Float) {
        var spreadAngles = new Array<Float>();
        var startAngle = -maxSpread / 2;
        var angleIncrement = maxSpread / (numAngles - 1);
        for(i in 0...numAngles) {
            spreadAngles.push(startAngle + angleIncrement * i);
        }
        return spreadAngles;
    }

    public function getSprayAngles(numAngles:Int, maxSpread:Float) {
        var sprayAngles = new Array<Float>();
        for(i in 0...numAngles) {
            sprayAngles.push(-maxSpread / 2 + Random.random * maxSpread);
        }
        return sprayAngles;
    }

    public function getAngleTowardsPlayer() {
        var player = scene.getInstance("player");
        return (
            Math.atan2(
                player.centerY - centerY,
                player.centerX - centerX
            )
        );
    }
}
