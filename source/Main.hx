import haxepunk.*;
import haxepunk.input.*;
import haxepunk.input.gamepads.*;
import haxepunk.math.*;
import haxepunk.utils.*;
import scenes.*;

class Main extends Engine
{
    public static var gamepad:Gamepad;
    public static var gamepad2:Gamepad;
    public static var gamepad3:Gamepad;

    private static var previousJumpHeld:Bool = false;
    private static var previousJumpHeld2:Bool = false;
    private static var previousJumpHeld3:Bool = false;
    private static var previousAttackHeld:Bool = false;
    private static var previousAttackHeld2:Bool = false;
    private static var previousAttackHeld3:Bool = false;
    private static var previousDodgeHeld:Bool = false;
    private static var previousDodgeHeld2:Bool = false;
    private static var previousDodgeHeld3:Bool = false;

    private static var p1PreviousAxis:Vector2 = new Vector2();

    static function main() {
        new Main();
    }

    override public function init() {
        Key.define("left", [Key.LEFT, Key.LEFT_SQUARE_BRACKET]);
        Key.define("right", [Key.RIGHT, Key.RIGHT_SQUARE_BRACKET]);
        Key.define("up", [Key.UP]);
        Key.define("down", [Key.DOWN]);
        Key.define("jump", [Key.Z, Key.SPACE]);
        Key.define("attack", [Key.X]);
        Key.define("dodge", [Key.C]);
        Key.define("start", [Key.ENTER]);

        Key.define("2P_left", [Key.A]);
        Key.define("2P_right", [Key.D]);
        Key.define("2P_up", [Key.W]);
        Key.define("2P_down", [Key.S]);
        Key.define("2P_jump", [Key.Q]);
        Key.define("2P_attack", [Key.E]);
        Key.define("2P_dodge", [Key.R]);

        Key.define("3P_left", [Key.J]);
        Key.define("3P_right", [Key.L]);
        Key.define("3P_up", [Key.I]);
        Key.define("3P_down", [Key.K]);
        Key.define("3P_jump", [Key.U]);
        Key.define("3P_attack", [Key.O]);
        Key.define("3P_dodge", [Key.P]);

        Key.define("debug", [Key.T]);

        gamepad = Gamepad.gamepad(0);
        gamepad2 = Gamepad.gamepad(1);
        gamepad3 = Gamepad.gamepad(2);
        Gamepad.onConnect.bind(function(newGamepad:Gamepad) {
            if(newGamepad.id == 0) {
                gamepad = newGamepad;
            }
            if(newGamepad.id == 1) {
                gamepad2 = newGamepad;
            }
            if(newGamepad.id == 2) {
                gamepad3 = newGamepad;
            }
        });

        HXP.scene = new MainMenu();
    }

    override public function update() {
        super.update();
        if(Input.pressed("debug")) {
            if(gamepad != null) {
                trace(gamepad.buttons);
                //for(i in 0...12) {
                    //trace('axis ${i}: ${gamepad.getAxis(i)}');
                //}
            }
        }
        if(gamepad != null) {
            previousJumpHeld = gamepad.check(XboxGamepad.A_BUTTON);
            previousAttackHeld = gamepad.check(XboxGamepad.X_BUTTON);
            previousDodgeHeld = gamepad.getAxis(5) >= 0.25;
            p1PreviousAxis.x = gamepad.getAxis(0);
            p1PreviousAxis.y =gamepad.getAxis(1);
        }
        if(gamepad2 != null) {
            previousJumpHeld2 = gamepad2.check(XboxGamepad.A_BUTTON);
            previousAttackHeld2 = gamepad2.check(XboxGamepad.X_BUTTON);
            previousDodgeHeld2 = gamepad2.getAxis(5) >= 0.25;
        }
        if(gamepad3 != null) {
            previousJumpHeld3 = gamepad3.check(XboxGamepad.A_BUTTON);
            previousAttackHeld3 = gamepad3.check(XboxGamepad.X_BUTTON);
            previousDodgeHeld3 = gamepad3.getAxis(5) >= 0.35;
        }
    }

