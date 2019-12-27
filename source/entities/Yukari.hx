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

class Yukari extends Boss
{
    public static inline var SPEED = 50;

    public static inline var BOUNCE_BULLETS_PER_SHOT = 10;
    public static inline var BOUNCE_SHOT_SPEED = 75;

    public static inline var SPOUT_SHOT_SPEED = 100;
    public static inline var SPOUT_SHOT_SPREAD = 3.1415 / 5;
    public static inline var SPOUT_SHOT_INTERVAL = 2.5;

    private var sprite:Spritemap;
    private var path:LinearPath;
    private var hasFiredBounceShot:Bool;
    private var spoutShotInterval:Alarm;

    public function new(
        startX:Float, startY:Float, pathPoints:Array<Vector2>
    ) {
        super(startX, startY);
        name = "yukari";
        mask = new Hitbox(80, 80);
        startingHealth = 666;
        health = startingHealth;
        sprite = new Spritemap("graphics/yukari.png", 80, 80);
        sprite.add("idle", [0]);
        graphic = sprite;

        path = new LinearPath(TweenType.Looping);
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        addTween(path, true);
        hasFiredBounceShot = false;

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
        var count = 0;
        for(spreadAngle in spreadAngles) {
            var shotAngle = getAngleTowardsPlayer() + spreadAngle;
            var shotVector = new Vector2(
                Math.cos(shotAngle), Math.sin(shotAngle)
            );
            scene.add(new Bullet(
                centerX, centerY, shotVector,
                count == 1 ? SPOUT_SHOT_SPEED * 1.25 : SPOUT_SHOT_SPEED,
                0x00FD00, 10
            ));
            count++;
        }
    }

    private function bounceShot() {
        var shotVector = new Vector2(1, 1);
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            BOUNCE_SHOT_SPEED, 0xFFFF00, 12, true
        ));
        shotVector = new Vector2(-1, 1);
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            BOUNCE_SHOT_SPEED, 0xFFFF00, 12, true
        ));
        shotVector = new Vector2(-1, -1);
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            BOUNCE_SHOT_SPEED, 0xFFFF00, 12, true
        ));
        shotVector = new Vector2(1, -1);
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            BOUNCE_SHOT_SPEED, 0xFFFF00, 12, true
        ));
    }

    override public function die() {
        var bounceBullets = new Array<Entity>();
        scene.getType("hazard", bounceBullets);
        for(bounceBullet in bounceBullets) {
            if(Type.getClass(bounceBullet) == Bullet) {
                cast(bounceBullet, Bullet).setIsBounceShot(false);
            }
        }
        super.die();
    }

    override public function update() {
        if(!hasFiredBounceShot) {
            bounceShot();
            hasFiredBounceShot = true;
        }
        x = path.x;
        y = path.y;
        super.update();
    }
}

