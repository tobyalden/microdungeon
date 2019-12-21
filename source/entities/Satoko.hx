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

class Satoko extends Boss
{
    public static inline var SPEED = 50;

    public static inline var RIPPLE_SHOT_SPEED = 60;
    public static inline var RIPPLE_SHOT_INTERVAL = 2.5;
    public static inline var RIPPLE_BULLETS_PER_SHOT = 8;

    private var sprite:Spritemap;
    private var path:LinearPath;
    private var rippleShotInterval:Alarm;

    public function new(startX:Float, startY:Float, pathPoints:Array<Vector2>) {
        super(startX, startY);
        name = "satoko";
        mask = new Hitbox(48, 48);
        sprite = new Spritemap("graphics/satoko.png", 48, 48);
        startingHealth = 666;
        health = startingHealth;
        sprite.add("idle", [0]);
        sprite.add("enrage", [1]);
        graphic = sprite;

        path = new LinearPath(TweenType.Looping);
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        addTween(path, true);
        
        rippleShotInterval = new Alarm(
            RIPPLE_SHOT_INTERVAL, TweenType.Looping
        );
        rippleShotInterval.onComplete.bind(function() {
            rippleShot();
        });
        var startDelay = new Alarm(RIPPLE_SHOT_INTERVAL / 2);
        startDelay.onComplete.bind(function() {
            rippleShot();
            addTween(rippleShotInterval, true);
        });
        addTween(startDelay, true);
    }

    override public function die() {
        if(scene.getInstance("rika") != null) {
            cast(scene.getInstance("rika"), Rika).enrage();
        }
        super.die();
    }

    public function enrage() {
        rippleShotInterval.multiplySpeed(2);
        path.multiplySpeed(2);
        sprite.play("enrage");
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
                centerX, centerY, shotVector, RIPPLE_SHOT_SPEED, 0x00FDFF, 12
            ));
        }
    }

    override public function update() {
        x = path.x;
        y = path.y;
        super.update();
    }
}
