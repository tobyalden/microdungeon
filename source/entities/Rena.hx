package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;

class Rena extends MiniEntity
{
    private var sprite:Spritemap;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        type = "hazard";
        mask = new Hitbox(75, 75);
        sprite = new Spritemap("graphics/rena.png", 75, 75);
        sprite.add("idle", [0]);
        graphic = sprite;
    }

    override public function update() {
        super.update();
    }
}
