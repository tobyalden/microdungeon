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

class Darude extends Boss
{
    public static inline var BOUNCE_BULLETS_PER_SHOT = 2;
    public static inline var BOUNCE_SHOT_SPEED = 150;
    public static inline var ARC_SHOT_SPEED = 150;
    public static inline var ARC_SHOT_INTERVAL = 0.6;

    private var sprite:Spritemap;
    private var hasFiredBounceShot:Bool;
    private var arcShotInterval:Alarm;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        name = "darude";
        mask = new Hitbox(75, 75);
        startingHealth = 666;
        health = startingHealth;
        sprite = new Spritemap("graphics/darude.png", 75, 75);
        sprite.add("idle", [0]);
        graphic = sprite;

        arcShotInterval = new Alarm(
            ARC_SHOT_INTERVAL, TweenType.Looping
        );
        arcShotInterval.onComplete.bind(function() {
            arcShot();
        });
        addTween(arcShotInterval, true);

        hasFiredBounceShot = false;
    }


    private function bounceShot() {
        var spreadAngles = getSpreadAngles(
            BOUNCE_BULLETS_PER_SHOT, Math.PI * 2
        );
        for(i in 0...BOUNCE_BULLETS_PER_SHOT) {
            var shotAngle = spreadAngles[i] + Math.PI / 2 + 1100;
            var shotVector = new Vector2(
                Math.cos(shotAngle), Math.sin(shotAngle)
            );
            scene.add(new Bullet(
                centerX, centerY, shotVector,
                BOUNCE_SHOT_SPEED, 0xFFFF00, 12, true
            ));
        }
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

    private function arcShot() {
        var shotAngle = getAngleTowardsPlayer();
        var shotVector = new Vector2(
            Math.cos(shotAngle),
            Math.sin(shotAngle) - Math.max(Math.random(), 0.2) * 2.5
        );
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            ARC_SHOT_SPEED / 2 + ARC_SHOT_SPEED * Math.min(Math.random(), 0.8),
            0xFF2600, 10, false, true
        ));
    }

    override public function update() {
        if(!hasFiredBounceShot) {
            bounceShot();
            arcShot();
            hasFiredBounceShot = true;
        }
        super.update();
    }
}

