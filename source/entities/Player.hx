package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class Player extends MiniEntity
{
    public static inline var RUN_ACCEL = 400;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var AIR_ACCEL = 360;
    public static inline var AIR_DECEL = 360;
    public static inline var MAX_RUN_SPEED = 100;
    public static inline var MAX_AIR_SPEED = 120;
    public static inline var GRAVITY = 500;
    public static inline var GRAVITY_ON_WALL = 150;
    public static inline var JUMP_POWER = 160;
    public static inline var JUMP_CANCEL_POWER = 40;
    public static inline var WALL_JUMP_POWER_X = 130;
    public static inline var WALL_JUMP_POWER_Y = 120;
    public static inline var WALL_STICKINESS = 60;
    public static inline var MAX_FALL_SPEED = 270;
    public static inline var MAX_FALL_SPEED_ON_WALL = 200;
    public static inline var DOUBLE_JUMP_POWER_X = 0;
    public static inline var DOUBLE_JUMP_POWER_Y = 130;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var canDoubleJump:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("up", [Key.UP]);
        Key.define("down", [Key.DOWN]);
        Key.define("jump", [Key.Z]);
        Key.define("attack", [Key.X]);
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
        canDoubleJump = false;
    }

    override public function update() {
        combat();
        movement();
        animation();
        super.update();
    }

    private function combat() {
        if(Input.pressed("attack")) {
            var boomerangHeading = new Vector2(sprite.flipX ? -1 : 1, 0);
            if(Input.check("up")) {
                boomerangHeading.y = -1;
            }
            else if(Input.check("down")) {
                boomerangHeading.y = 1;
            }
            var boomerang = new Boomerang(this, boomerangHeading);
            scene.add(boomerang);
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
        else if(!isOnWall()) {
            velocity.x = MathUtil.approach(
                velocity.x, 0, decel * HXP.elapsed
            );
        }
        var maxSpeed = isOnGround() ? MAX_RUN_SPEED : MAX_AIR_SPEED;
        velocity.x = MathUtil.clamp(velocity.x, -maxSpeed, maxSpeed);

        if(isOnGround()) {
            canDoubleJump = true;
            velocity.y = 0;
            if(Input.pressed("jump")) {
                velocity.y = -JUMP_POWER;
            }
        }
        else if(isOnWall()) {
            var gravity = velocity.y > 0 ? GRAVITY_ON_WALL : GRAVITY;
            velocity.y += gravity * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED_ON_WALL);
            if(Input.pressed("jump")) {
                velocity.y = -WALL_JUMP_POWER_Y;
                velocity.x = (
                    isOnLeftWall() ? WALL_JUMP_POWER_X : -WALL_JUMP_POWER_X
                );
            }
        }
        else {
            if(Input.pressed("jump") && canDoubleJump) {
                velocity.y = -DOUBLE_JUMP_POWER_Y;
                if(velocity.x > 0 && Input.check("left")) {
                    velocity.x = -DOUBLE_JUMP_POWER_X;
                }
                else if(velocity.x < 0 && Input.check("right")) {
                    velocity.x = DOUBLE_JUMP_POWER_X;
                }
                canDoubleJump = false;
            }
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

    override public function moveCollideY(_:Entity) {
        velocity.y = 0;
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
                if(Input.check("left")) {
                    sprite.flipX = true;
                }
                else if(Input.check("right")) {
                    sprite.flipX = false;
                }
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
