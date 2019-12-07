package scenes;

import haxepunk.*;
import entities.*;

class GameScene extends Scene
{
    override public function begin() {
        var level = new Level("testlevel");
        add(level);
        for(entity in level.entities) {
            add(entity);
        }
    }

    override public function update() {
        super.update();
    }
}
