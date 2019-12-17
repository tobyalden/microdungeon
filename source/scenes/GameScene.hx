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
    override public function begin() {
        add(new Player(10, 50));
        add(new Sawblade(
            52, HXP.height - 25, new Vector2(252, HXP.height - 25)
        ));
        add(new Level("testlevel"));
    }

    override public function update() {
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
