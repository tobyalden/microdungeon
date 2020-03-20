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

class FinalRena extends Boss
{
    public static inline var SPEED = 50;

    public static inline var SPOUT_SHOT_SPEED = 100;
    public static inline var SPOUT_SHOT_SPREAD = 3.1415 / 5;
    public static inline var SPOUT_SHOT_INTERVAL = 2.5;

    public static inline var RIPPLE_SHOT_SPEED = 60;
    public static inline var RIPPLE_SHOT_INTERVAL = 7;
    public static inline var RIPPLE_BULLETS_PER_SHOT = 8;

    public static inline var ARC_SHOT_SPEED = 150;
    public static inline var ARC_SHOT_INTERVAL = 0.6;

    public static inline var BOUNCE_BULLETS_PER_SHOT = 8;
    public static inline var BOUNCE_SHOT_SPEED = 25;

    private var sprite:Spritemap;
    private var path:LinearPath;
    private var wave:NumTween;
    private var secondWave:NumTween;
    private var spoutShotInterval:Alarm;
    private var rippleShotInterval:Alarm;
    private var arcShotInterval:Alarm;
    private var phase:Int;
    private var hasFiredBounceShot:Bool;

    public function new(startX:Float, startY:Float, pathPoints:Array<Vector2>) {
        super(startX, startY);
        name = "finalrena";
        mask = new Hitbox(75, 75);
        startingHealth = 666;
        health = startingHealth;
        sprite = new Spritemap("graphics/finalrena.png", 75, 75);
        sprite.add("1", [0]);
        sprite.add("2", [1]);
        graphic = sprite;

        path = new LinearPath(TweenType.Looping);
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        addTween(path, true);
        
        wave = new NumTween(TweenType.PingPong);
        wave.tween(-15, 5, 1, Ease.sineInOut);
        addTween(wave, true);

        secondWave = new NumTween(TweenType.PingPong);
        secondWave.tween(0, -25, 1, Ease.sineInOut);
        addTween(secondWave);

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

        arcShotInterval = new Alarm(
            ARC_SHOT_INTERVAL, TweenType.Looping
        );
        arcShotInterval.onComplete.bind(function() {
            arcShot();
        });
        addTween(arcShotInterval);

        phase = 1;
        hasFiredBounceShot = false;
        sfx["secondphase"] = new Sfx("audio/secondphase.ogg");
    }

    override public function die() {
        if(phase == 1) {
            spoutShotInterval.active = false;
            rippleShotInterval.active = false;
            arcShotInterval.start();
            secondWave.start();
            phase = 2;
            health = 666;
            startingHealth = 666;
            sfx["klaxon"].stop();
            sfx["music"].stop();
            sfx["secondphase"].play();
            sfx["music"] = new Sfx('audio/${name}_music2.ogg');
        }
        else {
            var bounceBullets = new Array<Entity>();
            scene.getType("hazard", bounceBullets);
            for(bounceBullet in bounceBullets) {
                if(Type.getClass(bounceBullet) == Bullet) {
                    scene.remove(bounceBullet);
                }
            }
            super.die();
        }
    }

    private function arcShot() {
        var shotAngle = getAngleTowardsPlayer();
        var shotVector = new Vector2(
            Math.cos(shotAngle) / 3,
            -Math.abs(Math.sin(shotAngle) - Math.max(Math.random(), 0.2) * 2.5)
        );
        scene.add(new Bullet(
            centerX, centerY, shotVector,
            ARC_SHOT_SPEED,
            0xFF2600, HXP.choose(10, 12, 14), false, true
        ));
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

    private function bounceShot() {
        var spreadAngles = getSpreadAngles(
            BOUNCE_BULLETS_PER_SHOT, Math.PI * 2
        );
        for(i in 0...BOUNCE_BULLETS_PER_SHOT) {
            var shotAngle = spreadAngles[i] * 2 + Math.PI + 1100;
            var shotVector = new Vector2(
                Math.cos(shotAngle), Math.sin(shotAngle)
            );
            scene.add(new Bullet(
                centerX, centerY, shotVector,
                BOUNCE_SHOT_SPEED, 0xFFFF00, 12, true
            ));
        }
    }

    override public function update() {
        sprite.play('${phase}');
        if(!hasFiredBounceShot && phase == 2) {
            hasFiredBounceShot = true;
            bounceShot();
        }
        x = path.x;
        if(phase == 2) {
            y = startPosition.y + wave.value + secondWave.value;
        }
        else {
            y = startPosition.y + wave.value;
        }
        super.update();
    }
}

