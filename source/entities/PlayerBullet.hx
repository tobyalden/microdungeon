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
    private var sfx:Map<String, Sfx>;

    public function new(x:Float, y:Float, heading:Vector2) {
        super(x, y);
        layer = 1;
        mask = new Hitbox(2, 2);
        sprite = new Spritemap("graphics/playerbullet.png", 2, 2);
        sprite.add("idle", [0]);
        graphic = sprite;
        velocity = heading;
        velocity.normalize(SPEED);
        sfx = [
            "bullethit1" => new Sfx("audio/bullethit1.ogg"),
            "bullethit2" => new Sfx("audio/bullethit2.ogg"),
            "bullethit3" => new Sfx("audio/bullethit3.ogg")
        ];
    }

    override public function update() {
        super.update();
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls", "boss"]
        );
    }

    override public function moveCollideX(e:Entity) {
        if(e.type == "boss") {
            cast(e, Boss).takeHit();
            var sfxName = 'bullethit${HXP.choose(1, 2, 3)}';
            if(!sfx[sfxName].playing) {
                sfx[sfxName].play(0.15);
            }
        }
        scene.remove(this);
        return true;
    }

    override public function moveCollideY(e:Entity) {
        if(e.type == "boss") {
            cast(e, Boss).takeHit();
            var sfxName = 'bullethit${HXP.choose(1, 2, 3)}';
            if(!sfx[sfxName].playing) {
                sfx[sfxName].play(0.15);
            }
        }
        scene.remove(this);
        return true;
    }
}
