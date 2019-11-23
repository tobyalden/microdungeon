package entities;

import haxepunk.*;
import haxepunk.graphics.*;

class Player extends Entity
{
    public function new(x:Float, y:Float) {
        super(x, y);
        graphic = new Image("graphics/player.png");
    }

    override public function update() {
        super.update();
    }
}
