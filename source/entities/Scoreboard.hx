package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import scenes.*;

class Scoreboard extends MiniEntity
{
    private var victoriesByPlayer:Map<Int, Array<Spritemap>>;
    private var background:ColoredRect;

    public function new() {
        super(0, 0);
        layer = -10;
        victoriesByPlayer = new Map<Int, Array<Spritemap>>();
        var allSprites = new Graphiclist([]);

        background = new ColoredRect(0, 0, 0x000000);
        background.alpha = 0.5;
        allSprites.add(background);

        for(playerNumber in 0...GameScene.numberOfPlayers) {
            var victories = new Array<Spritemap>();
            for(i in 0...GameScene.matchPoint) {
                var victory = new Spritemap("graphics/checkbox.png", 15, 15);
                victory.add("unchecked", [0]);
                victory.add("checked", [1]);
                victory.add("victorychecked", [2, 3], 3);
                victory.play("unchecked");
                victory.x = i * 20;
                victory.y = playerNumber * 20;
                victories.push(victory);
            }
            victoriesByPlayer[playerNumber] = victories;
            var playerIcon = new Image(
                'graphics/player${playerNumber + 1}icon.png'
            );
            playerIcon.x = -13;
            playerIcon.y = playerNumber * 20 + 2;
            allSprites.add(playerIcon);
        }

        background.x = -18;
        background.y = -10;
        background.width = GameScene.matchPoint * 20 + 20;
        background.height = GameScene.numberOfPlayers * 20 + 15;

        x = Math.round(HXP.width / 2 - background.width / 2) + 20;
        y = Math.round(HXP.height / 2 - background.height / 2) + 10;

        for(victories in victoriesByPlayer) {
            for(victory in victories) {
                allSprites.add(victory);
            }
        }
        graphic = allSprites;
    }

    override public function update() {
        for(playerNumber in 0...GameScene.numberOfPlayers) {
            for(i in 0...GameScene.matchPoint) {
                if(i < GameScene.victoriesByPlayer[playerNumber + 1]) {
                    var victory = victoriesByPlayer[playerNumber][i];
                    if(i == GameScene.matchPoint - 1) {
                        victory.play("victorychecked");
                    }
                    else {
                        victory.play("checked");
                    }
                }
                else {
                    victoriesByPlayer[playerNumber][i].play("unchecked");
                }
            }
        }
        super.update();
    }
}

