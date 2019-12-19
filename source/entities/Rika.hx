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

class Rika extends Boss
{
    public static inline var SPEED = 50;

    public static inline var SPOUT_SHOT_SPEED = 100;
    public static inline var SPOUT_SHOT_SPREAD = 3.1415 / 5;
    public static inline var SPOUT_SHOT_INTERVAL = 2.5;

    private var sprite:Spritemap;
    private var path:LinearPath;
    private var spoutShotInterval:Alarm;

    public function new(startX:Float, startY:Float, pathPoints:Array<Vector2>) {
        super(startX, startY);
        name = "rika";
        mask = new Hitbox(48, 48);
        startingHealth = 1000;
        health = startingHealth;
        sprite = new Spritemap("graphics/rika.png", 48, 48);
        sprite.add("idle", [0]);
        sprite.add("enrage", [1]);
        graphic = sprite;

        path = new LinearPath(TweenType.Looping);
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        addTween(path, true);
        
        spoutShotInterval = new Alarm(
            SPOUT_SHOT_INTERVAL, TweenType.Looping
        );
        spoutShotInterval.onComplete.bind(function() {
            spoutShot();
        });
        addTween(spoutShotInterval, true);
    }

    private function spoutShot() {
        var spreadAngles = getSpreadAngles(3, SPOUT_SHOT_SPREAD);
        for(spreadAngle in spreadAngles) {
            var shotAngle = getAngleTowardsPlayer() + spreadAngle;
            var shotVector = new Vector2(
                Math.cos(shotAngle), Math.sin(shotAngle)
            );
            scene.add(new Bullet(
                centerX, centerY, shotVector, SPOUT_SHOT_SPEED, 0x00FD00, 10
            ));
        }
    }

    override public function die() {
        if(scene.getInstance("satoko") != null) {
            cast(scene.getInstance("satoko"), Satoko).enrage();
        }
        super.die();
    }

    public function enrage() {
        spoutShotInterval.multiplySpeed(2);
        path.multiplySpeed(2);
        sprite.play("enrage");
    }

    override public function update() {
        x = path.x;
        y = path.y;
        super.update();
    }
}
