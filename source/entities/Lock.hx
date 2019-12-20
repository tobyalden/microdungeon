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

class Lock extends MiniEntity
{
    public var bossName(default, null):String;

    public function new(
        startX:Float, startY:Float, startWidth:Int, startHeight:Int,
        bossName:String
    ) {
        super(startX, startY);
        type = "walls";
        this.bossName = bossName;
        mask = new Hitbox(startWidth, startHeight);
        graphic = new ColoredRect(startWidth, startHeight, 0x808080);
    }

    override public function update() {
        var boss = scene.getInstance(bossName);
        visible = boss != null && boss.active;
        collidable = boss != null && boss.active;
        super.update();
    }
}


