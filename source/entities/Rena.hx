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

class Rena extends MiniEntity
{
    public static inline var SPOUT_SHOT_SPEED = 150;
    public static inline var SPOUT_SHOT_INTERVAL = 1.5;

    private var sprite:Spritemap;
    private var spoutShotInterval:Alarm;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        type = "hazard";
        mask = new Hitbox(75, 75);
        sprite = new Spritemap("graphics/rena.png", 75, 75);
        sprite.add("idle", [0]);
        graphic = sprite;

        spoutShotInterval = new Alarm(
            SPOUT_SHOT_INTERVAL, TweenType.Looping
        );
        spoutShotInterval.onComplete.bind(function() {
            spoutShot();
        });
        addTween(spoutShotInterval, true);
    }

    private function spoutShot() {
        var shotAngle = getAngleTowardsPlayer(20);
        var shotVector = new Vector2(
            Math.cos(shotAngle), Math.sin(shotAngle)
        );
        scene.add(new Bullet(centerX, centerY, shotVector, SPOUT_SHOT_SPEED));
    }

    override public function update() {
        super.update();
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

    public function getAngleTowardsPlayer(bulletSize:Float) {
        var player = scene.getInstance("player");
        return (
            Math.atan2(
                player.centerY - centerY - bulletSize / 2,
                player.centerX - centerX - bulletSize / 2
            )
        );
    }
}
