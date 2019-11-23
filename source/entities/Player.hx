package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class Player extends MiniEntity
{
    public static inline var RUN_ACCEL = 100;
    public static inline var RUN_DECEL = 100;
    public static inline var MAX_RUN_SPEED = 100;
    public static inline var GRAVITY = 200;
    public static inline var GRAVITY_ON_WALL = 100;
    public static inline var JUMP_POWER = 100;
    public static inline var JUMP_CANCEL_POWER = 25;
    public static inline var WALL_JUMP_POWER_X = 100;
    public static inline var WALL_JUMP_POWER_Y = 100;
    public static inline var WALL_STICKINESS = 30;
    public static inline var MAX_FALL_SPEED = 100;
    public static inline var MAX_FALL_SPEED_ON_WALL = 50;

    private var sprite:Spritemap;
    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("jump", [Key.Z]);
        sprite = new Spritemap("graphics/player.png", 8, 12);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("wall", [5]);
        sprite.add("skid", [6]);
        sprite.play("idle");
        graphic = sprite;
        mask = new Hitbox(6, 12, -1, 0);
        velocity = new Vector2();
    }

    override public function update() {
        movement();
        animation();
        super.update();
    }

    private function movement() {
        if(Input.check("left") && !isOnLeftWall()) {
            velocity.x -= RUN_ACCEL * HXP.elapsed;
        }
        else if(Input.check("right") && !isOnRightWall()) {
            velocity.x += RUN_ACCEL * HXP.elapsed;
        }
        else if(!isOnWall()) {
            velocity.x = MathUtil.approach(
                velocity.x, 0, RUN_DECEL * HXP.elapsed
            );
        }
        velocity.x = MathUtil.clamp(velocity.x, -MAX_RUN_SPEED, MAX_RUN_SPEED);

        if(isOnGround()) {
            velocity.y = 0;
            if(Input.pressed("jump")) {
                velocity.y = -JUMP_POWER;
            }
        }
        else if(isOnWall()) {
            velocity.y += GRAVITY_ON_WALL * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED_ON_WALL);
            if(Input.pressed("jump")) {
                velocity.y = -WALL_JUMP_POWER_Y;
                velocity.x = (
                    isOnLeftWall() ? WALL_JUMP_POWER_X : -WALL_JUMP_POWER_X
                );
            }
        }
        else {
            if(Input.released("jump")) {
                velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
            }
            velocity.y += GRAVITY * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        }

        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
    }

    override public function moveCollideX(_:Entity) {
        if(isOnGround()) {
            velocity.x = 0;
        }
        else if(isOnLeftWall()) {
            velocity.x = Math.max(velocity.x, -WALL_STICKINESS);
        }
        else if(isOnRightWall()) {
            velocity.x = Math.min(velocity.x, WALL_STICKINESS);
        }
        return true;
    }

    private function animation() {
        if(!isOnGround()) {
            if(isOnWall()) {
                sprite.play("wall");
                sprite.flipX = isOnLeftWall();
            }
            else {
                sprite.play("jump");
                sprite.flipX = velocity.x < 0;
            }
        }
        else if(velocity.x != 0) {
            if(
                velocity.x > 0 && Input.check("left")
                || velocity.x < 0 && Input.check("right")
            ) {
                sprite.play("skid");
            }
            else {
                sprite.play("run");
            }
            sprite.flipX = velocity.x < 0;
        }
        else {
            sprite.play("idle");
        }
    }
}
