part of siege_game;

class InputSystem implements System {
  
  bool enabled;
  int priority;
  
  CanvasManager _cm;
  
  Map<String, bool> _keys;
  Map<int, String> _mappings;
  
  List<Entity> _inputEntities;
  
  Entity _testEntity;
  WorldPositionComponent _centerPosition;
  
  InputSystem(this._cm) {
    _setupMappings();
    _keys = new HashMap<String, bool>();
    window.onKeyDown.listen(_keydown);
    window.onKeyUp.listen(_keyup);
    
    CanvasElement canvas = query("#siege_game_canvas");
    canvas.onMouseMove.listen(_mouseMove);
    canvas.onMouseDown.listen(_mouseDown);
    canvas.onMouseUp.listen(_mouseUp);
    // mouse 2 menu
    canvas.onContextMenu.listen((e) => e.preventDefault());
    
    _inputEntities = new List<Entity>();
  }
  
  void _setupMappings() {
    _mappings = new HashMap<int, String>();
    _mappings[65] = "left";
    _mappings[87] = "up";
    _mappings[68] = "right";
    _mappings[83] = "down";
    
    _mappings[37] = "left";
    _mappings[38] = "up";
    _mappings[39] = "right";
    _mappings[40] = "down";
  }
  
  void _keydown(KeyboardEvent event) {
    event.preventDefault();
    String key = _translateKeyCode(event.keyCode);
    if (key != null) _keys[key] = true;
  }
  
  void _keyup(KeyboardEvent event) {
    event.preventDefault();
    String key = _translateKeyCode(event.keyCode);
    if (key != null) _keys[key] = false;
  }
  
  void _mouseDown(MouseEvent event) {
    event.preventDefault();
    print(event.button);
  }
  
  void _mouseUp(MouseEvent event) {
    event.preventDefault();
  }
  
  // http://gamedev.tutsplus.com/tutorials/implementation/cheap-and-easy-isometric-levels/
  void _mouseMove(MouseEvent event) {
    event.preventDefault();
    WorldPositionComponent position = _testEntity.getComponent(WorldPositionComponent);
    Point worldPoint = _cm.translateToWorldCoordinates(_centerPosition, event.layerX, event.layerY);
    position.x = worldPoint.x;
    position.y = worldPoint.y;
  }
  
  String _translateKeyCode(int keyCode) => _mappings[keyCode];
  
  void process(num timeDelta) {
    int x = 0;
    int y = 0;
    if (_keys["left"] != null && _keys["left"]) x--;
    if (_keys["right"] != null && _keys["right"]) x++;
    if (_keys["down"] != null && _keys["down"]) y++;
    if (_keys["up"] != null && _keys["up"]) y--;
    
    for (Entity entity in _inputEntities) {
      VelocityComponent velocity = entity.getComponent(VelocityComponent);
      num screenX = velocity.baseVelocity * timeDelta * x;
      num screenY = velocity.baseVelocity * timeDelta * y;
      velocity.xVelocity += screenY + screenX;
      velocity.yVelocity += screenY - screenX;
    }
  }
  
  void attachWorld(World world) {
  }
  
  void detachWorld() {
  }
  
  void entityActivation(Entity entity) {
    if (entity.hasComponent(InputComponent) && entity.hasComponent(VelocityComponent)) {
      _inputEntities.add(entity);
    }
    if (entity.hasComponent(CameraCenteringComponent)) {
      _centerPosition = entity.getComponent(WorldPositionComponent);
    }
    if (entity.hasComponent(TestComponent)) {
      _testEntity = entity;
    }
  }
  
  void entityDeactivation(Entity entity) {
  }
}