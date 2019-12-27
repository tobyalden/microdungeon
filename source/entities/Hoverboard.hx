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

class Hoverboard extends MiniEntity
{
    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        type = "hoverboard";
        mask = new Hitbox(32, 32);
        graphic = new Image("graphics/hoverboard.png");
        var bob = new VarTween(TweenType.PingPong);
        bob.tween(this, "y", y - 10, 1, Ease.sineInOut);
        addTween(bob, true);
    }
}
