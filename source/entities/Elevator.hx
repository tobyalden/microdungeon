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

class Elevator extends MiniEntity
{
    public static inline var SPEED = 40;

    public var isUsed(default, null):Bool;
    private var path:LinearPath;

    public function new(
        startX:Float, startY:Float, pathPoints:Array<Vector2>
    ) {
        super(startX, startY);
        type = "elevator";
        layer = -1;
        mask = new Hitbox(16, 4);
        graphic = new Image("graphics/elevator.png");
        path = new LinearPath();
        for(point in pathPoints) {
            path.addPoint(point.x, point.y);
        }
        path.setMotionSpeed(SPEED);
        path.onComplete.bind(function() {
            moveTo(path.x, path.y);
            var player = scene.getInstance("player");
            if(player != null) {
                cast(player, Player).getOffElevator();
            }
        });
        addTween(path);
        isUsed = false;
    }

    public function activate() {
        path.start();
        isUsed = true;
    }

    override public function update() {
        if(path.active) {
            moveTo(path.x, path.y);
        }
        super.update();
    }
}

