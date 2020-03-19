package scenes;

import haxepunk.*;
import haxepunk.graphics.*;
import haxepunk.input.*;
import haxepunk.math.*;
import haxepunk.Tween;
import haxepunk.tweens.motion.*;
import haxepunk.tweens.misc.*;
import haxepunk.utils.*;
import entities.*;

typedef EndingSequenceStep = {
  var atTime:Float;
  var doThis:Void->Void;
}

class Ending extends Scene
{
    public static inline var NUMBER_OF_SLIDES = 10;
    public static inline var TIME_BETWEEN_SLIDES = 12;

    private var slides:Array<Image>;
    private var slideIndex:Int;
    private var slideAdvancer:Alarm;
    private var sfx:Map<String, Sfx>;
    private var curtain:Curtain;

    override public function begin() {
        curtain = new Curtain();
        add(curtain);
        curtain.fadeOut(0.5);

        slides = new Array<Image>();
        for(i in 1...(NUMBER_OF_SLIDES + 1)) {
            slides.push(new Image('graphics/ending${i}.png'));
        }
        for(slide in slides) {
            addGraphic(slide);
            slide.alpha = 0;
        }

        slideIndex = 0;

        slideAdvancer = new Alarm(TIME_BETWEEN_SLIDES, TweenType.Looping);
        slideAdvancer.onComplete.bind(function() {
            if(slideIndex < slides.length - 1) {
                slideIndex++;
            }
            else {
                curtain.fadeIn(TIME_BETWEEN_SLIDES);
                slideAdvancer.active = false;
                doSequence([
                    {
                        atTime: (TIME_BETWEEN_SLIDES + 3),
                        doThis: function() {
                            HXP.scene = new MainMenu();
                        }
                    }
                ]);
            }
        });
        addTween(slideAdvancer, true);

        sfx = [
            "ending" => new Sfx("audio/ending.ogg")
        ];
        sfx["ending"].play();
    }

    override public function update() {
        if(slideAdvancer.active) {
            slides[slideIndex].alpha = slideAdvancer.percent;
        }
        super.update();
    }

    private function doSequence(sequence:Array<EndingSequenceStep>) {
        for(step in sequence) {
            var stepTimer = new Alarm(step.atTime);
            stepTimer.onComplete.bind(step.doThis);
            addTween(stepTimer, true);
        }
    }
}
