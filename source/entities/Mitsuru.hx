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

class Mitsuru extends Boss
{
    public static inline var SPOUT_SHOT_SPEED = 100;
    public static inline var SPOUT_SHOT_INTERVAL = 0.37;

    public static inline var SCATTER_SHOT_SPEED = 60;
    public static inline var SCATTER_SHOT_INTERVAL = 0.38;

    public static inline var BOUNCE_SHOT_SPEED = 100;

    private var sprite:Spritemap;
    private var spoutShotInterval:Alarm;
    private var scatterShotInterval:Alarm;
    private var hasFiredBounceShot:Bool;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        name = "mitsuru";
        mask = new Hitbox(75, 75);
        startingHealth = 666;
        health = startingHealth;
        sprite = new Spritemap("graphics/mitsuru.png", 75, 75);
        sprite.add("idle", [0]);
        graphic = sprite;

        spoutShotInterval = new Alarm(
            SPOUT_SHOT_INTERVAL, TweenType.Looping
        );
        spoutShotInterval.onComplete.bind(function() {
            spoutShot();
        });
        addTween(spoutShotInterval, true);

        scatterShotInterval = new Alarm(
            SCATTER_SHOT_INTERVAL, TweenType.Looping
        );
        scatterShotInterval.onComplete.bind(function() {
            scatterShot();
        });
        addTween(scatterShotInterval, true);

        hasFiredBounceShot = false;
    }

    private function spoutShot() {
        var shotAngle = age;
        var shotVector = new Vector2(
            Math.cos(shotAngle), Math.sin(shotAngle)
        );
        scene.add(new Bullet(
            centerX, centerY, shotVector, SPOUT_SHOT_SPEED, 0x00FD00, 10
        ));
        var secondShotVector = shotVector.clone();
        secondShotVector.inverse();
        scene.add(new Bullet(
            centerX, centerY, secondShotVector, SPOUT_SHOT_SPEED, 0x00FD00, 10
        ));
    }

    private function scatterShot() {
        var shotAngle = Math.PI * 2 * Math.random();
        var shotVector = new Vector2(
            Math.cos(shotAngle), Math.sin(shotAngle)
        );
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            MathUtil.lerp(
                SCATTER_SHOT_SPEED / 1.5,
                SCATTER_SHOT_SPEED * 1.5,
                Math.random()
            ),
            0x00FDFF, 15
        ));
    }

    private function bounceShot() {
        var shotVector = new Vector2(
            HXP.choose(0.5, 1, -1, -0.5),
            HXP.choose(0.5, 1, -1, -0.5)
        );
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            BOUNCE_SHOT_SPEED, 0xFFFF00, 15, true
        ));
        var secondShotVector = new Vector2(
            HXP.choose(0.5, 1, -1, -0.5),
            HXP.choose(0.5, 1, -1, -0.5)
        );
        while(
            shotVector.x == secondShotVector.x
            && shotVector.y == secondShotVector.y
        ) {
            secondShotVector = new Vector2(
                HXP.choose(0.5, 1, -1, -0.5),
                HXP.choose(0.5, 1, -1, -0.5)
            );
        }
        scene.add(new Bullet(
            centerX, centerY, secondShotVector,
            BOUNCE_SHOT_SPEED, 0xFFFF00, 15, true
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
        super.update();
    }
}

