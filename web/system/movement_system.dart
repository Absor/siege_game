part of siege_game;

class MovementSystem implements System {
  
  bool enabled;
  int priority;
  
  List<Entity> _movingEntities;
  
  MovementSystem() {
    _movingEntities = new List<Entity>();
  }
  
  void process(num timeDelta) {
    for (Entity movingEntity in _movingEntities) {
      VelocityComponent velocity = movingEntity.getComponent(VelocityComponent);
      WorldPositionComponent position = movingEntity.getComponent(WorldPositionComponent);
      position.oldX = position.x;
      position.oldY = position.y;
      position.x += velocity.xVelocity;
      position.y += velocity.yVelocity;
      velocity.xVelocity = 0;
      velocity.yVelocity = 0;
    }
  }
    
  void attachWorld(World world) {
  }
  
  void detachWorld() {
  }
  
  void entityActivation(Entity entity) {
    if (entity.hasComponent(VelocityComponent) && entity.hasComponent(WorldPositionComponent)) {
      _movingEntities.add(entity);
    }
  }
  
  void entityDeactivation(Entity entity) {
    _movingEntities.remove(entity);
  }
}