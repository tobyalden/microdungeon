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

class Ukyo extends Boss
{
    public static inline var SPEED = 50;

    public static inline var BOUNCE_BULLETS_PER_SHOT = 10;
    public static inline var BOUNCE_SHOT_SPEED = 75;

    private var sprite:Spritemap;
    private var path:LinearPath;
    private var wave:NumTween;
    private var hasFiredBounceShot:Bool;

    public function new(
        startX:Float, startY:Float, pathPoints:Array<Vector2>
    ) {
        super(startX, startY);
        name = "ukyo";
        mask = new Hitbox(75, 75);
        startingHealth = 666;
        health = startingHealth;
        sprite = new Spritemap("graphics/ukyo.png", 75, 75);
        sprite.add("idle", [0]);
        graphic = sprite;

        path = new LinearPath(TweenType.Looping);
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        addTween(path, true);
        
        wave = new NumTween(TweenType.PingPong);
        wave.tween(0, 50, 1, Ease.sineInOut);
        addTween(wave, true);
        hasFiredBounceShot = false;
    }

    private function bounceShot() {
        var spreadAngles = getSpreadAngles(
            BOUNCE_BULLETS_PER_SHOT, Math.PI * 2
        );
        var offset = Math.random() * Math.PI * 2;
        for(i in 0...BOUNCE_BULLETS_PER_SHOT) {
            var shotAngle = spreadAngles[i] + Math.PI / 2  + offset;
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

    override public function update() {
        if(!hasFiredBounceShot) {
            bounceShot();
            hasFiredBounceShot = true;
        }
        x = path.x;
        y = startPosition.y + wave.value;
        super.update();
    }
}
