package scenes;

import haxepunk.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import entities.*;

class GameScene extends Scene
{
    public var allSfxStopped(default, null):Bool;

    override public function begin() {
        var level = new Level("testlevel");
        add(level);
        for(entity in level.entities) {
            add(entity);
        }
        allSfxStopped = false;
    }

    override public function update() {
        super.update();
    }

    public function stopAllSfx() {
        cast(getInstance("player1"), Player).stopAllSfx();
        cast(getInstance("player2"), Player).stopAllSfx();
        if(getInstance("boomerang1") != null) {
            cast(getInstance("boomerang1"), Boomerang).stopAllSfx();
        }
        if(getInstance("boomerang2") != null) {
            cast(getInstance("boomerang2"), Boomerang).stopAllSfx();
        }
        allSfxStopped = true;
    }

    public function onDeath() {
        var resetTimer = new Alarm(3);
        resetTimer.onComplete.bind(function() {
            stopAllSfx();
            HXP.scene = new GameScene();
        });
        addTween(resetTimer, true);
    }
}
