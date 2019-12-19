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
import scenes.*;

class UI extends MiniEntity
{
    // Buffer of 4
    public static inline var SINGLE_BOSS_HEALTHBAR_LENGTH = 312;
    public static inline var DOUBLE_BOSS_HEALTHBAR_LENGTH = 154;

    private var primaryBossHealthBar:ColoredRect;
    private var secondaryBossHealthBar:ColoredRect;

    public function new() {
        super(0, 0);
        layer = -99;

        primaryBossHealthBar = new ColoredRect(0, 4, 0xFFFFFF);
        primaryBossHealthBar.x = 4;
        primaryBossHealthBar.y = HXP.height - 8;

        secondaryBossHealthBar = new ColoredRect(0, 4, 0xFFFFFF);
        secondaryBossHealthBar.x = 4 + DOUBLE_BOSS_HEALTHBAR_LENGTH + 4;
        secondaryBossHealthBar.y = HXP.height - 8;

        var allBossHealthBars = new Graphiclist();
        allBossHealthBars.add(primaryBossHealthBar);
        allBossHealthBars.add(secondaryBossHealthBar);
        graphic = allBossHealthBars;
    }

    override public function update() {
        followCamera = scene.camera;
        var bosses = cast(scene, GameScene).getCurrentBosses();
        primaryBossHealthBar.visible = bosses.length > 0;
        secondaryBossHealthBar.visible = bosses.length > 1;
        if(bosses.length == 1) {
            primaryBossHealthBar.width = (
                bosses[0].health / bosses[0].startingHealth
                * SINGLE_BOSS_HEALTHBAR_LENGTH
            );
        }
        else if(bosses.length == 2) {
            primaryBossHealthBar.width = (
                bosses[0].health / bosses[0].startingHealth
                * DOUBLE_BOSS_HEALTHBAR_LENGTH
            );
            secondaryBossHealthBar.width = (
                bosses[1].health / bosses[1].startingHealth
                * DOUBLE_BOSS_HEALTHBAR_LENGTH
            );
        }
        super.update();
    }
}
