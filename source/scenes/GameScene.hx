package scenes;

import haxepunk.*;
import haxepunk.math.*;
import entities.*;

class GameScene extends Scene
{
    override public function begin() {
        add(new Player(10, 50));
        add(new Sawblade(
            52, HXP.height - 25, new Vector2(252, HXP.height - 25)
        ));
        add(new Level("testlevel"));
    }

    override public function update() {
        super.update();
    }
}
