part of siege_game;

class EntityCreator {
  
  World _world;
  int id;
  
  EntityCreator(this._world) {
    id = 0;
  }
  
  Entity newEntity() {
    return _world.createEntity(id++);
  }
}