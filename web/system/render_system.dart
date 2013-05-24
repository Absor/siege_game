part of siege_game;

class RenderSystem implements System {
  
  int priority;
  bool enabled;
  
  CanvasManager _cm;
  
  List<Entity> _background;
  List<Entity> _objects;
  
  Entity _centerPositionEntity;
  
  Rect _worldViewArea;
  
  RenderSystem(this._cm) {    
    _background = new List<Entity>();
    _objects = new List<Entity>();
  }
  
  void process(num timeDelta) {
    if (_centerPositionEntity == null) return;
    _cm.clearCanvas();
    _objects.sort((Entity entity1, Entity entity2) {
      WorldPositionComponent pos1 = entity1.getComponent(WorldPositionComponent);
      WorldPositionComponent pos2 = entity2.getComponent(WorldPositionComponent);
      return pos1.x + pos1.y - pos2.x - pos2.y;
    });
    
    _calculateWorldViewArea(_centerPositionEntity.getComponent(WorldPositionComponent));
    
    _renderEntities(_background);
    _renderEntities(_objects);
  }
  
  void _calculateWorldViewArea(WorldPositionComponent worldCenter) {
    _worldViewArea = new Rect(
        (worldCenter.x - worldCenter.y) * 32 - _cm.scaleWidth / 2,
        (worldCenter.x + worldCenter.y) * 16 - _cm.scaleHeight / 2,
        _cm.scaleWidth, _cm.scaleHeight);
  }
  
  void _renderEntities(List<Entity> entities) {
    num scaler = _cm.scaler;
    Rect canvasDrawArea = _cm.canvasDrawArea;
    for (Entity entity in entities) {
      WorldPositionComponent entityWorldPosition = entity.getComponent(WorldPositionComponent);
      RenderComponent rc = entity.getComponent(RenderComponent);
      num screenX = (entityWorldPosition.x - entityWorldPosition.y) * 32;
      num screenY = (entityWorldPosition.x + entityWorldPosition.y) * 16;
      Rect entityWorldImageArea = new Rect(screenX + rc.xOffset, screenY + rc.yOffset, rc.sourceWidth, rc.sourceHeight);
      Rect intersection = _worldViewArea.intersection(entityWorldImageArea);
      if (intersection != null) {
        // if top left corner is not inside draw area we need to correct
        num xChange = intersection.left - entityWorldImageArea.left;
        num yChange = intersection.top - entityWorldImageArea.top;
        _cm.context.drawImageScaledFromSource(
            // draw only intersection
            rc.source,
            rc.sourceX + xChange,
            rc.sourceY + yChange,
            intersection.width,
            intersection.height,
            // draw scaled to canvas
            (screenX + xChange - _worldViewArea.left + rc.xOffset) * scaler + canvasDrawArea.left,
            (screenY + yChange - _worldViewArea.top + rc.yOffset) * scaler + canvasDrawArea.top,
            (intersection.width) * scaler,
            (intersection.height) * scaler);
      }
    }
  }
  
  void attachWorld(World world) {
  }
  
  void detachWorld() {
  }
  
  void entityActivation(Entity entity) {
    if (entity.hasComponent(CameraCenteringComponent)) {
      _centerPositionEntity = entity;
    }
    if (entity.hasComponent(RenderComponent) && entity.hasComponent(WorldPositionComponent)) {
      if (entity.hasComponent(BackgroundComponent)) {
        _background.add(entity);
      } else {
        _objects.add(entity);
      }
    }
  }
  
  void entityDeactivation(Entity entity) {
    _background.remove(entity);
    _objects.remove(entity);
    if (entity == _centerPositionEntity) _centerPositionEntity = null;
  }
}