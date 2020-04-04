package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.utils.*;

class Player extends MiniEntity
{
    public static inline var RUN_ACCEL = 400 * 1.8;
    public static inline var RUN_ACCEL_TURN_MULTIPLIER = 2;
    public static inline var RUN_DECEL = RUN_ACCEL * RUN_ACCEL_TURN_MULTIPLIER;
    public static inline var AIR_ACCEL = 360 * 1.8;
    public static inline var AIR_DECEL = 360;
    public static inline var MAX_RUN_SPEED = 100 / 1.25;
    public static inline var MAX_AIR_SPEED = 120 / 1.25;
    public static inline var GRAVITY = 600;
    public static inline var GRAVITY_ON_WALL = 150;
    public static inline var JUMP_POWER = 160;
    public static inline var JUMP_CANCEL_POWER = 40;
    public static inline var WALL_JUMP_POWER_X = 140 / 1.5 / 1.1;
    public static inline var WALL_JUMP_POWER_Y = 120 * 1.35 / 1.1;
    public static inline var WALL_STICKINESS = 60;
    public static inline var MAX_FALL_SPEED = 270;
    public static inline var MAX_FALL_SPEED_ON_WALL = 0;

    public static inline var HOOK_SHOT_SPEED = 250;
    public static inline var GRAPPLE_EXIT_SPEED = 100;
    public static inline var ANGULAR_ACCELERATION_MULTIPLIER = 14;
    public static inline var SWING_DECELERATION = 0.99;
    public static inline var INITIAL_SWING_SPEED = 3;
    public static inline var SWING_INFLUENCE = 4;
    public static inline var MIN_HOOK_DISTANCE = 25;
    public static inline var MAX_HOOK_DISTANCE = 75;

    public static inline var HOOK_RETRACT_SPEED = 50;
    public static inline var HOOK_RELEASE_SPEED = 75;

    private var sprite:Spritemap;
    private var velocity:Vector2;
    private var hook:Hook;
    private var rotateAmount:Float;

    public function new(x:Float, y:Float) {
        super(x, y);
        name = "player";
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("up", [Key.UP]);
        Key.define("down", [Key.DOWN]);
        Key.define("jump", [Key.Z]);
        Key.define("grapple", [Key.X]);
        sprite = new Spritemap("graphics/player.png", 8, 12);
        sprite.add("idle", [0]);
        sprite.add("run", [1, 2, 3, 2], 8);
        sprite.add("jump", [4]);
        sprite.add("wall", [5]);
        sprite.add("skid", [6]);
        sprite.play("idle");
        graphic = sprite;
        sprite.x = -1;
        mask = new Hitbox(6, 12);
        velocity = new Vector2();
        rotateAmount = 0;
    }

    override public function update() {
        movement();
        animation();
        super.update();
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
            if(Input.released("jump")) {
                velocity.y = Math.max(velocity.y, -JUMP_CANCEL_POWER);
            }
            velocity.y += GRAVITY * HXP.elapsed;
            velocity.y = Math.min(velocity.y, MAX_FALL_SPEED);
        }

        if(Input.pressed("grapple")) {
            if(hook != null) {
                scene.remove(hook);
            }
            var hookDirection = sprite.flipX ? -1 : 1;
            if(Input.check("left")) {
                hookDirection = -1;
            }
            else if(Input.check("right")) {
                hookDirection = 1;
            }
            var hookVelocity = new Vector2(
                hookDirection * HOOK_SHOT_SPEED, -HOOK_SHOT_SPEED
            );
            hook = new Hook(centerX - 4, centerY - 4, hookVelocity);
            scene.add(hook);
        }
        if(Input.released("grapple")) {
            if(hook != null) {
                detachHook();
            }
        }

        if(hook != null && distanceFrom(hook) > MAX_HOOK_DISTANCE) {
            detachHook();
        }

