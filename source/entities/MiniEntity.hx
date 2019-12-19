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

    private function explode() {
        var numExplosions = 50;
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
        scene.camera.shake(1, 4);
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
