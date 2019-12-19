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

class Rena extends Boss
{
    public static inline var MAX_HEALTH = 1000;
    public static inline var SPOUT_SHOT_SPEED = 150;
    public static inline var SPOUT_SHOT_INTERVAL = 1.5;

    public static inline var RIPPLE_SHOT_SPEED = 100;
    public static inline var RIPPLE_SHOT_SPREAD = 15;
    public static inline var RIPPLE_SHOT_INTERVAL = 2.7;
    public static inline var RIPPLE_BULLETS_PER_SHOT = 13;

    private var sprite:Spritemap;
    private var spoutShotInterval:Alarm;
    private var rippleShotInterval:Alarm;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        name = "rena";
        mask = new Hitbox(75, 75);
        health = MAX_HEALTH;
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

        rippleShotInterval = new Alarm(
            RIPPLE_SHOT_INTERVAL, TweenType.Looping
        );
        rippleShotInterval.onComplete.bind(function() {
            rippleShot();
        });
        addTween(rippleShotInterval, true);
    }

    private function spoutShot() {
        var shotAngle = getAngleTowardsPlayer();
        var shotVector = new Vector2(
            Math.cos(shotAngle), Math.sin(shotAngle)
        );
        scene.add(new Bullet(
            centerX, centerY, shotVector, SPOUT_SHOT_SPEED, 0x00FD00, 20
        ));
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
        super.update();
    }
}
