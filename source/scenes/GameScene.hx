package scenes;

import haxepunk.*;
import entities.*;

class GameScene extends Scene
{
    override public function begin() {
        add(new Player(152, 82));
        add(new Level("testlevel"));
    }

    override public function update() {
        super.update();
    }
}
