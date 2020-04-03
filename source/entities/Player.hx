package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class Player extends MiniEntity
{
    public static inline var RUN_SPEED = 80 * 1.25;
    public static inline var AIR_SPEED = 80 * 1.25;
    public static inline var GRAVITY = 600;
    public static inline var JUMP_POWER = 175 * 1.5;
    public static inline var JUMP_CANCEL_POWER = 80;
    public static inline var MAX_FALL_SPEED = 270;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var isRunningJump:Bool;
    private var slowedJump:Bool;

    public function new(x:Float, y:Float) {
        super(x, y);
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("jump", [Key.Z]);
        sprite = new Spritemap("graphics/player.png", 100, 100);
        sprite.add("idle", [0]);
        sprite.add("run", [15, 16, 17, 18, 19], 8);
        sprite.add("jump", [5, 6], 3, false);
        sprite.play("idle");
        graphic = sprite;
        sprite.x = -44;
        //sprite.x = -34;
        //sprite.x = -29;
        sprite.y = -51;
        isRunningJump = false;
        slowedJump = false;
        mask = new Hitbox(7, 49);
        velocity = new Vector2();
    }

    override public function update() {
        movement();
        animation();
        super.update();
    }

    private function movement() {
        if(isOnGround()) {
            if(Input.check("left")) {
                velocity.x = -RUN_SPEED;
            }
            else if(Input.check("right")) {
                velocity.x = RUN_SPEED;
            }
            else {
                velocity.x = 0;
            }
        }
        else {
            if(isRunningJump) {
                if(velocity.x > 0) {
                    if(Input.check("left")) {
                        velocity.x = AIR_SPEED / 2;
                        slowedJump = true;
                    }
                    else if(!slowedJump) {
                        velocity.x = AIR_SPEED;
                    }
                }
                else if(velocity.x < 0) {
                    if(Input.check("right")) {
                        velocity.x = -AIR_SPEED / 2;
                        slowedJump = true;
                    }
                    else if(!slowedJump) {
                        velocity.x = -AIR_SPEED;
                    }
                }
            }
            else {
                if(Input.check("left") && !slowedJump) {
                    velocity.x = -AIR_SPEED / 3;
                    slowedJump = true;
                }
                else if(Input.check("right") && !slowedJump) {
                    velocity.x = AIR_SPEED / 3;
                    slowedJump = true;
                }
            }
        }

        if(isOnGround()) {
            slowedJump = false;
            velocity.y = 0;
            if(Input.pressed("jump")) {
                velocity.y = -JUMP_POWER;
                isRunningJump = velocity.x != 0;
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

    override public function moveCollideY(_:Entity) {
        velocity.y = 0;
        return true;
    }

    private function animation() {
        if(isOnGround()) {
            if(velocity.x < 0) {
                sprite.flipX = true;
            }
            else if(velocity.x > 0) {
                sprite.flipX = false;
            }
        }
        sprite.x = sprite.flipX ? -47 : -44;
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
