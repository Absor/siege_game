part of siege_game;

class AnimationSystem implements System {
  
  bool enabled;
  int priority;
  
  List<Entity> _animatedEntities;
  
  num _fastAnim;
  num _slowAnim;
  
  AnimationSystem() {
    _animatedEntities = new List<Entity>();
    _fastAnim = 0;
    _slowAnim = 0;
  }
  
  void process(num timeDelta) {
    _fastAnim += timeDelta;
    _slowAnim += timeDelta;
    while (_fastAnim > 0 || _slowAnim > 0) {
      for (Entity entity in _animatedEntities) {
        VelocityComponent velocity = entity.getComponent(VelocityComponent);
        RenderComponent rc = entity.getComponent(RenderComponent);
        SpritesheetAnimationComponent anim = entity.getComponent(SpritesheetAnimationComponent);
        if (velocity.xVelocity != 0 || velocity.yVelocity != 0) {
          rc.sourceY = _velocityToImageRow(velocity) * 128;
          if (_fastAnim > 0) _playWalk(rc);
        } else {
          if (_slowAnim > 0) _playStance(rc, anim);
        }
      }
      
      if (_fastAnim > 0) _fastAnim -= 100;
      if (_slowAnim > 0) _slowAnim -= 150;
    }
  }
  
  void _playWalk(RenderComponent rc) {
    if (rc.sourceX < 512 || rc.sourceX > 1536) {
      rc.sourceX = 384;
    }
    rc.sourceX = (rc.sourceX + 128 - 512) % 1024 + 512;
  }
  
  void _playStance(RenderComponent rc, SpritesheetAnimationComponent anim) {
    if (rc.sourceX > 384) {
      rc.sourceX = -128;
      anim.forward = true;
    }
    if (anim.forward) rc.sourceX += 128;
    else rc.sourceX -= 128;
    if (rc.sourceX >= 384) anim.forward = false;
    else if (rc.sourceX <= 0) anim.forward = true;
  }
  
  static final _imageRow = [[2,  3, 4],
                            [1, -1, 5],
                            [0,  7, 6]];
  
  int _velocityToImageRow(VelocityComponent velocity) {
    int x;
    int y;
    if (velocity.xVelocity < 0) x = 0;
    else if (velocity.xVelocity == 0) x = 1;
    else x = 2;
    if (velocity.yVelocity < 0) y = 0;
    else if (velocity.yVelocity == 0) y = 1;
    else y = 2;
    return _imageRow[y][x];
  }
  
  void attachWorld(World world) {
  }
  
  void detachWorld() {
  }
  
  void entityActivation(Entity entity) {
    if (entity.hasComponent(SpritesheetAnimationComponent) &&
        entity.hasComponent(VelocityComponent) &&
        entity.hasComponent(RenderComponent)) {
      _animatedEntities.add(entity);
    }
  }
  
  void entityDeactivation(Entity entity) {
    _animatedEntities.remove(entity);
  }
}