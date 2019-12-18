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

class Mion extends MiniEntity
{
    public static inline var MAX_HEALTH = 1000;
    public static inline var SPEED = 50;

    public static inline var SPOUT_SHOT_SPEED = 100;
    public static inline var SPOUT_SHOT_SPREAD = 3.1415 / 5;
    public static inline var SPOUT_SHOT_INTERVAL = 2.5;

    public static inline var RIPPLE_SHOT_SPEED = 60;
    public static inline var RIPPLE_SHOT_INTERVAL = 7;
    public static inline var RIPPLE_BULLETS_PER_SHOT = 8;

    public var health(default, null):Int;
    private var sprite:Spritemap;
    private var path:LinearPath;
    private var wave:NumTween;
    private var spoutShotInterval:Alarm;
    private var rippleShotInterval:Alarm;
    private var startY:Float;

    public function new(startX:Float, startY:Float, pathPoints:Array<Vector2>) {
        super(startX, startY);
        this.startY = startY;
        name = "mion";
        type = "mion";
        mask = new Hitbox(75, 75);
        health = MAX_HEALTH;
        sprite = new Spritemap("graphics/mion.png", 75, 75);
        sprite.add("idle", [0]);
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

    public function takeHit() {
        health -= 1;
        if(health <= 0) {
            scene.remove(this);
        }
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
        y = startY + wave.value;
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

    public function getAngleTowardsPlayer() {
        var player = scene.getInstance("player");
        return (
            Math.atan2(
                player.centerY - centerY,
                player.centerX - centerX
            )
        );
    }
}

