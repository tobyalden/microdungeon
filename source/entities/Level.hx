package entities;

import haxepunk.*;
import haxepunk.graphics.tile.*;
import haxepunk.masks.*;
import haxepunk.math.*;
import openfl.Assets;

class Level extends Entity
{
    public static inline var TILE_SIZE = 4;

    public var entities(default, null):Array<Entity>;
    public var playerStart(default, null):Vector2;
    private var walls:Grid;
    private var tiles:Tilemap;

    public function new(levelName:String) {
        super();
        type = "walls";

        loadLevel(levelName);

        tiles = new Tilemap(
            'graphics/tiles.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        tiles.loadFromString(walls.saveToString(',', '\n', '1', '0'));

        graphic = tiles;
        mask = walls;
    }

    private function loadLevel(levelName:String) {
        var xml = Xml.parse(Assets.getText('levels/${levelName}.oel'));
        var fastXml = new haxe.xml.Fast(xml.firstElement());
        var segmentWidth = Std.parseInt(fastXml.node.width.innerData);
        var segmentHeight = Std.parseInt(fastXml.node.height.innerData);
        walls = new Grid(segmentWidth, segmentHeight, TILE_SIZE, TILE_SIZE);
        for (r in fastXml.node.walls.nodes.rect) {
            walls.setRect(
                Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
            );
        }

        entities = new Array<Entity>();
        if(fastXml.hasNode.objects) {
            if(fastXml.node.objects.hasNode.player) {
                for(player in fastXml.node.objects.nodes.player) {
                    playerStart = new Vector2(
                        Std.parseInt(player.att.x),
                        Std.parseInt(player.att.y)
                    );
                }
            }
            if(fastXml.node.objects.hasNode.rena) {
                for(rena in fastXml.node.objects.nodes.rena) {
                    var rena = new Rena(
                        Std.parseInt(rena.att.x),
                        Std.parseInt(rena.att.y)
                    );
                    entities.push(rena);
                }
            }
            if(fastXml.node.objects.hasNode.sawblade) {
                for(sawblade in fastXml.node.objects.nodes.sawblade) {
                    var nodes = new Array<Vector2>();
                    nodes.push(new Vector2(
                        Std.parseInt(sawblade.att.x),
                        Std.parseInt(sawblade.att.y)
                    ));
                    for(n in sawblade.nodes.node) {
                        nodes.push(new Vector2(
                            Std.parseInt(n.att.x), Std.parseInt(n.att.y)
                        ));
                    }
                    nodes.push(new Vector2(
                        Std.parseInt(sawblade.att.x),
                        Std.parseInt(sawblade.att.y)
                    ));
                    var sawblade = new Sawblade(
                        Std.parseInt(sawblade.att.x),
                        Std.parseInt(sawblade.att.y),
                        Std.parseInt(sawblade.att.speed),
                        nodes
                    );
                    entities.push(sawblade);
                }
            }
        }
    }

    override public function update() {
        super.update();
    }
}