    public static function inputPressed(inputName:String, playerNum:Int = 1) {
        var playerPrefix = [1 => "", 2 => "2P_", 3 => "3P_"][playerNum];
        var checkGamepad = [1 => gamepad, 2 => gamepad2, 3 => gamepad3][playerNum];
        if(checkGamepad == null || Input.pressed(playerPrefix + inputName)) {
            return Input.pressed(playerPrefix + inputName);
        }
        var previousJumpHeldToUse = [
            1 => previousJumpHeld,
            2 => previousJumpHeld2,
            3 => previousJumpHeld3
        ][playerNum];
        var previousAttackHeldToUse = [
            1 => previousAttackHeld,
            2 => previousAttackHeld2,
            3 => previousAttackHeld3
        ][playerNum];
        var previousDodgeHeldToUse = [
            1 => previousDodgeHeld,
            2 => previousDodgeHeld2,
            3 => previousDodgeHeld3
        ][playerNum];
        if(inputName == "jump") {
            if(
                !previousJumpHeldToUse
                && checkGamepad.check(XboxGamepad.A_BUTTON)
            ) {
                return true;
            }
        }
        if(inputName == "attack") {
            if(
                !previousAttackHeldToUse
                && checkGamepad.check(XboxGamepad.X_BUTTON)
            ) {
                return true;
            }
        }
        if(inputName == "dodge") {
            if(
                !previousDodgeHeldToUse
                && checkGamepad.getAxis(5) >= 0.25
            ) {
                return true;
            }
        }
        if(inputName == "start") {
            if(checkGamepad.pressed(6)) {
                return true;
            }
        }
        if(inputName == "left") {
            return (
                checkGamepad.getAxis(0) < -0.5
                && p1PreviousAxis.x > -0.5
                || checkGamepad.pressed(XboxGamepad.DPAD_LEFT)
            );
        }
        if(inputName == "right") {
            return (
                checkGamepad.getAxis(0) > 0.5
                && p1PreviousAxis.x < 0.5
                || checkGamepad.pressed(XboxGamepad.DPAD_RIGHT)
            );
        }
        if(inputName == "up") {
            return (
                checkGamepad.getAxis(1) < -0.5
                && p1PreviousAxis.y > -0.5
                || checkGamepad.pressed(XboxGamepad.DPAD_UP)
            );
        }
        if(inputName == "down") {
            return (
                checkGamepad.getAxis(1) > 0.5
                && p1PreviousAxis.y < 0.5
                || checkGamepad.pressed(XboxGamepad.DPAD_DOWN)
            );
        }
        return false;
    }

    public static function inputReleased(inputName:String, playerNum:Int = 1) {
        var playerPrefix = [1 => "", 2 => "2P_", 3 => "3P_"][playerNum];
        var checkGamepad = [1 => gamepad, 2 => gamepad2, 3 => gamepad3][playerNum];
        if(checkGamepad == null || Input.released(playerPrefix + inputName)) {
            return Input.released(playerPrefix + inputName);
        }
        var previousJumpHeldToUse = [
            1 => previousJumpHeld,
            2 => previousJumpHeld2,
            3 => previousJumpHeld3
        ][playerNum];
        var previousAttackHeldToUse = [
            1 => previousAttackHeld,
            2 => previousAttackHeld2,
            3 => previousAttackHeld3
        ][playerNum];
        var previousDodgeHeldToUse = [
            1 => previousDodgeHeld,
            2 => previousDodgeHeld2,
            3 => previousDodgeHeld3
        ][playerNum];
        if(inputName == "jump") {
            if(
                previousJumpHeldToUse
                && !checkGamepad.check(XboxGamepad.A_BUTTON)
            ) {
                return true;
            }
        }
        if(inputName == "attack") {
            if(
                previousAttackHeldToUse
                && !checkGamepad.check(XboxGamepad.X_BUTTON)
            ) {
                return true;
            }
        }
        if(inputName == "dodge") {
            if(
                previousDodgeHeldToUse
                && checkGamepad.getAxis(5) < 0.25
            ) {
                return true;
            }
        }
        return false;
    }

    public static function inputCheck(inputName:String, playerNum:Int = 1) {
        var playerPrefix = [1 => "", 2 => "2P_", 3 => "3P_"][playerNum];
        var checkGamepad = [1 => gamepad, 2 => gamepad2, 3 => gamepad3][playerNum];
        if(checkGamepad == null || Input.check(playerPrefix + inputName)) {
            if(inputName == "left" && Input.check(playerPrefix + "right")) {
                return false;
            }
            if(inputName == "right" && Input.check(playerPrefix + "left")) {
                return false;
            }
            return Input.check(playerPrefix + inputName);
        }
        if(inputName == "jump") {
            return checkGamepad.check(XboxGamepad.A_BUTTON);
        }
        if(inputName == "attack") {
            return checkGamepad.check(XboxGamepad.X_BUTTON);
        }
        if(inputName == "dodge") {
            return checkGamepad.getAxis(5) >= 0.25;
        }
        if(inputName == "left") {
            return (
                checkGamepad.getAxis(0) < -0.5
                || checkGamepad.check(XboxGamepad.DPAD_LEFT)
            );
        }
        if(inputName == "right") {
            return (
                checkGamepad.getAxis(0) > 0.5
                || checkGamepad.check(XboxGamepad.DPAD_RIGHT)
            );
        }
        if(inputName == "up") {
            return (
                checkGamepad.getAxis(1) < -0.5
                || checkGamepad.check(XboxGamepad.DPAD_UP)
            );
        }
        if(inputName == "down") {
            return (
                checkGamepad.getAxis(1) > 0.5
                || checkGamepad.check(XboxGamepad.DPAD_DOWN)
            );
        }
        return false;
    }
}
