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
    private var cursorSprite:Spritemap;
    private var cursorPositionY:Int;
    private var cursorPositionX:Int;
    private var cursorBouncer:VarTween;
    private var curtain:Curtain;
    private var isStarting:Bool;
    private var isConfirmingNewGame:Bool;
    private var sfx:Map<String, Sfx>;

    override public function begin() {
        addGraphic(new Image("graphics/mainmenu.png"));
        titleSprite = new Image("graphics/title.png");
        titleSprite.centerOrigin();
        titleSprite.angle = -6;
        title = new Entity(HXP.width / 2, 33, titleSprite);
        add(title);
        titleRotater = new VarTween(TweenType.PingPong);
        titleRotater.tween(titleSprite, "angle", 6, 1.5, Ease.sineInOut);
        addTween(titleRotater, true);

        background = new ColoredRect(0, 0, 0x000000);
        background.alpha = 0.75;
        addGraphic(background);

        curtain = new Curtain();
        add(curtain);
        curtain.fadeOut(0.5);

        isStarting = false;
        isConfirmingNewGame = false;

        menu = new Array<Text>();
        menu.push(new Text(
            'New Game', { size: 16 }
        ));
        menu.push(new Text(
            'Continue', { size: 16 }
        ));
        var count = 0;
        for(menuItem in menu) {
            menuItem.font = "font/action.ttf";
            menuItem.x = 70;
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

        cursorPositionY = 0;
        cursorPositionX = 0;

        cursorSprite = new Spritemap("graphics/cursor.png", 254, 155);
        cursorSprite.add("idle", [0]);
        cursorSprite.add("select", [1]);
        cursorSprite.scale = 0.25;
        cursor = new Entity(
            menu[cursorPositionY].x - 55,
            menu[cursorPositionY].y,
            cursorSprite
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
            "synthsting1" => new Sfx("audio/synthsting1.wav"),
            "synthsting2" => new Sfx("audio/synthsting2.wav"),
            "menuback" => new Sfx("audio/menuback.wav")
        ];
    }

    override public function update() {
        var oldCursorPositionY = cursorPositionY;
        var oldCursorPositionX = cursorPositionX;
        if(isStarting) {
            // Do nothing
        }
        else if(isConfirmingNewGame) {
            if(Input.pressed("left")) {
                cursorPositionX -= 1;
            }
            else if(Input.pressed("right")) {
                cursorPositionX += 1;
            }
        }
        else {
            if(Input.pressed("up")) {
                cursorPositionY -= 1;
            }
            else if(Input.pressed("down")) {
                cursorPositionY += 1;
            }
        }
        cursorPositionY = Std.int(
            MathUtil.clamp(cursorPositionY, 0, menu.length - 1)
        );
        cursorPositionX = Std.int(
            MathUtil.clamp(cursorPositionX, 0, 1)
        );
        cursor.y = menu[cursorPositionY].y;
        if(
            cursorPositionY != oldCursorPositionY
        ) {
            sfx["menuselect"].play();
        }
        else if(cursorPositionX != oldCursorPositionX) {
            if(cursorPositionX == 1) {
                cursor.graphic.x += 44;
            }
            else {
                cursor.graphic.x -= 44;
            }
            sfx["menuselect"].play();
        }

        if(isStarting) {
            // Do nothing
        }
        else if(cursorPositionY == 0) {
            // New Game
            if(Input.pressed("jump")) {
                sfx["menuselect"].play();
                isConfirmingNewGame = true;
                menu[0].text = "W..WEALLY?";
                menu[0].color = 0xFF0000;
                menu[1].text = "NAW  YEAH";
                cursorPositionY = 1;
            }
        }
        else if(cursorPositionY == 1) {
            if(isConfirmingNewGame) {
                // New Game confirmation
                if(Input.pressed("jump")) {
                    if(cursorPositionX == 0) {
                        // No
                        isConfirmingNewGame = false;
                        menu[0].text = "NEW GAME";
                        menu[0].color = 0xFFFFFF;
                        menu[1].text = "CONTINUE";
                        cursorPositionY = 0;
                        sfx["menuback"].play();
                    }
                    else {
                        // Yes
                        startGame();
                        sfx["synthsting1"].play();
                    }
                }
            }
            else {
                // Continue
                if(Input.pressed("jump")) {
                    startGame();
                    sfx["synthsting2"].play();
                }
            }
        }
        super.update();
    }
    
    private function startGame() {
        isStarting = true;
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

    private function doSequence(sequence:Array<SequenceStepForMenu>) {
        for(step in sequence) {
            var stepTimer = new Alarm(step.atTime);
            stepTimer.onComplete.bind(step.doThis);
            addTween(stepTimer, true);
        }
    }
}