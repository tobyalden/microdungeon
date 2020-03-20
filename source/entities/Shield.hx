package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import scenes.*;

class Shield extends MiniEntity
{
    public static inline var WIDTH = 2;
    public static inline var HEIGHT = 20;
    public static inline var DISTANCE_FROM_PLAYER = 5;

    public function new() {
        super(0, 0);
        name = "shield";
        type = "shield";
        graphic = new ColoredRect(WIDTH, HEIGHT, 0x35f22e);
        mask = new Hitbox(WIDTH, HEIGHT);
    }

    override public function update() {
        var player = scene.getInstance("player");
        y = player.y;
        if(Input.check("up")) {
            y -= 6;
        }
        else if(Input.check("down")) {
            y += 6;
        }
        if(cast(player.graphic, Spritemap).flipX) {
            x = player.x - DISTANCE_FROM_PLAYER - 2;
        }
        else {
            x = player.x + player.width + DISTANCE_FROM_PLAYER;
        }
        var bullets = new Array<Entity>();
        collideTypesInto(["hazard"], x, y, bullets);
        for(bullet in bullets) {
            if(Type.getClass(bullet) == Bullet) {
                cast(bullet, Bullet).setXVelocityAwayFromPlayer();
                if(bullet.centerX < centerX) {
                    bullet.x = x - bullet.width + 5;
                }
                else {
                    bullet.x = x + width + 5;
                }
            }
        }
    }
}
