import haxepunk.*;
import haxepunk.debug.Console;
import haxepunk.input.*;
import scenes.*;

class Main extends Engine
{
    static function main() {
        new Main();
    }

    override public function init() {
#if debug
        Console.enable();
#end
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET, Key.J]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET, Key.L]);
        Key.define("up", [Key.UP, Key.I]);
        Key.define("down", [Key.DOWN, Key.K]);
        Key.define("jump", [Key.Z, Key.A]);
        Key.define("shoot", [Key.X, Key.S]);

        HXP.scene = new GameScene();
        //HXP.scene = new MainMenu();
    }

    override public function update() {
        super.update();
    }
}
