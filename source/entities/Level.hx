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
    private var walls:Grid;
    private var tiles:Tilemap;

    public function new(levelName:String) {
        super();
        type = "walls";

        loadLevel(levelName);

        tiles = new Tilemap(
            'graphics/stone.png',
            walls.width, walls.height, walls.tileWidth, walls.tileHeight
        );
        tiles.loadFromString(walls.saveToString(',', '\n', '1', '0'));
        for(tileX in 0...tiles.columns) {
            for(tileY in 0...tiles.rows) {
                if(tiles.getTile(tileX, tileY) == 1) {
                    tiles.setTile(tileX, tileY, Random.randInt(3000) + 1);
                }
            }
        }
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
        for (r in fastXml.node.optionalWalls.nodes.rect) {
            if(Math.random() > 0.5) {
                walls.setRect(
                    Std.int(Std.parseInt(r.att.x) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.y) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.w) / TILE_SIZE),
                    Std.int(Std.parseInt(r.att.h) / TILE_SIZE)
                );
            }
        }

        entities = new Array<Entity>();
        if(fastXml.hasNode.objects) {
            var playerNumbers = [1, 2, 3];
            //HXP.shuffle(playerNumbers);
            for (e in fastXml.node.objects.nodes.player1) {
                entities.push(new Player(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y), playerNumbers[0]
                ));
            }
            for (e in fastXml.node.objects.nodes.player2) {
                entities.push(new Player(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y), playerNumbers[1]
                ));
            }
            for (e in fastXml.node.objects.nodes.player3) {
                entities.push(new Player(
                    Std.parseInt(e.att.x), Std.parseInt(e.att.y), playerNumbers[2]
                ));
            }
        }
    }

    override public function update() {
        super.update();
    }
}

