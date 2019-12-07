package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;

class Particle extends MiniEntity
{
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var goSlowly:Bool;

    public function new(
        x:Float, y:Float, velocity:Vector2, goQuickly:Bool = false,
        goSlowly:Bool = false
    ) {
	    super(x, y);
        this.velocity = velocity;
        this.goSlowly = goSlowly;
        sprite = new Spritemap("graphics/particle.png", 24, 24);
        if(goQuickly) {
            sprite.add(
                "idle", [0, 1, 2, 3], Std.int(Math.random() * 4 + 4), false
            );
        }
        else if(goSlowly) {
            sprite.add(
                "idle", [0, 1, 2, 3], Std.int(Math.random() * 2 + 1), false
            );
        }
        else {
            sprite.add(
                "idle", [0, 1, 2, 3], Std.int(Math.random() * 4 + 2), false
            );
        }
        sprite.play("idle");
        sprite.originX = 12;
        sprite.originY = 12;
        graphic = sprite;
    }

    public override function update() {
        var delta = HXP.elapsed * 60;
        moveBy(
            velocity.x * delta * 17,
            velocity.y * delta * 17
        );
        velocity.scale(0.97);
        graphic.alpha -= (
            (1 - (Math.abs(velocity.x) + Math.abs(velocity.y)))
            * delta * 0.003
        );
        if(sprite.complete && !goSlowly) {
            scene.remove(this);
        }
    }
}


