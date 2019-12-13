package scenes;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.text.*;
import haxepunk.graphics.tile.*;
import haxepunk.input.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import entities.*;

typedef SequenceStepForMenu = {
  var atTime:Float;
  var doThis:Void->Void;
}

class MainMenu extends Scene
{
    private var title:Entity;
    private var titleSprite:Image;
    private var titleRotater:VarTween;
    private var menu:Array<Text>;
    private var background:ColoredRect;
    private var cursor:Entity;
    private var cursorPosition:Int;
    private var cursorBouncer:VarTween;
    private var curtain:Curtain;
    private var isStarting:Bool;
    private var sfx:Map<String, Sfx>;

    override public function begin() {
        addGraphic(new Image("graphics/mainmenu.png"));
        titleSprite = new Image("graphics/title.png");
        titleSprite.centerOrigin();
        titleSprite.angle = -6;
        title = new Entity(HXP.width / 2, 33, titleSprite);
        add(title);
        titleRotater = new VarTween(TweenType.PingPong);
        titleRotater.tween(titleSprite, "angle", 6, 3, Ease.sineInOut);
        addTween(titleRotater, true);

        background = new ColoredRect(0, 0, 0x000000);
        background.alpha = 0.75;
        addGraphic(background);

        curtain = new Curtain();
        add(curtain);
        curtain.fadeOut(0.5);

        isStarting = false;

        menu = new Array<Text>();
        menu.push(new Text(
            'Players: ${GameScene.numberOfPlayers}', { size: 16 }
        ));
        menu.push(new Text(
            'Match Point: ${GameScene.matchPoint}', { size: 16 }
        ));
        menu.push(new Text(
            'START MATCH', { size: 16 }
        ));
        var count = 0;
        for(menuItem in menu) {
            menuItem.x = 170;
            menuItem.y = 100 + menu[0].textHeight * count;
            if(menuItem.textWidth > background.width) {
                background.width = menuItem.textWidth + 15;
            }
            addGraphic(menuItem);
            count++;
        }
        background.x = menu[0].x;
        background.y = menu[0].y;
        background.height = menu.length * menu[0].textHeight;

        cursorPosition = 0;

        cursor = new Entity(
            menu[cursorPosition].x - 35,
            menu[cursorPosition].y,
            new Image("graphics/cursor.png")
        );
        cursor.layer = -1;
        add(cursor);

        cursorBouncer = new VarTween(TweenType.PingPong);
        cursorBouncer.tween(
            cursor, "x", cursor.x - 10, 0.5, Ease.circInOut
        );
        addTween(cursorBouncer, true);
        sfx = [
            "menuselect" => new Sfx("audio/menuselect.wav"),
            "menustart" => new Sfx("audio/menustart.wav")
        ];
    }

    override public function update() {
        var oldCursorPosition = cursorPosition;
        if(isStarting) {
            // Do nothing
        }
        else if(Main.inputPressed("up")) {
            cursorPosition -= 1;
        }
        else if(Main.inputPressed("down")) {
            cursorPosition += 1;
        }
        cursorPosition = Std.int(
            MathUtil.clamp(cursorPosition, 0, menu.length - 1)
        );
        if(cursorPosition != oldCursorPosition) {
            sfx["menuselect"].play();
            cursor.y = menu[cursorPosition].y;
        }
        if(isStarting) {
            // Do nothing
        }
        else if(cursorPosition == 0) {
            // Number of players
            var oldNumberOfPlayers = GameScene.numberOfPlayers;
            if(Main.inputPressed("jump")) {
                GameScene.numberOfPlayers += 1;
                if(
                    GameScene.numberOfPlayers
                    > GameScene.MAX_NUMBER_OF_PLAYERS
                ) {
                    GameScene.numberOfPlayers = 2;
                }
            }
            else if(Main.inputPressed("left")) {
                GameScene.numberOfPlayers -= 1;
            }
            else if(Main.inputPressed("right")) {
                GameScene.numberOfPlayers += 1;
            }
            GameScene.numberOfPlayers = Std.int(MathUtil.clamp(
                GameScene.numberOfPlayers, 2, GameScene.MAX_NUMBER_OF_PLAYERS
            ));
            if(GameScene.numberOfPlayers != oldNumberOfPlayers) {
                sfx["menuselect"].play();
                menu[0].text = 'Players: ${GameScene.numberOfPlayers}';
            }
        }
        else if(cursorPosition == 1) {
            // Match Point
            var oldMatchPoint = GameScene.matchPoint;
            if(Main.inputPressed("jump")) {
                GameScene.matchPoint += 1;
                if(
                    GameScene.matchPoint
                    > GameScene.MAX_MATCH_POINT
                ) {
                    GameScene.matchPoint = 1;
                }
            }
            else if(Main.inputPressed("left")) {
                GameScene.matchPoint -= 1;
            }
            else if(Main.inputPressed("right")) {
                GameScene.matchPoint += 1;
            }
            GameScene.matchPoint = Std.int(MathUtil.clamp(
                GameScene.matchPoint, 1, GameScene.MAX_MATCH_POINT
            ));
            if(GameScene.matchPoint != oldMatchPoint) {
                sfx["menuselect"].play();
                menu[1].text = 'Match Point: ${GameScene.matchPoint}';
            }
        }
        else if(cursorPosition == 2) {
            // Start game
            if(Main.inputPressed("jump")) {
                isStarting = true;
                sfx["menustart"].play();
                cursor.graphic = new Image("graphics/thumbsup.png");
                cursor.y -= 7;
                curtain.fadeIn(3);
                doSequence([
                    {
                        atTime: 3,
                        doThis: function() {
                            HXP.scene = new GameScene();
                        }
                    }
                ]);
            }
        }
        super.update();
    }

    private function doSequence(sequence:Array<SequenceStepForMenu>) {
        for(step in sequence) {
            var stepTimer = new Alarm(step.atTime);
            stepTimer.onComplete.bind(step.doThis);
            addTween(stepTimer, true);
        }
    }
}
