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

class NoHoverboardSign extends MiniEntity
{
    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        layer = 1;
        type = "nohoverboardsign";
        mask = new Hitbox(7, 100, 27);
        graphic = new Image("graphics/nohoverboardsign.png");
    }
}
