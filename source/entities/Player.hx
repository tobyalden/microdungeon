package entities;

import haxepunk.*;
import haxepunk.graphics.*;

class Player extends Entity
{
    public function new() {
        super();
        graphic = new Image("graphics/player.png");
    }

    override public function update() {
        super.update();
    }
}
