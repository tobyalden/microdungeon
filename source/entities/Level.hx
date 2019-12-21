package entities;

import haxepunk.*;
import haxepunk.graphics.*;
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
    private var background:Backdrop;

    public function new(levelName:String) {
        super();
        layer = 1;
        type = "walls";

        loadLevel(levelName);

        var tilePath = 'graphics/${levelName}_tiles.png';
        tiles = new Tilemap(
            tilePath,
            walls.width, walls.height,
            walls.tileWidth, walls.tileHeight
        );
        var tileImage = new Image(tilePath);
        for(tileX in 0...tiles.columns) {
            for(tileY in 0...tiles.rows) {
                if(!walls.getTile(tileX, tileY)) {
                    tiles.clearTile(tileX, tileY);
                }
                else {
                    var tile = Std.int(
                        tileX % (tileImage.width / TILE_SIZE)
                        + tileY % (tileImage.height / TILE_SIZE)
                        * (tileImage.width / TILE_SIZE)
                    );
                    tiles.setTile(tileX, tileY, tile);
                }
            }
        }
        addGraphic(tiles);
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
            if(fastXml.node.objects.hasNode.bosstrigger) {
                for(bossTrigger in fastXml.node.objects.nodes.bosstrigger) {
                    var bossTrigger = new BossTrigger(
                        Std.parseInt(bossTrigger.att.x),
                        Std.parseInt(bossTrigger.att.y),
                        Std.parseInt(bossTrigger.att.width),
                        Std.parseInt(bossTrigger.att.height),
                        bossTrigger.att.bossname
                    );
                    entities.push(bossTrigger);
                }
            }
            if(fastXml.node.objects.hasNode.lock) {
                for(lock in fastXml.node.objects.nodes.lock) {
                    var lock = new Lock(
                        Std.parseInt(lock.att.x),
                        Std.parseInt(lock.att.y),
                        Std.parseInt(lock.att.width),
                        Std.parseInt(lock.att.height),
                        lock.att.bossname
                    );
                    entities.push(lock);
                }
            }
            if(fastXml.node.objects.hasNode.savepoint) {
                for(savePoint in fastXml.node.objects.nodes.savepoint) {
                    var savePoint = new SavePoint(
                        Std.parseInt(savePoint.att.x),
                        Std.parseInt(savePoint.att.y),
                        savePoint.att.bossname
                    );
                    entities.push(savePoint);
                }
            }
            if(fastXml.node.objects.hasNode.decoration) {
                for(decoration in fastXml.node.objects.nodes.decoration) {
                    var decoration = new Decoration(
                        Std.parseInt(decoration.att.x),
                        Std.parseInt(decoration.att.y),
                        decoration.att.fileName,
                        Std.parseInt(decoration.att.layer)
                    );
                    entities.push(decoration);
                }
            }
            if(fastXml.node.objects.hasNode.mion) {
                for(mion in fastXml.node.objects.nodes.mion) {
                    var nodes = new Array<Vector2>();
                    nodes.push(new Vector2(
                        Std.parseInt(mion.att.x),
                        Std.parseInt(mion.att.y)
                    ));
                    for(n in mion.nodes.node) {
                        nodes.push(new Vector2(
                            Std.parseInt(n.att.x), Std.parseInt(n.att.y)
                        ));
                    }
                    nodes.push(new Vector2(
                        Std.parseInt(mion.att.x),
                        Std.parseInt(mion.att.y)
                    ));
                    var mion = new Mion(
                        Std.parseInt(mion.att.x),
                        Std.parseInt(mion.att.y),
                        nodes
                    );
                    entities.push(mion);
                }
            }
            if(fastXml.node.objects.hasNode.satoko) {
                for(satoko in fastXml.node.objects.nodes.satoko) {
                    var nodes = new Array<Vector2>();
                    nodes.push(new Vector2(
                        Std.parseInt(satoko.att.x),
                        Std.parseInt(satoko.att.y)
                    ));
                    for(n in satoko.nodes.node) {
                        nodes.push(new Vector2(
                            Std.parseInt(n.att.x), Std.parseInt(n.att.y)
                        ));
                    }
                    nodes.push(new Vector2(
                        Std.parseInt(satoko.att.x),
                        Std.parseInt(satoko.att.y)
                    ));
                    var satoko = new Satoko(
                        Std.parseInt(satoko.att.x),
                        Std.parseInt(satoko.att.y),
                        nodes
                    );
                    entities.push(satoko);
                }
            }
            if(fastXml.node.objects.hasNode.rika) {
                for(rika in fastXml.node.objects.nodes.rika) {
                    var nodes = new Array<Vector2>();
                    nodes.push(new Vector2(
                        Std.parseInt(rika.att.x),
                        Std.parseInt(rika.att.y)
                    ));
                    for(n in rika.nodes.node) {
                        nodes.push(new Vector2(
                            Std.parseInt(n.att.x), Std.parseInt(n.att.y)
                        ));
                    }
                    nodes.push(new Vector2(
                        Std.parseInt(rika.att.x),
                        Std.parseInt(rika.att.y)
                    ));
                    var rika = new Rika(
                        Std.parseInt(rika.att.x),
                        Std.parseInt(rika.att.y),
                        nodes
                    );
                    entities.push(rika);
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
            if(fastXml.node.objects.hasNode.elevator) {
                for(elevator in fastXml.node.objects.nodes.elevator) {
                    var nodes = new Array<Vector2>();
                    nodes.push(new Vector2(
                        Std.parseInt(elevator.att.x),
                        Std.parseInt(elevator.att.y)
                    ));
                    for(n in elevator.nodes.node) {
                        nodes.push(new Vector2(
                            Std.parseInt(n.att.x), Std.parseInt(n.att.y)
                        ));
                    }
                    var elevator = new Elevator(
                        Std.parseInt(elevator.att.x),
                        Std.parseInt(elevator.att.y),
                        nodes
                    );
                    entities.push(elevator);
                }
            }
        }
    }

    override public function update() {
        super.update();
    }
}

