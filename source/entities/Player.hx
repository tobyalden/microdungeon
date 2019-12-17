package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class Player extends MiniEntity
{
    public static inline var RUN_ACCEL = 9999;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var AIR_ACCEL = RUN_ACCEL;
    public static inline var AIR_DECEL = RUN_ACCEL;
    public static inline var MAX_RUN_SPEED = 100;
    public static inline var MAX_AIR_SPEED = MAX_RUN_SPEED;
    public static inline var GRAVITY = 600;
    public static inline var JUMP_POWER = 300;
    public static inline var JUMP_CANCEL_POWER = 20;
    public static inline var MAX_FALL_SPEED = 270;
    public static inline var GLIDE_FACTOR = 7;

    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("jump", [Key.Z]);
        Key.define("shoot", [Key.X]);
        sprite = new Spritemap("graphics/player.png", 16, 24);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("fall", [5]);
        sprite.add("crouch", [6]);
        sprite.add("throw", [7, 8], 2);
        sprite.add("throw_jump", [9, 10], 2);
        sprite.add("throw_fall", [11, 12], 2);
        sprite.play("idle");
        graphic = sprite;
        //mask = new Hitbox(12, 24, -4);
        mask = new Hitbox(16, 24);
        velocity = new Vector2();
    }

    override public function update() {
        shooting();
        movement();
        animation();
        super.update();
    }

    private function shooting() {
        if(Input.check("shoot")) {
            var heading = new Vector2();
            heading.x = sprite.flipX ? -1 : 1;
            var bullet = new PlayerBullet(centerX, y + 11, heading);
            scene.add(bullet);
        }
    }

    private function movement() {
        var accel = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        if(
            isOnGround() && (
                Input.check("left") && velocity.x > 0
                || Input.check("right") && velocity.x < 0
            )
        ) {
            accel *= RUN_ACCEL_TURN_MULTIPLIER;
        }
        var decel = isOnGround() ? RUN_DECEL : AIR_DECEL;
        if(Input.check("left") && !isOnLeftWall()) {
            velocity.x -= accel * HXP.elapsed;
        }
        else if(Input.check("right") && !isOnRightWall()) {
            velocity.x += accel * HXP.elapsed;
        }
        else {
            velocity.x = MathUtil.approach(
                velocity.x, 0, decel * HXP.elapsed
            );
        }
        var maxSpeed = isOnGround() ? MAX_RUN_SPEED : MAX_AIR_SPEED;
        velocity.x = MathUtil.clamp(velocity.x, -maxSpeed, maxSpeed);

        if(isOnGround()) {
            velocity.y = 0;
            if(Input.pressed("jump")) {
                velocity.y = -JUMP_POWER;
            }
        }
        else {
            if(Input.released("jump")) {
                velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
            }
            if(Input.check("shoot")) {
                velocity.y += GRAVITY * HXP.elapsed;
                velocity.y = Math.min(velocity.y, MAX_FALL_SPEED / GLIDE_FACTOR);
            }
            else {
                velocity.y += GRAVITY * HXP.elapsed;
                velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
            }
        }

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    override public function moveCollideX(_:Entity) {
        if(isOnGround()) {
            velocity.x = 0;
        }
        return true;
    }

    override public function moveCollideY(_:Entity) {
        if(isOnCeiling()) {
            velocity.y = -velocity.y;
        }
        velocity.y = 0;
        return true;
    }

    private function animation() {
        if(velocity.x != 0 && !Input.check("shoot")) {
        //if(velocity.x != 0) {
            sprite.flipX = velocity.x < 0;
        }
        if(!isOnGround()) {
            sprite.play("jump");
        }
        else if(velocity.x != 0) {
            sprite.play("run");
        }
        else {
            sprite.play("idle");
        }
    }
}