        if(
            hook != null
            && hook.isAttached
            && distanceFrom(hook) > MIN_HOOK_DISTANCE
        ) {
            if(Input.check("up")) {
                var towardsHook = new Vector2(
                    hook.centerX - centerX, hook.centerY - centerY
                );
                towardsHook.normalize(HOOK_RETRACT_SPEED);
                var oldPosition = new Vector2(x, y);
                moveTo(
                    x + towardsHook.x * HXP.elapsed,
                    y + towardsHook.y * HXP.elapsed,
                    "walls"
                );
                if(distanceFrom(hook) <= MIN_HOOK_DISTANCE) {
                    x = oldPosition.x;
                    y = oldPosition.y;
                }
            }
            else if(Input.check("down")) {
                var awayFromHook = new Vector2(
                    centerX - hook.centerX, centerY - hook.centerY
                );
                awayFromHook.normalize(HOOK_RETRACT_SPEED);
                var oldPosition = new Vector2(x, y);
                moveTo(
                    x + awayFromHook.x * HXP.elapsed,
                    y + awayFromHook.y * HXP.elapsed,
                    "walls"
                );
                if(distanceFrom(hook) > MAX_HOOK_DISTANCE - 10) {
                    x = oldPosition.x;
                    y = oldPosition.y;
                }
            }

            if(
                isOnCeiling() || isOnGround()
                || isOnLeftWall() || isOnRightWall()
            ) {
                rotateAmount = 0;
            }
            var angularAcceleration = new Vector2(
                centerX - hook.centerX, centerY - hook.centerY
            );
            angularAcceleration.normalize(ANGULAR_ACCELERATION_MULTIPLIER);
            if(Input.check("left")) {
                var swingInfluence = new Vector2(SWING_INFLUENCE, 0);
                angularAcceleration.add(swingInfluence);
            }
            else if(Input.check("right")) {
                var swingInfluence = new Vector2(-SWING_INFLUENCE, 0);
                angularAcceleration.add(swingInfluence);
            }
            rotateAmount += angularAcceleration.x * HXP.elapsed;
            rotateAmount *= Math.pow(
                SWING_DECELERATION, (HXP.elapsed * HXP.assignedFrameRate)
            );
            var rotateAmountTimeScaled = rotateAmount * HXP.elapsed;
            // Math from https://math.stackexchange.com/questions/814950
            var xRotated = (
                Math.cos(rotateAmountTimeScaled) * (centerX - hook.centerX)
                - Math.sin(rotateAmountTimeScaled) * (centerY - hook.centerY)
                + hook.centerX
            ) - width / 2;
            var yRotated = (
                Math.sin(rotateAmountTimeScaled) * (centerX - hook.centerX)
                + Math.cos(rotateAmountTimeScaled) * (centerY - hook.centerY)
                + hook.centerY
            ) - height / 2;
            velocity = new Vector2(xRotated - x, yRotated - y);
            velocity.scale(1 / HXP.elapsed);
            if(!(
                isOnCeiling() && yRotated < y
                || isOnGround() && yRotated > y
                || isOnLeftWall() && xRotated < x
                || isOnRightWall() && xRotated > x
            )) {
                moveTo(xRotated, yRotated, "walls");
            }
        }
        else {
            moveBy(
                velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls"
            );
        }
    }

    public function detachHook() {
        hook.enabled = false;
        scene.remove(hook);
        hook = null;
    }

    public function setRotateAmountToInitialValue() {
        var hookDirection = sprite.flipX ? -1 : 1;
        if(Input.check("left")) {
            hookDirection = -1;
        }
        else if(Input.check("right")) {
            hookDirection = 1;
        }
        var entranceAngle = new Vector2(
            centerX - hook.centerX, centerY - hook.centerY
        );
        entranceAngle.normalize(INITIAL_SWING_SPEED);
        rotateAmount = entranceAngle.x;
        rotateAmount -= velocity.x / 100;
        if(velocity.y < 0) {
            rotateAmount += (velocity.y / 100) * entranceAngle.x;
        }
        trace(rotateAmount);
    }

    override public function render(camera:Camera) {
        if(hook != null && hook.isAttached) {
            Draw.color = 0xFFFFFF;
            Draw.line(centerX, centerY, hook.centerX, hook.centerY);
            Draw.color = 0x00FF00;
            Draw.circle(
                hook.centerX,
                hook.centerY,
                MathUtil.distance(
                    centerX, centerY, hook.centerX, hook.centerY
                ),
                100
            );
        }
        super.render(camera);
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
