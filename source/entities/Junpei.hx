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

class Junpei extends Boss
{
    public static inline var CHASE_ACCEL = 1.5;
    public static inline var MAX_CHASE_SPEED = 80;
    public static inline var SPOUT_SHOT_SPEED = 150;
    public static inline var SPOUT_SHOT_INTERVAL = 1.5;

    public static inline var RIPPLE_SHOT_SPEED = 100;
    public static inline var RIPPLE_SHOT_SPREAD = 15;
    public static inline var RIPPLE_SHOT_INTERVAL = 2.7;
    public static inline var RIPPLE_BULLETS_PER_SHOT = 13;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var spoutShotInterval:Alarm;
    private var rippleShotInterval:Alarm;
    private var isEnraged:Bool;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        name = "junpei";
        mask = new Hitbox(50, 25);
        startingHealth = 333;
        health = startingHealth;
        sprite = new Spritemap("graphics/junpei.png", 50, 25);
        sprite.add("idle", [0]);
        sprite.add("enrage", [1]);
        graphic = sprite;

        velocity = new Vector2();
        isEnraged = false;

        spoutShotInterval = new Alarm(
            SPOUT_SHOT_INTERVAL, TweenType.Looping
        );
        spoutShotInterval.onComplete.bind(function() {
            spoutShot();
        });
        //addTween(spoutShotInterval, true);

        rippleShotInterval = new Alarm(
            RIPPLE_SHOT_INTERVAL, TweenType.Looping
        );
        rippleShotInterval.onComplete.bind(function() {
            rippleShot();
        });
        //addTween(rippleShotInterval, true);
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

    override public function die() {
        if(scene.getInstance("stupei") != null) {
            cast(scene.getInstance("stupei"), Stupei).enrage();
        }
        super.die();
    }

    public function enrage() {
        sprite.play("enrage");
        isEnraged = true;
    }

    override public function update() {
        var acceleration = new Vector2(
            Math.cos(getAngleTowardsPlayer()), Math.sin(getAngleTowardsPlayer())
        );
        acceleration.normalize(isEnraged ? CHASE_ACCEL * 1.5 : CHASE_ACCEL);
        velocity.add(acceleration);

        var stupei = scene.getInstance("stupei");
        if(stupei != null) {
            var awayFromStupei = new Vector2(
                Math.cos(getAngleTowardsEntity(stupei)),
                Math.sin(getAngleTowardsEntity(stupei))
            );
            awayFromStupei.inverse();
            var isClose = distanceFrom(stupei, true) < 50;
            awayFromStupei.normalize(CHASE_ACCEL / (isClose ? 1 : 4));
            velocity.add(awayFromStupei);
        }

        var maxChaseSpeed = isEnraged ? MAX_CHASE_SPEED * 1.5 : MAX_CHASE_SPEED;
        if(velocity.length > maxChaseSpeed) {
            velocity.normalize(maxChaseSpeed);
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["walls", "boss"]);
        super.update();
    }
}

