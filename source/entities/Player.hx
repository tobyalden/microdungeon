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

    public static inline var HOVERBOARD_ACCEL = 600;
    public static inline var MAX_HOVERBOARD_SPEED = 200;
    public static inline var HOVERBOARD_JUMP_POWER = 300;
    public static inline var HOVERBOARD_JUMP_CANCEL_POWER = 40;
    public static inline var HOVERBOARD_HOVER_POWER = GRAVITY * 2;
    public static inline var HOVERBOARD_HEIGHT = 7;

    public var activeElevator(default, null):Elevator;
    public var isDead(default, null):Bool;
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var shotTimer:Alarm;
    private var wasOnGround:Bool;
    private var isOnHoverboard:Bool;
    private var isGoingThroughDoor:Bool;
    private var inventory:Array<String>;
    private var sfx:Map<String, Sfx>;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        sprite = new Spritemap("graphics/player.png", 26, 26);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("crouch", [5]);
        sprite.add("hoverboard", [6]);
        sprite.play("idle");
        graphic = sprite;
        mask = new Hitbox(12, 24);
        sprite.x = -7;
        sprite.y = -2;
        velocity = new Vector2();
        shotTimer = new Alarm(PEASHOOTER_SHOT_INTERVAL, TweenType.Looping);
        shotTimer.onComplete.bind(function() {
            firePeashooter();
        });
        addTween(shotTimer);
        isDead = false;
        wasOnGround = false;
        isOnHoverboard = false;
        isGoingThroughDoor = false;
        //inventory = ["hanginggloves"];
        inventory = [];
        sfx = [
            "jump" => new Sfx("audio/jump.wav"),
            "land" => new Sfx("audio/land.wav"),
            "shoot" => new Sfx("audio/shoot.wav"),
            "death" => new Sfx("audio/death.wav"),
            "hoverboard" => new Sfx("audio/hoverboard.wav"),
            "getonhoverboard" => new Sfx("audio/getonhoverboard.wav"),
            "getoffhoverboard" => new Sfx("audio/getoffhoverboard.wav")
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
                if(isOnHoverboard) {
                    hoverboardMovement();
                }
                else {
                    movement();
                }
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
            Input.pressed("interact")
            && elevator != null
            && !cast(elevator, Elevator).isUsed
        ) {
            activeElevator = cast(elevator, Elevator);
            activeElevator.activate();
            sprite.flipX = false;
            sprite.play("idle");
        }
        var bossTrigger = collide("bosstrigger", x, y);
        if(
            bossTrigger != null
            && activeElevator == null
        ) {
            var boss = scene.getInstance(
                cast(bossTrigger, BossTrigger).bossName
            );
            if(boss != null) {
                boss.active = true;
                GameScene.checkpoint = new Vector2(
                    bossTrigger.centerX - width / 2,
                    bossTrigger.bottom - height
                );
                bossTrigger.collidable = false;
            }
        }
        var _savePoint = collide("savepoint", x, y + 1);
        if(Input.pressed("interact") && _savePoint != null) {
            var savePoint = cast(_savePoint, SavePoint);
            savePoint.flash();
            cast(scene, GameScene).saveGame(savePoint);
        }
        var _door = collide("door", x, y + 1);
        if(Input.pressed("interact") && _door != null) {
            var door = cast(_door, Door);
            active = false;
            isGoingThroughDoor = true;
            cast(scene, GameScene).useDoor(door);
        }
        var hoverboard = collide("hoverboard", x, y);
        if(hoverboard != null) {
            scene.remove(hoverboard);
            isOnHoverboard = true;
            sfx["getonhoverboard"].play();
        }
        var noHoverboardSign = collide("nohoverboardsign", x, y);
        if(noHoverboardSign != null) {
            if(isOnHoverboard) {
                sfx["getoffhoverboard"].play();
                isOnHoverboard = false;
            }
        }
    }

    public function getOffElevator() {
        moveTo(
            activeElevator.centerX - width / 2,
            activeElevator.y - height
        );
        activeElevator.sfx["elevator"].stop();
        activeElevator = null;
    }

    private function die() {
        if(isGoingThroughDoor) {
            return;
        }
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

    private function hoverboardMovement() {
        if(Input.check("left") && !isOnLeftWall()) {
            velocity.x -= HOVERBOARD_ACCEL * HXP.elapsed;
        }
        else if(Input.check("right") && !isOnRightWall()) {
            velocity.x += HOVERBOARD_ACCEL * HXP.elapsed;
        }
        else {
            velocity.x = MathUtil.approach(
                velocity.x, 0, HOVERBOARD_ACCEL * HXP.elapsed
            );
        }
        velocity.x = MathUtil.clamp(
            velocity.x, -MAX_HOVERBOARD_SPEED, MAX_HOVERBOARD_SPEED
        );

        velocity.y += GRAVITY * HXP.elapsed;
        velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);

        var distanceFromGround = -1;
        for(i in 0...HXP.height) {
            if(collide("walls", x, y + i) != null) {
                distanceFromGround = i;
                break;
            }
        }
        sfx["hoverboard"].volume = MathUtil.clamp(
            (15 / distanceFromGround) / 15, 0, 1
        );

        if(collide("walls", x, y + HOVERBOARD_HEIGHT) != null) {
            velocity.y -= HOVERBOARD_HOVER_POWER * HXP.elapsed;
        }
        if(collide("walls", x, y + HOVERBOARD_HEIGHT * 3) != null) {
            if(Input.pressed("jump")) {
                var jumpPower:Float = HOVERBOARD_JUMP_POWER;
                if(distanceFromGround <= 3) {
                    distanceFromGround = 1;
                }
                var jumpModifier = MathUtil.lerp(
                    0.75, 1,
                    MathUtil.clamp((15 / distanceFromGround) / 15, 0, 1)
                );
                velocity.y = -jumpPower * jumpModifier;
                sfx["jump"].play();
                trace(distanceFromGround);
            }
        }

        moveBy(
            velocity.x * HXP.elapsed,
            velocity.y * HXP.elapsed,
            ["walls", "elevator"]
        );
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
        if(isGoingThroughDoor) {
            sprite.play("idle");
            return;
        }
        if(isOnHoverboard) {
            sprite.play("hoverboard");
            if(velocity.x != 0) {
                sprite.flipX = velocity.x < 0;
            }
            if(!sfx["hoverboard"].playing) {
                sfx["hoverboard"].loop();
            }
            return;
        }
        else {
            sfx["hoverboard"].stop();
        }

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
