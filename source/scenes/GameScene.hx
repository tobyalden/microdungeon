package scenes;

import haxepunk.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
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
    public static inline var SAVE_FILENAME = "renagame";
    public static inline var BACKGROUND_TEXTURE_SCROLL_SPEED = 30;

    public static var checkpoint:Vector2 = null;
    public static var lastSavePoint:Vector2 = null;
    public static var defeatedBosses:Array<String> = [];

    private var player:Player;
    private var curtain:Curtain;
    private var ui:UI;
    private var waitingForRespawn:Bool;
    private var sfx:Map<String, Sfx>;
    private var backgroundTexture:Backdrop;
    private var backgroundTexture2:Backdrop;

    public static function clearSaveData() {
        Data.load(SAVE_FILENAME);
        Data.write("lastSavePoint", null);
        Data.write("defeatedBosses", []);
        Data.write("saveDataExists", false);
        Data.save(SAVE_FILENAME);
    }

    override public function begin() {
        Data.load(SAVE_FILENAME);
        lastSavePoint = Data.read("lastSavePoint", null);
        defeatedBosses = Data.read("defeatedBosses", []);
        var level = new Level("testlevel");
        if(checkpoint != null) {
            player = new Player(checkpoint.x, checkpoint.y);
        }
        else if(lastSavePoint != null) {
            player = new Player(lastSavePoint.x, lastSavePoint.y);
        }
        else {
            player = new Player(level.playerStart.x, level.playerStart.y);
        }
        add(player);
        add(level);
        for(entity in level.entities) {
            if(defeatedBosses.indexOf(entity.name) == -1) {
                add(entity);
            }
        }
        ui = new UI();
        add(ui);
        curtain = new Curtain();
        add(curtain);
        curtain.fadeOut(0.5);
        waitingForRespawn = false;
        sfx = [
            "retryprompt" => new Sfx("audio/retryprompt.wav"),
            "retry" => new Sfx("audio/retry.wav"),
            "backtosavepoint" => new Sfx("audio/backtosavepoint.wav")
        ];
        var background = new Backdrop("graphics/background.png");
        addGraphic(background, 5);
        backgroundTexture = new Backdrop("graphics/backgroundtexture.png");
        addGraphic(backgroundTexture, 4);
        backgroundTexture2 = new Backdrop("graphics/backgroundtexture2.png");
        addGraphic(backgroundTexture2, 3);
    }

    public function saveGame(savePoint:SavePoint = null) {
        if(savePoint != null) {
            lastSavePoint = new Vector2(
                savePoint.centerX - player.width / 2,
                savePoint.bottom - player.height
            );
            checkpoint = lastSavePoint.clone();
        }
        Data.write("lastSavePoint", lastSavePoint);
        Data.write("defeatedBosses", defeatedBosses);
        Data.write("saveDataExists", true);
        Data.save(SAVE_FILENAME);
    }

    override public function update() {
        backgroundTexture.x -= HXP.elapsed * BACKGROUND_TEXTURE_SCROLL_SPEED;
        backgroundTexture2.x -= (
            HXP.elapsed * BACKGROUND_TEXTURE_SCROLL_SPEED / Math.PI * 2
        );
        if(waitingForRespawn) {
            if(Input.pressed("jump")) {
                respawn();
            }
            else if(Input.pressed("shoot")) {
                respawn(true);
            }
        }

        camera.x = Math.floor(player.centerX / HXP.width) * HXP.width;
        camera.y = Math.floor(player.centerY / HXP.height) * HXP.height;

        for(boss in getAllBosses()) {
            boss.graphic.color = boss.active ? 0xFFFFFF : 0x0000FF;
        }

        var updateLast = new Array<Entity>();
        var updateFirst = new Array<Entity>();
        for(e in _update) {
            if(Type.getClass(e) == Player) {
                _update.remove(e);
                updateLast.push(e);
            }
            if(Type.getClass(e) == Elevator) {
                _update.remove(e);
                updateFirst.push(e);
            }
        }

        for(e in updateFirst) {
            _update.push(e);
        }
        for(e in updateLast) {
            _update.add(e);
        }

        super.update();
    }

    public function getAllBosses() {
        var _bosses = new Array<Entity>();
        var bosses = new Array<Boss>();
        getType("boss", _bosses);
        for(_boss in _bosses) {
            var boss = cast(_boss, Boss);
            bosses.push(boss);
        }
        return bosses;
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
        doSequence([
            {
                atTime: 2,
                doThis: function() {
                    ui.showRetryPrompt();
                    sfx["retryprompt"].play();
                    waitingForRespawn = true;
                }
            }
        ]);
    }

    public function respawn(fromLastSavePoint:Bool = false) {
        waitingForRespawn = false;
        if(fromLastSavePoint) {
            checkpoint = null;
            sfx["backtosavepoint"].play();
        }
        else {
            sfx["retry"].play();
        }
        curtain.fadeIn(0.5);
        doSequence([
            {
                atTime: 0.5,
                doThis: function() {
                    for(boss in getCurrentBosses()) {
                        boss.sfx["klaxon"].stop();
                    }
                    HXP.scene = new GameScene();
                }
            }
        ]);
    }

    private function doSequence(sequence:Array<SequenceStep>) {
        for(step in sequence) {
            var stepTimer = new Alarm(step.atTime);
            stepTimer.onComplete.bind(step.doThis);
            addTween(stepTimer, true);
        }
    }

}
