package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import scenes.*;

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

    public var playerNumber(default, null):Int;
    public var isDead(default, null):Bool;
    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var canDoubleJump:Bool;
    private var wasOnGround:Bool;
    private var sfx:Map<String, Sfx>;

    public function new(x:Float, y:Float, playerNumber:Int) {
        super(x, y);
        this.playerNumber = playerNumber;
        name = 'player${playerNumber}';
        sprite = new Spritemap('graphics/player${playerNumber}.png', 8, 12);
        sprite.flipX = playerNumber == 2;
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
        wasOnGround = false;
        isDead = false;
        sfx = [
            "jump" => new Sfx("audio/jump.wav"),
            "doublejump" => new Sfx("audio/doublejump.wav"),
            "land" => new Sfx("audio/land.wav"),
            "run" => new Sfx("audio/run.wav"),
            "skid" => new Sfx("audio/skid.wav"),
            "toss" => new Sfx("audio/toss.wav"),
            "wallslide" => new Sfx("audio/wallslide.wav"),
            "death" => new Sfx("audio/death.wav")
        ];
    }

    public function stopAllSfx() {
        for(s in sfx) {
            s.stop();
        }
    }

    override public function update() {
        if(!isDead) {
            combat();
            movement();
            animation();
        }
        super.update();
    }

    private function die() {
        isDead = true;
        visible = false;
        collidable = false;
        explode();
        sfx["death"].play();
        cast(scene, GameScene).onDeath();
    }

    private function explode() {
        var numExplosions = 100;
        var directions = new Array<Vector2>();
        for(i in 0...numExplosions) {
            var angle = (2/numExplosions) * i;
            directions.push(new Vector2(Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), Math.sin(angle)));
            directions.push(new Vector2(Math.cos(angle), -Math.sin(angle)));
            directions.push(new Vector2(-Math.cos(angle), -Math.sin(angle)));
        }
        var count = 0;
        for(direction in directions) {
            direction.scale(0.8 * Math.random());
            direction.normalize(
                Math.max(0.1 + 0.2 * Math.random(), direction.length)
            );
            var explosion = new Particle(
                centerX, centerY, directions[count]
            );
            explosion.layer = -99;
            scene.add(explosion);
            count++;
        }

#if desktop
        Sys.sleep(0.02);
#end
        scene.camera.shake(2, 8);
    }

    private function combat() {
        var _enemyBoomerang = collide("boomerang", x, y);
        if(_enemyBoomerang != null) {
            var enemyBoomerang = cast(_enemyBoomerang, Boomerang);
            if(enemyBoomerang.player.playerNumber != playerNumber) {
                die();
            }
        }

        if(Main.inputPressed("act", playerNumber)) {
            var boomerangs = new Array<Entity>();
            scene.getType("boomerang", boomerangs);
            for(boomerang in boomerangs) {
                if(
                    cast(boomerang, Boomerang).player.playerNumber
                    == playerNumber
                ) {
                    return;
                }
            }
            var boomerangHeading = new Vector2(sprite.flipX ? -1 : 1, 0);
            if(
                !Main.inputCheck("left", playerNumber)
                && !Main.inputCheck("right", playerNumber)
                && (
                    Main.inputCheck("up", playerNumber)
                    || Main.inputCheck("down", playerNumber)
                )
            ) {
                boomerangHeading.x = 0;
            }
            if(Main.inputCheck("up", playerNumber)) {
                boomerangHeading.y = -1;
            }
            else if(Main.inputCheck("down", playerNumber)) {
                boomerangHeading.y = 1;
            }
            var boomerang = new Boomerang(this, boomerangHeading);
            scene.add(boomerang);
            sfx["toss"].play();
        }
    }

    private function movement() {
        var accel = isOnGround() ? RUN_ACCEL : AIR_ACCEL;
        if(
            isOnGround() && (
                Main.inputCheck("left", playerNumber) && velocity.x > 0
                || Main.inputCheck("right", playerNumber) && velocity.x < 0
            )
        ) {
            accel *= RUN_ACCEL_TURN_MULTIPLIER;
        }
        var decel = isOnGround() ? RUN_DECEL : AIR_DECEL;
        if(Main.inputCheck("left", playerNumber) && !isOnLeftWall()) {
            velocity.x -= accel * HXP.elapsed;
        }
        else if(Main.inputCheck("right", playerNumber) && !isOnRightWall()) {
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
            if(!wasOnGround) {
                sfx["land"].play();
            }
            canDoubleJump = true;
            velocity.y = 0;
            if(Main.inputPressed("jump", playerNumber)) {
                velocity.y = -JUMP_POWER;
                sfx["jump"].play();
            }
        }
        else if(isOnWall()) {
            var gravity = velocity.y > 0 ? GRAVITY_ON_WALL : GRAVITY;
            velocity.y += gravity * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED_ON_WALL);
            if(Main.inputPressed("jump", playerNumber)) {
                velocity.y = -WALL_JUMP_POWER_Y;
                velocity.x = (
                    isOnLeftWall() ? WALL_JUMP_POWER_X : -WALL_JUMP_POWER_X
                );
            }
        }
        else {
            if(Main.inputPressed("jump", playerNumber) && canDoubleJump) {
                velocity.y = -DOUBLE_JUMP_POWER_Y;
                sfx["doublejump"].play();
                if(
                    velocity.x > 0 && Main.inputCheck("left", playerNumber)
                ) {
                    velocity.x = -DOUBLE_JUMP_POWER_X;
                }
                else if(
                    velocity.x < 0 && Main.inputCheck("right", playerNumber)
                ) {
                    velocity.x = DOUBLE_JUMP_POWER_X;
                }
                canDoubleJump = false;
            }
            if(Main.inputReleased("jump", playerNumber)) {
                velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
            }
            velocity.y += GRAVITY * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        }

        wasOnGround = isOnGround();
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
        var playRunSfx = false;
        var playWallSlideSfx = false;
        if(!isOnGround()) {
            if(isOnWall()) {
                sprite.play("wall");
                playWallSlideSfx = true;
                sprite.flipX = isOnLeftWall();
            }
            else {
                sprite.play("jump");
                if(Main.inputCheck("left", playerNumber)) {
                    sprite.flipX = true;
                }
                else if(Main.inputCheck("right", playerNumber)) {
                    sprite.flipX = false;
                }
            }
        }
        else if(velocity.x != 0) {
            if(
                velocity.x > 0 && Main.inputCheck("left", playerNumber)
                || velocity.x < 0 && Main.inputCheck("right", playerNumber)
            ) {
                sprite.play("skid");
                if(!sfx["skid"].playing) {
                    sfx["skid"].play();
                }
            }
            else {
                sprite.play("run");
                playRunSfx = true;
            }
            sprite.flipX = velocity.x < 0;
        }
        else {
            sprite.play("idle");
        }

        if(playRunSfx) {
            if(!sfx["run"].playing) {
                if(!cast(scene, GameScene).allSfxStopped) {
                    sfx["run"].loop();
                }
            }
        }
        else {
            sfx["run"].stop();
        }

        if(playWallSlideSfx) {
            sfx["wallslide"].volume = Math.abs(
                velocity.y / MAX_FALL_SPEED_ON_WALL
            );
            if(!sfx["wallslide"].playing) {
                if(!cast(scene, GameScene).allSfxStopped) {
                    sfx["wallslide"].loop();
                }
            }
        }
        else {
            sfx["wallslide"].stop();
        }
    }
}
