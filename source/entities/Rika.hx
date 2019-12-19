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

    public static inline var RIPPLE_SHOT_SPEED = 60;
    public static inline var RIPPLE_SHOT_INTERVAL = 7;
    public static inline var RIPPLE_BULLETS_PER_SHOT = 8;

    private var sprite:Spritemap;
    private var path:LinearPath;
    private var spoutShotInterval:Alarm;
    private var rippleShotInterval:Alarm;

    public function new(startX:Float, startY:Float, pathPoints:Array<Vector2>) {
        super(startX, startY);
        name = "rika";
        mask = new Hitbox(48, 48);
        startingHealth = 1000;
        health = startingHealth;
        sprite = new Spritemap("graphics/rika.png", 48, 48);
        sprite.add("idle", [0]);
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

        rippleShotInterval = new Alarm(
            RIPPLE_SHOT_INTERVAL, TweenType.Looping
        );
        rippleShotInterval.onComplete.bind(function() {
            rippleShot();
        });
        addTween(rippleShotInterval, true);
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

    private function rippleShot() {
        var spreadAngles = getSpreadAngles(
            RIPPLE_BULLETS_PER_SHOT, Math.PI * 2
        );
        var offset = Math.random() * Math.PI * 2;
        for(i in 0...RIPPLE_BULLETS_PER_SHOT) {
            var shotAngle = spreadAngles[i] + Math.PI / 2  + offset;
            var shotVector = new Vector2(
                Math.cos(shotAngle), Math.sin(shotAngle)
            );
            scene.add(new Bullet(
                centerX, centerY, shotVector,
                RIPPLE_SHOT_SPEED * (i % 2 == 0 ? 0.66 : 1.33),
                0x00FDFF, (i % 2 == 0 ? 12 : 16)
            ));
        }
    }

    override public function update() {
        x = path.x;
        y = path.y;
        super.update();
    }
}

