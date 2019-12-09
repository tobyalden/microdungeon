package scenes;

import haxepunk.*;
import haxepunk.graphics.tile.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import entities.*;

class GameScene extends Scene
{
    public var allSfxStopped(default, null):Bool;
    private var clouds:Entity;
    private var clouds2:Entity;

    override public function begin() {
        clouds = new Entity(0, 0, new Backdrop("graphics/clouds.png"));
        clouds.layer = 20;
        add(clouds);
        clouds2 = new Entity(0, 0, new Backdrop("graphics/clouds2.png"));
        clouds2.layer = 19;
        add(clouds2);
        var level = new Level("testlevel");
        add(level);
        for(entity in level.entities) {
            add(entity);
        }
        allSfxStopped = false;
    }

    override public function update() {
        clouds.x -= 100 * HXP.elapsed;
        clouds2.x -= 34 * HXP.elapsed;
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

    private function getNumberOfAlivePlayers() {
        var players = new Array<Entity>();
        getType("player", players);
        var numberOfAlivePlayers = 0;
        for(player in players) {
            if(!cast(player, Player).isDead) {
                numberOfAlivePlayers++;
            }
        }
        return numberOfAlivePlayers;
    }

    public function onDeath() {
        if(getNumberOfAlivePlayers() <= 1) {
            var resetTimer = new Alarm(3);
            resetTimer.onComplete.bind(function() {
                stopAllSfx();
                HXP.scene = new GameScene();
            });
            addTween(resetTimer, true);
        }
    }
}
