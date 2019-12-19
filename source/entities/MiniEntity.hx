package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class MiniEntity extends Entity
{
    public function new(x:Float, y:Float) {
        super(x, y);
    }

    public function isOffScreen() {
        return (
            x + width < scene.camera.x
            || x > scene.camera.x + HXP.width
            || y + height < scene.camera.y
            || y > scene.camera.y + HXP.height
        );
    }

    public function isOnGround() {
        return collide("walls", x, y + 1) != null;
    }

    public function isOnCeiling() {
        return collide("walls", x, y - 1) != null;
    }

    public function isOnWall() {
        return isOnRightWall() || isOnLeftWall();
    }

    public function isOnRightWall() {
        return collide("walls", x + 1, y) != null;
    }

    public function isOnLeftWall() {
        return collide("walls", x - 1, y) != null;
    }
}
