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

    override public function begin() {
        //add(new Sawblade(
            //52, HXP.height - 25 - 8, new Vector2(252, HXP.height - 25 - 8)
        //));
        var level = new Level("testlevel");
        player = new Player(level.playerStart.x, level.playerStart.y);
        add(player);
        add(level);
        for(entity in level.entities) {
            add(entity);
        }
        add(new UI());
    }

    override public function update() {
        camera.x = Math.floor(player.centerX / HXP.width) * HXP.width;
        super.update();
    }

    public function onDeath() {
        doSequence([{
            atTime: 3,
            doThis: function() { HXP.scene = new GameScene(); }
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
