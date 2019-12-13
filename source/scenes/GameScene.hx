package scenes;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
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
    public static inline var MAX_NUMBER_OF_PLAYERS = 3;
    public static inline var MAX_MATCH_POINT = 12;

    static public var numberOfPlayers:Int = 2;
    static public var matchPoint:Int = 3;
    static public var victoriesByPlayer:Map<Int, Int> = [
        1 => 0,
        2 => 0,
        3 => 0,
        4 => 0
    ];

    public var allSfxStopped(default, null):Bool;
    private var clouds:Entity;
    private var clouds2:Entity;
    private var centerDisplayText:Text;
    private var centerDisplay:Entity;
    private var centerDisplaySmallText:Text;
    private var centerDisplaySmall:Entity;
    private var curtain:Curtain;
    private var scoreboard:Scoreboard;
    private var sfx:Map<String, Sfx>;
    private var isMatchOver:Bool;
    private var isRestarting:Bool;

    override public function begin() {
        Key.define("togglethirdplayer", [Key.DIGIT_3]);
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
        centerDisplay.layer = -50;
        add(centerDisplay);

        centerDisplaySmallText = new Text("Returning to menu...", { size: 12 });
        centerDisplaySmallText.alpha = 0;
        centerDisplaySmall = new Entity(
            HXP.width / 2 - centerDisplaySmallText.textWidth / 2,
            centerDisplay.y + centerDisplayText.textHeight - 10,
            centerDisplaySmallText
        );
        centerDisplaySmall.layer = -50;
        add(centerDisplaySmall);

        curtain = new Curtain();
        add(curtain);
        curtain.fadeOut(0.5);

        scoreboard = new Scoreboard();
        scoreboard.visible = false;
        add(scoreboard);

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
            "fight" => new Sfx("audio/fight.wav"),
            "showscoreboard" => new Sfx("audio/showscoreboard.wav"),
            "addpoint" => new Sfx("audio/addpoint.wav"),
            "addfinalpoint" => new Sfx("audio/addfinalpoint.wav"),
            "gameover" => new Sfx("audio/gameover.ogg")
        ];
        isMatchOver = false;
        isRestarting = false;
    }

    private function realignCenterDisplay() {
        centerDisplay.x = HXP.width / 2 - centerDisplayText.textWidth / 2;
        centerDisplay.y = HXP.height / 2 - centerDisplayText.textHeight / 2;
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

    public function returnToMenu() {
        for(playerNumber in victoriesByPlayer.keys()) {
            victoriesByPlayer[playerNumber] = 0;
        }
        curtain.fadeIn(3);
        doSequence([
            {
                atTime: 3,
                doThis: function() {
                    stopAllSfx();
                    HXP.scene = new MainMenu();
                    sfx["gameover"].stop();
                }
            }
        ]);
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

    private function getNumberOfLastAlivePlayer() {
        var players = new Array<Entity>();
        getType("player", players);
        for(_player in players) {
            var player = cast(_player, Player);
            if(!player.isDead) {
                return player.playerNumber;
            }
        }
        return 0;
    }

    public function onDeath() {
        if(getNumberOfAlivePlayers() <= 1) {
            var endOfMatch = victoriesByPlayer[
                getNumberOfLastAlivePlayer()
            ] + 1 == matchPoint;
            if(endOfMatch) {
                sfx["gameover"].play();
            }
            doSequence([
                {
                    atTime: 1.5,
                    doThis: function() {
                        scoreboard.visible = true;
                        sfx["showscoreboard"].play();
                    }
                },
                {
                    atTime: 2.5,
                    doThis: function() {
                        victoriesByPlayer[getNumberOfLastAlivePlayer()] += 1;
                        sfx[endOfMatch ? "addfinalpoint" : "addpoint"].play();
                    }
                },
                {
                    atTime: 4.5,
                    doThis: function() {
                        if(!endOfMatch) {
                            curtain.fadeIn(0.5);
                        }
                        else {
                            scoreboard.visible = false;
                        }
                    }
                },
                {
                    atTime: 5,
                    doThis: function() {
                        if(endOfMatch) {
                            centerDisplayText.text = 'PLAYER ${
                                getNumberOfLastAlivePlayer()
                            } WINS';
                            centerDisplayText.color = 0xFFFFFF;
                            centerDisplayText.alpha = 1;
                            realignCenterDisplay();
                            isMatchOver = true;
                        }
                        else {
                            stopAllSfx();
                            HXP.scene = new GameScene();
                        }
                    }
                },
                {
                    atTime: 7,
                    doThis: function() {
                        if(endOfMatch) {
                            centerDisplaySmallText.alpha = 1;
                            returnToMenu();
                        }
                    }
                }
            ]);
        }
    }
}
