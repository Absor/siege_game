part of siege_game;

class AssetLoader {
  
  World _world;
  EntityCreator _ec;
  
  Entity _player;
  
  AssetLoader(this._world, this._ec) {
    _createPlayer();
    _loadMap("assets/maps/world.json");
    
    _test();
  }
  
  void _test() {
    Entity entity = _ec.newEntity();
    WorldPositionComponent position = new WorldPositionComponent();
    position.x = -1;
    position.y = -1;
    entity.addComponent(position);
    RenderComponent rc = new RenderComponent();
    rc.source = new CanvasElement(width: 2, height: 2);
    rc.source.context2D.fillStyle = "green";
    rc.source.context2D.fillRect(0, 0, 2, 2);
    rc.sourceHeight = 2;
    rc.sourceWidth = 2;
    rc.sourceX = 0;
    rc.sourceY = 0;
    rc.xOffset = 0;
    rc.yOffset = 0;
    entity.addComponent(rc);
    entity.addComponent(new TestComponent());
    _world.activateEntity(entity.id);
  }
  
  void _createPlayer() {
    _player = _ec.newEntity();
    _player.addComponent(new CameraCenteringComponent());
    _player.addComponent(new InputComponent());
    VelocityComponent velocity = new VelocityComponent();
    velocity.baseVelocity = 2/1000;
    velocity.xVelocity = 0;
    velocity.yVelocity = 0;
    _player.addComponent(velocity);
    RenderComponent rc = new RenderComponent();
    rc.source = new ImageElement(src:"assets/skeleton.png");
    rc.sourceHeight = 128;
    rc.sourceWidth = 128;
    rc.sourceX = 0;
    rc.sourceY = 768;
    rc.xOffset = -64;
    rc.yOffset = -96;
    _player.addComponent(rc);
    WorldPositionComponent position = new WorldPositionComponent();
    position.x = 0;
    position.y = 0;
    _player.addComponent(position);
    SpritesheetAnimationComponent anim = new SpritesheetAnimationComponent();
    anim.forward = true;
    _player.addComponent(anim);
    CollisionComponent collision = new CollisionComponent();
    collision.size = 0.2;
    _player.addComponent(collision);
    _world.activateEntity(_player.id);
  }
  
  void _loadMap(String url) {
    HttpRequest.getString(url)
    .then((e) => parse(e))
    .then(_loadImages)
    .then(_parseLayers)
    .then((List<Entity> mapEntities) {
      for (Entity entity in mapEntities) {
        _world.activateEntity(entity.id);
      }
    });
  }
  
  Future _loadImages(var mapData) {
    var completer = new Completer();
    List futures = new List();
    for (var tileSet in mapData["tilesets"]) {
      tileSet["image"] = new ImageElement(src:"assets/maps/" + tileSet["image"]);
      futures.add(tileSet["image"].onLoad.first);
    }
    Future.wait(futures).then((list) => completer.complete(mapData));
    return completer.future;
  }
  
  List<Entity> _parseLayers(var mapData) {
    List<Entity> mapEntities = new List<Entity>();
    for (var layer in mapData["layers"]) {
      if (layer["type"] != "tilelayer") continue;
      var data = layer["data"];
      for (int i = 0; i < data.length; i++) {
        if (data[i] == 0) continue;
        Entity entity = _ec.newEntity();
        WorldPositionComponent position = new WorldPositionComponent();
        position.x = i % layer["width"];
        position.y = (i / layer["width"]).floor();
        entity.addComponent(position);
        entity.addComponent(_getRenderComponent(mapData, data[i]));
        if (layer["name"] == "background") {
          entity.addComponent(new BackgroundComponent());
        } else if (layer["name"] == "collision") {
          CollisionComponent collision = new CollisionComponent();
          collision.size = 0.5;
          entity.addComponent(collision);
          entity.removeComponent(RenderComponent);
        }
        mapEntities.add(entity);
      }
    }
    return mapEntities;
  }
  
  RenderComponent _getRenderComponent(var mapData, int tileId) {
    var tileSetData = mapData["tilesets"];
    for (int i = tileSetData.length - 1; i >= 0; i--) {
      var tileSet = tileSetData[i];
      if (tileSet["firstgid"] <= tileId) {
        int imageId = tileId - tileSet["firstgid"];
        RenderComponent rc = new RenderComponent();
        rc.source= tileSet["image"];
        rc.sourceHeight = tileSet["tileheight"];
        rc.sourceWidth = tileSet["tilewidth"];
        rc.sourceX = (rc.sourceWidth * imageId) % tileSet["imagewidth"];
        rc.sourceY = ((rc.sourceWidth * imageId) / tileSet["imagewidth"]).floor() * rc.sourceHeight;
        rc.xOffset = mapData["tilewidth"] / 2 - rc.sourceWidth;
        rc.yOffset = mapData["tileheight"] / 2 - rc.sourceHeight;
        if (tileSet["tileoffset"] != null) {
          // TODO plus or minus?
          rc.xOffset += tileSet["tileoffset"]["x"];
          rc.yOffset += tileSet["tileoffset"]["y"];
        }
        return rc;
      }
    }
  }
}