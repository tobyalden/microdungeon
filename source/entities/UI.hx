package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
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

    private var retryPrompt:Text;
    private var retryPromptRotator:VarTween;
    private var primaryBossHealthBar:ColoredRect;
    private var secondaryBossHealthBar:ColoredRect;
    private var colorShifterOne:ColorTween;
    private var colorShifterTwo:ColorTween;

    public function showRetryPrompt() {
        var retryPromptFader = new VarTween();
        retryPromptFader.tween(retryPrompt, "alpha", 1, 0.5, Ease.sineOut);
        addTween(retryPromptFader, true);
    }

    public function new() {
        super(0, 0);
        layer = -99;

        var sprite = new Graphiclist();
        retryPrompt = new Text(
            'Z = AGAIN !!!\nX = BACK 2 SAVE POINT', { size: 24 }
        );
        retryPrompt.centerOrigin();
        retryPrompt.font = "font/action.ttf";
        retryPrompt.angle = -6;
        retryPrompt.x = HXP.width / 2;
        retryPrompt.y = HXP.height / 2;
        retryPrompt.alpha = 0;
        sprite.add(retryPrompt);

        retryPromptRotator = new VarTween(TweenType.PingPong);
        retryPromptRotator.tween(retryPrompt, "angle", 6, 1.5, Ease.sineInOut);
        addTween(retryPromptRotator, true);

        primaryBossHealthBar = new ColoredRect(0, 4, 0xFFFFFF);
        primaryBossHealthBar.x = 4;
        primaryBossHealthBar.y = HXP.height - 8;
        sprite.add(primaryBossHealthBar);

        secondaryBossHealthBar = new ColoredRect(0, 4, 0xFFFFFF);
        secondaryBossHealthBar.x = 4 + DOUBLE_BOSS_HEALTHBAR_LENGTH + 4;
        secondaryBossHealthBar.y = HXP.height - 8;
        sprite.add(secondaryBossHealthBar);

        colorShifterOne = new ColorTween(TweenType.PingPong);
        colorShifterOne.tween(
            1, Color.getColorRGB(255, 0, 0), Color.getColorRGB(255, 170, 29), 1, 1, Ease.sineInOut
        );
        addTween(colorShifterOne, true);

        //colorShifterTwo = new ColorTween(TweenType.Looping);
        //colorShifterTwo.tween(1, 0xff0000, 0x00FF00);
        //addTween(colorShifterTwo.tween, true);

        graphic = sprite;
    }

    override public function update() {
        primaryBossHealthBar.color = colorShifterOne.color;
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
