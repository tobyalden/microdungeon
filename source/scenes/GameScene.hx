package scenes;

import haxepunk.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import entities.*;

typedef SequenceStep = {
  var atTime:Float;
  var doThis:Void->Void;
}

class GameScene extends Scene
{
    private var player:Player;
    private var curtain:Curtain;

    override public function begin() {
        var level = new Level("testlevel");
        player = new Player(level.playerStart.x, level.playerStart.y);
        add(player);
        add(level);
        for(entity in level.entities) {
            add(entity);
        }
        add(new UI());
        curtain = new Curtain();
        add(curtain);
        curtain.fadeOut(0.5);
    }

    override public function update() {
        camera.x = Math.floor(player.centerX / HXP.width) * HXP.width;
        super.update();
    }

    public function getCurrentBosses() {
        var _bosses = new Array<Entity>();
        var bosses = new Array<Boss>();
        getType("boss", _bosses);
        for(_boss in _bosses) {
            var boss = cast(_boss, Boss);
            if(!boss.isOffScreen()) {
                bosses.push(boss);
            }
        }
        return bosses;
    }

    public function onDeath() {
        doSequence([{
            atTime: 3,
            doThis: function() {
                for(boss in getCurrentBosses()) {
                    boss.sfx["klaxon"].stop();
                }
                HXP.scene = new GameScene();
            }
        }]);
    }

    private function doSequence(sequence:Array<SequenceStep>) {
        for(step in sequence) {
            var stepTimer = new Alarm(step.atTime);
            stepTimer.onComplete.bind(step.doThis);
            addTween(stepTimer, true);
        }
    }

}
