package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.math.*;

class Hook extends MiniEntity
{
    public var isAttached(default, null):Bool;
    private var velocity:Vector2;

    public function new(x:Float, y:Float, velocity:Vector2) {
        super(x, y);
        this.velocity = velocity;
        graphic = new Image("graphics/hook.png");
        setHitbox(8, 8);
        isAttached = false;
    }

    override public function update() {
        var player = scene.getInstance("player");
        moveBy(
            velocity.x * HXP.elapsed, velocity.y * HXP.elapsed, "walls", true
        );
        super.update();
    }

    override public function moveCollideX(_:Entity) {
        velocity = new Vector2(0, 0);
        isAttached = true;
        var player = cast(scene.getInstance("player"), Player);
        player.setRotateAmountToInitialValue();
        return true;
    }

    override public function moveCollideY(_:Entity) {
        velocity = new Vector2(0, 0);
        isAttached = true;
        var player = cast(scene.getInstance("player"), Player);
        player.setRotateAmountToInitialValue();
        return true;
    }
}
