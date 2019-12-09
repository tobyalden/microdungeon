package scenes;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import entities.*;

typedef SequenceStep = {
  var atTime:Float;
  var doThis:Void->Void;
}

class GameScene extends Scene
{
    public var allSfxStopped(default, null):Bool;
    private var clouds:Entity;
    private var clouds2:Entity;
    private var centerDisplayText:Text;
    private var centerDisplay:Entity;
    private var curtain:Curtain;
    private var sfx:Map<String, Sfx>;

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
        centerDisplayText = new Text("READY", { size: 36 });
        centerDisplayText.alpha = 0;
        centerDisplay = new Entity(
            HXP.width / 2 - centerDisplayText.textWidth / 2,
            HXP.height / 2 - centerDisplayText.textHeight / 2,
            centerDisplayText
        );
        centerDisplay.layer = -999;
        add(centerDisplay);

        curtain = new Curtain();
        add(curtain);
        curtain.fadeOut(0.5);

        doSequence([
            {
                atTime: 0.75,
                doThis: function() {
                    centerDisplayText.alpha = 1;
                    sfx["ready"].play();
                }
            },
            {
                atTime: 1.5,
                doThis: function() {
                    centerDisplayText.text = "FIGHT";
                    centerDisplayText.color = 0xFF0000;
                    sfx["fight"].play();
                    startMatch();
                }
            },
            {
                atTime: 2.25,
                doThis: function() {
                    centerDisplayText.alpha = 0;
                }
            }
        ]);

        sfx = [
            "ready" => new Sfx("audio/ready.wav"),
            "fight" => new Sfx("audio/fight.wav")
        ];
    }

    private function doSequence(sequence:Array<SequenceStep>) {
        for(step in sequence) {
            var stepTimer = new Alarm(step.atTime);
            stepTimer.onComplete.bind(step.doThis);
            addTween(stepTimer, true);
        }
    }

    public function startMatch() {
        var players = new Array<Entity>();
        getType("player", players);
        for(player in players) {
            cast(player, Player).setCanMove(true);
        }
    }

    override public function update() {
        clouds.x -= 100 * HXP.elapsed;
        clouds2.x -= 34 * HXP.elapsed;
        super.update();
    }

    public function stopAllSfx() {
        cast(getInstance("player1"), Player).stopAllSfx();
        cast(getInstance("player2"), Player).stopAllSfx();
        if(getInstance("player3") != null) {
            cast(getInstance("player3"), Player).stopAllSfx();
        }
        if(getInstance("boomerang1") != null) {
            cast(getInstance("boomerang1"), Boomerang).stopAllSfx();
        }
        if(getInstance("boomerang2") != null) {
            cast(getInstance("boomerang2"), Boomerang).stopAllSfx();
        }
        if(getInstance("boomerang3") != null) {
            cast(getInstance("boomerang3"), Boomerang).stopAllSfx();
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
            doSequence([
                {
                    atTime: 2.5,
                    doThis: function() {
                        curtain.fadeIn(0.5);
                    }
                }
            ]);
        }
    }
}
