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
        Key.define("left", [Key.LEFT]);
        Key.define("right", [Key.RIGHT]);
        Key.define("up", [Key.UP]);
        Key.define("down", [Key.DOWN]);
        Key.define("interact", [Key.DOWN, Key.UP]);
        Key.define("jump", [Key.Z]);
        Key.define("shoot", [Key.X]);
        Key.define("cheat", [Key.P]);

        //HXP.scene = new GameScene();
        HXP.scene = new Ending();
    }

    override public function update() {
        super.update();
    }
}
