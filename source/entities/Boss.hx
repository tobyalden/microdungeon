package entities;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import scenes.*;

class Boss extends MiniEntity
{
    public var health(default, null):Int;
    public var sfx(default, null):Map<String, Sfx>;
    public var startingHealth(default, null):Int;
    private var startPosition:Vector2;

    public function new(startX:Float, startY:Float) {
        super(startX, startY);
        type = "boss";
        startPosition = new Vector2(startX, startY);
        sfx = [
            "bossdeath" => new Sfx("audio/bossdeath.wav"),
            "klaxon" => new Sfx("audio/klaxon.wav")
        ];
        active = false;
    }

    public function takeHit() {
        if(!active) {
            return;
        }
        if(Input.check("cheat")) {
            health -= 1000;
        }
        else {
            health -= 1;
        }
        if(health <= startingHealth / 4) {
            if(!sfx["klaxon"].playing) {
                sfx["klaxon"].loop();
            }
        }
        if(health <= 0) {
            die();
            sfx["klaxon"].stop();
            sfx["music"].stop();
        }
    }

    override public function update() {
        if(!sfx.exists("music")) {
            sfx["music"] = new Sfx('audio/${name}_music.ogg');
        }
        var player = cast(scene.getInstance("player"), Player);
        if(active && !sfx["music"].playing && !player.isDead) {
            sfx["music"].loop();
        }
        if(sfx["klaxon"].playing) {
            graphic.x = Math.random() * 3;
            graphic.y = Math.random() * 3;
        }
        super.update();
    }

    public function die() {
        sfx["bossdeath"].play();
        explode();
        if(GameScene.defeatedBosses.indexOf(name) == -1) {
            GameScene.defeatedBosses.push(name);
        }
        scene.remove(this);
    }

    public function getSpreadAngles(numAngles:Int, maxSpread:Float) {
        var spreadAngles = new Array<Float>();
        var startAngle = -maxSpread / 2;
        var angleIncrement = maxSpread / (numAngles - 1);
        for(i in 0...numAngles) {
            spreadAngles.push(startAngle + angleIncrement * i);
        }
        return spreadAngles;
    }

    public function getSprayAngles(numAngles:Int, maxSpread:Float) {
        var sprayAngles = new Array<Float>();
        for(i in 0...numAngles) {
            sprayAngles.push(-maxSpread / 2 + Random.random * maxSpread);
        }
        return sprayAngles;
    }

    public function getAngleTowardsPlayer() {
        var player = scene.getInstance("player");
        return (
            Math.atan2(
                player.centerY - centerY,
                player.centerX - centerX
            )
        );
    }
}
