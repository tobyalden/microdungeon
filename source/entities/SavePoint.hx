package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.graphics.Spritemap;
import haxepunk.graphics.text.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.GameScene;

class SavePoint extends MiniEntity
{
    public var bossName(default, null):String;
    private var sprite:Spritemap;
    private var textDisplay:Text;
    private var textRotater:VarTween;
    private var textFader:VarTween;
    private var sfx:Map<String, Sfx>;

    public function new(x:Float, y:Float, bossName:String) {
        super(x, y);
        this.bossName = bossName;
        layer = -1;
        type = "savepoint";
        sprite = new Spritemap("graphics/savepoint.png", 16, 32);
        sprite.add("idle", [0, 4, 8, 12, 8, 4], 12);
        sprite.add("flash", [1, 5, 9], 18, false);
        sprite.play("idle");
        sprite.onAnimationComplete.bind(function(_:Animation) {
            sprite.play("idle");
        });
        setHitbox(16, 32);

        textDisplay = new Text("GAME SAVED", { size: 12 });
        textDisplay.centerOrigin();
        textDisplay.originX += width / 2;
        textDisplay.x += 9;
        textDisplay.y -= 16;
        textDisplay.angle = -6;
        textDisplay.font = "font/action.ttf";
        textDisplay.alpha = 0;
        addGraphic(sprite);
        addGraphic(textDisplay);

        textRotater = new VarTween(TweenType.PingPong);
        textRotater.tween(textDisplay, "angle", 6, 0.5, Ease.sineInOut);
        addTween(textRotater, true);

        textFader = new VarTween();
        addTween(textFader);

        sfx = [
            "save" => new Sfx("audio/save.wav")
        ];
    }

    override public function update() {
        if(bossName != "") {
            var boss = scene.getInstance(bossName);
            visible = boss == null;
            collidable = boss == null;
        }
        super.update();
    }

    public function flash() {
        sprite.play("flash", true);
        textDisplay.alpha = 1;
        textFader.tween(textDisplay, "alpha", 0, 1.5, Ease.sineOut);
        textFader.start();
        sfx["save"].play();
    }
}
