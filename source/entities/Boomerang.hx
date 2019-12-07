package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class Boomerang extends MiniEntity
{
    public static inline var MAX_SPEED = 200;
    public static inline var RETURN_RATE = 0.75;

    private var sprite:Spritemap;
    private var velocity:Vector2;

    private var initialVelocity:Vector2;
    private var age:Float;

    public function new(source:Entity, heading:Vector2) {
        super(source.centerX, source.centerY);
        mask = new Hitbox(8, 8);
        x -= width / 2;
        y -= height / 2;
        velocity = heading;
        velocity.normalize(MAX_SPEED);
        initialVelocity = velocity.clone();
        age = 0;
        sprite = new Spritemap("graphics/boomerang.png", 8, 8);
        graphic = sprite;
    }

    override public function update() {
        var player = scene.getInstance("player");
        var towardsPlayer = new Vector2(
            player.centerX - centerX, player.centerY - centerY
        );
        var distanceFromPlayer = towardsPlayer.length;
        towardsPlayer.normalize(MAX_SPEED);
        velocity.x = MathUtil.lerp(
            initialVelocity.x,
            towardsPlayer.x,
            Math.min(age * RETURN_RATE, 1)
        );
        velocity.y = MathUtil.lerp(
            initialVelocity.y,
            towardsPlayer.y,
            Math.min(age * RETURN_RATE, 1)
        );
        towardsPlayer.scale(HXP.elapsed);
        if(age > 0.1 && towardsPlayer.length > distanceFromPlayer) {
            scene.remove(this);
        }
        else {
            moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed);
        }
        super.update();
        age += HXP.elapsed;
    }
}
