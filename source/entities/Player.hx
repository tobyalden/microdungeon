package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

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
    public static inline var GLIDE_FACTOR = 1;
    public static inline var PEASHOOTER_SHOT_INTERVAL = 1 / 60;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var shotTimer:Alarm;
    private var isDead:Bool;
    private var wasOnGround:Bool;
    private var inventory:Array<String>;
    private var sfx:Map<String, Sfx>;
    private var activeElevator:Elevator;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
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
        mask = new Hitbox(12, 24);
        sprite.x = -2;
        velocity = new Vector2();
        shotTimer = new Alarm(PEASHOOTER_SHOT_INTERVAL, TweenType.Looping);
        shotTimer.onComplete.bind(function() {
            firePeashooter();
        });
        addTween(shotTimer);
        isDead = false;
        wasOnGround = false;
        //inventory = ["hanginggloves"];
        inventory = [];
        sfx = [
            "jump" => new Sfx("audio/jump.wav"),
            "land" => new Sfx("audio/land.wav"),
            "shoot" => new Sfx("audio/shoot.wav"),
            "death" => new Sfx("audio/death.wav")
        ];
        activeElevator = null;
    }

    private function firePeashooter() {
        var heading = new Vector2();
        heading.x = sprite.flipX ? -1 : 1;
        var bullet = new PlayerBullet(centerX, y + 11, heading);
        scene.add(bullet);
    }

    override public function update() {
        collisions();
        if(!isDead) {
            if(activeElevator != null) {
                moveTo(
                    activeElevator.centerX - width / 2,
                    activeElevator.y - height
                );
            }
            else {
                shooting();
                movement();
                animation();
            }
        }
        super.update();
    }

    private function collisions() {
        for(hazardType in ["hazard", "boss"]) {
            if(collide(hazardType, x, y) != null) {
                die();
            }
        }
        var elevator = collide("elevator", x, y + 1);
        if(
            Input.pressed("up")
            && elevator != null
            && !cast(elevator, Elevator).isUsed
        ) {
            activeElevator = cast(elevator, Elevator);
            activeElevator.activate();
            sprite.flipX = false;
            sprite.play("idle");
        }
    }

    public function getOffElevator() {
        moveTo(
            activeElevator.centerX - width / 2,
            activeElevator.y - height
        );
        activeElevator = null;
    }

    private function die() {
        isDead = true;
        visible = false;
        collidable = false;
        explode();
        sfx["death"].play();
        sfx["shoot"].stop();
        shotTimer.cancel();
        cast(scene, GameScene).onDeath();
    }

    private function shooting() {
        if(Input.pressed("shoot")) {
            firePeashooter();
            shotTimer.start();
            sfx["shoot"].loop();
        }
        if(Input.released("shoot")) {
            shotTimer.active = false;
            sfx["shoot"].stop();
        }
    }

    private function movement() {
        if(
            inventory.indexOf("hanginggloves") != -1
            && isOnCeiling()
            && Input.check("up")
        ) {
            velocity.y = 0;
            return;
        }
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
                sfx["jump"].play();
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

        wasOnGround = isOnGround();
        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls", "elevator"]
        );
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
        if(!wasOnGround && isOnGround()) {
            sfx["land"].play();
        }
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
