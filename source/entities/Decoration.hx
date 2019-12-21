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

class Decoration extends MiniEntity
{
    private var sprite:Image;

    public function new(
        startX:Float, startY:Float, filePath:String, layer:Int
    ) {
        super(startX, startY);
        this.layer = layer;
        sprite = new Image('graphics/${filePath}.png');
        trace('loaded ${filePath}');
        graphic = sprite;
    }
}
