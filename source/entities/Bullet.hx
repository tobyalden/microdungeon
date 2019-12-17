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

    public function new(
        x:Float, y:Float, heading:Vector2, speed:Float, bulletColor:Int, size:Int
    ) {
        super(x, y);
        type = "hazard";
        var hitbox = new Hitbox(size, size);
        x -= hitbox.width;
        y -= hitbox.height;
        mask = hitbox;
        layer = -1;
        sprite = new Spritemap("graphics/bullet.png", 20, 20);
        sprite.scale = size / 20;
        sprite.add("idle", [0]);
        sprite.color = bulletColor;
        graphic = sprite;
        velocity = heading;
        velocity.normalize(speed);
    }

    override public function update() {
        if(isOffScreen()) {
            scene.remove(this);
        }
        super.update();
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
    }

    override public function moveCollideX(_:Entity) {
        return true;
    }

    override public function moveCollideY(_:Entity) {
        return true;
    }
}
