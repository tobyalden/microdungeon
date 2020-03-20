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

class Bullet extends MiniEntity
{
    public static inline var ARC_SHOT_FALL_VELOCITY = 200;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isBounceShot:Bool;
    private var isArcShot:Bool;
    private var age:Float;
    private var isReflected:Bool;
    private var size:Int;
    private var sfx:Map<String, Sfx>;

    public function setIsBounceShot(newIsBounceShot:Bool) {
        isBounceShot = newIsBounceShot;
    }

    public function new(
        x:Float, y:Float, heading:Vector2, speed:Float, bulletColor:Int,
        size:Int, isBounceShot:Bool = false, isArcShot:Bool = false
    ) {
        super(x, y);
        this.isBounceShot = isBounceShot;
        this.isArcShot = isArcShot;
        this.size = size;
        type = "hazard";
        var hitbox = new Circle(
            Std.int(size / 2), Std.int(-size / 2), Std.int(-size / 2)
        );
        mask = hitbox;
        layer = -1;
        sprite = new Spritemap("graphics/bullet.png", 20, 20);
        sprite.scale = size / 20;
        sprite.centerOrigin();
        sprite.add("idle", [0]);
        sprite.color = bulletColor;
        graphic = sprite;
        velocity = heading;
        velocity.normalize(speed);
        age = 0;
        isReflected = false;
        sfx = [
            "bullethit1" => new Sfx("audio/bullethit1.ogg"),
            "bullethit2" => new Sfx("audio/bullethit2.ogg"),
            "bullethit3" => new Sfx("audio/bullethit3.ogg")
        ];
    }

    override public function update() {
        age += HXP.elapsed;
        if(isOffScreen()) {
            scene.remove(this);
        }
        if(isArcShot) {
           velocity.y += ARC_SHOT_FALL_VELOCITY * HXP.elapsed;  
        }
        if(isReflected) {
            moveBy(
                velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["boss"]
            );
        }
        else if(isBounceShot) {
            moveBy(
                velocity.x * HXP.elapsed, velocity.y * HXP.elapsed,
                ["walls", "shield"]
            );
        }
        else {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, ["shield"]);
        }
        super.update();
    }

    override public function moveCollideX(e:Entity) {
        if(e.type == "boss") {
            cast(e, Boss).takeHit(size * 2);
            var sfxName = 'bullethit${HXP.choose(1, 2, 3)}';
            if(!sfx[sfxName].playing) {
                sfx[sfxName].play(1);
            }
            scene.remove(this);
        }
        else if(e.type == "walls") {
            velocity.x = -velocity.x;
        }
        else {
            setXVelocityAwayFromPlayer();
        }
        return true;
    }

    override public function moveCollideY(e:Entity) {
        if(e.type == "boss") {
            cast(e, Boss).takeHit(size * 2);
            var sfxName = 'bullethit${HXP.choose(1, 2, 3)}';
            if(!sfx[sfxName].playing) {
                sfx[sfxName].play(1);
            }
            scene.remove(this);
        }
        else if(e.type == "walls") {
            velocity.y = -velocity.y;
        }
        else {
            setYVelocityAwayFromPlayer();
        }
        return true;
    }

    public function setXVelocityAwayFromPlayer() {
        var player = scene.getInstance("player");
        velocity.x = player.centerX < centerX ? Math.abs(velocity.x) : -Math.abs(velocity.x);
        if(!isBounceShot) {
            isReflected = true;
            sprite.color = 0xF4FFFD;
        }
    }

    public function setYVelocityAwayFromPlayer() {
        var player = scene.getInstance("player");
        velocity.x = player.centerY < centerY ? Math.abs(velocity.x) : -Math.abs(velocity.x);
        if(!isBounceShot) {
            isReflected = true;
            sprite.color = 0xF4FFFD;
        }
    }
}
