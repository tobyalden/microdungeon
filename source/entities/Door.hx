package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.Spritemap;
import haxepunk.graphics.text.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.GameScene;

class Door extends MiniEntity
{
    public var toLevel(default, null):String;

    public function new(
        x:Float, y:Float, width:Int, height:Int, toLevel:String
    ) {
        super(x, y);
        this.toLevel = toLevel;
        type = "door";
        mask = new Hitbox(width, height);
    }

    override public function update() {
        super.update();
    }
}
