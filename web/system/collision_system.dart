part of siege_game;

class CollisionSystem extends System {
  
  bool enabled;
  int priority;
  
  List<Entity> _colliders;
  
  CollisionSystem() {
    _colliders = new List<Entity>();
  }
  
  void process(num timeDelta) {
    for (Entity collider1 in _colliders) {
      CollisionComponent collision1 = collider1.getComponent(CollisionComponent);
      WorldPositionComponent position1 = collider1.getComponent(WorldPositionComponent);
      bool collision = false;
      for (Entity collider2 in _colliders) {
        if (collider1 == collider2) continue;
        WorldPositionComponent position2 = collider2.getComponent(WorldPositionComponent);
        CollisionComponent collision2 = collider2.getComponent(CollisionComponent);
        num minDistance = (collision1.size + collision2.size);
        if(_euclideanDistance(position1.x, position1.y, position2.x, position2.y) < minDistance) {
          collision = true;
          break;
        }
      }
      if (collision) {
        position1.x = position1.oldX;
        position1.y = position1.oldY;
      }
    }
  }
  
  num _euclideanDistance(num x1, num y1, num x2, num y2) {
    return sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
  }
    
  void attachWorld(World world) {
  }
  
  void detachWorld() {
  }
  
  void entityActivation(Entity entity) {
    if (entity.hasComponent(WorldPositionComponent) && entity.hasComponent(CollisionComponent)) {
      _colliders.add(entity);
    }
  }
  
  void entityDeactivation(Entity entity) {
    _colliders.remove(entity);
  }
}