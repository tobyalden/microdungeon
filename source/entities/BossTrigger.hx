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

class BossTrigger extends MiniEntity
{
    public var bossName(default, null):String;

    public function new(
        startX:Float, startY:Float, startWidth:Int, startHeight:Int,
        bossName:String
    ) {
        super(startX, startY);
        this.bossName = bossName;
        type = "bosstrigger";
        mask = new Hitbox(startWidth, startHeight);
    }

    override public function update() {
        super.update();
    }
}

