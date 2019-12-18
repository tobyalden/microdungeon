package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class PlayerBullet extends MiniEntity
{
    public static inline var SPEED = 270;

    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        layer = 1;
        mask = new Hitbox(2, 2);
        sprite = new Spritemap("graphics/playerbullet.png", 2, 2);
        sprite.add("idle", [0]);
        graphic = sprite;
        velocity = heading;
        velocity.normalize(SPEED);
    }

    override public function update() {
        super.update();
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls", "rena", "mion"]
        );
    }

    override public function moveCollideX(e:Entity) {
        if(e.name == "rena") {
            cast(e, Rena).takeHit();
        }
        else if(e.name == "mion") {
            cast(e, Mion).takeHit();
        }
        scene.remove(this);
        return true;
    }

    override public function moveCollideY(e:Entity) {
        if(e.name == "rena") {
            cast(e, Rena).takeHit();
        }
        else if(e.name == "mion") {
            cast(e, Mion).takeHit();
        }
        scene.remove(this);
        return true;
    }
}
