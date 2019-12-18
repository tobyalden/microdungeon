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

class UI extends MiniEntity
{
    private var bossHealth:ColoredRect;

    public function new() {
        super(0, 0);
        layer = -99;
        bossHealth = new ColoredRect(HXP.width - 10, 4, 0xFFFFFF);
        bossHealth.x = 5;
        bossHealth.y = HXP.height - 8;
        graphic = bossHealth;
    }

    override public function update() {
        followCamera = scene.camera;
        var mion = scene.getInstance("mion");
        if(mion != null) {
            bossHealth.width = (
                cast(mion, Mion).health / Mion.MAX_HEALTH
                * (HXP.width - 10)
            );
        }
        super.update();
    }
}
