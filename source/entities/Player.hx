package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;

class Player extends Entity
{
    public static inline var SPEED = 100;

    private var velocity:Vector2;

    public function new(x:Float, y:Float) {
        super(x, y);
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        graphic = new Image("graphics/player.png");
        velocity = new Vector2();
        mask = new Hitbox(16, 16);
    }

    override public function update() {
        if(Input.check("left")) {
            velocity.x = -SPEED;
        }
        else if(Input.check("right")) {
            velocity.x = SPEED;
        }
        else {
            velocity.x = 0;
        }
        moveBy(velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls");
        super.update();
    }
}
