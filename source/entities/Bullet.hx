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
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isBounceShot:Bool;
    private var age:Float;

    public function setIsBounceShot(newIsBounceShot:Bool) {
        isBounceShot = newIsBounceShot;
    }

    public function new(
        x:Float, y:Float, heading:Vector2, speed:Float, bulletColor:Int,
        size:Int, isBounceShot:Bool = false
    ) {
        super(x, y);
        this.isBounceShot = isBounceShot;
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
    }

    override public function update() {
        age += HXP.elapsed;
        if(isOffScreen()) {
            scene.remove(this);
        }
        if(isBounceShot) {
            moveBy(
                velocity.x * HXP.elapsed, velocity.y * HXP.elapsed,
                ["walls"]
            );
        }
        else {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        }
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        velocity.x = -velocity.x;
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity.y = -velocity.y;
        return true;
    }
}
