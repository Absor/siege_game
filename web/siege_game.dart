library siege_game;

import 'dart:html';
import 'dart:json';
import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:siege_engine/siege_engine.dart';

part 'component/world_position_component.dart';
part 'component/render_component.dart';
part 'component/background_component.dart';
part 'component/collision_component.dart';
part 'component/camera_centering_component.dart';
part 'component/input_component.dart';
part 'component/velocity_component.dart';
part 'component/spritesheet_animation_component.dart';
part 'component/test_component.dart';
part 'system/render_system.dart';
part 'system/input_system.dart';
part 'system/movement_system.dart';
part 'system/animation_system.dart';
part 'system/collision_system.dart';
part 'util/asset_loader.dart';
part 'util/entity_creator.dart';
part 'util/canvas_manager.dart';

void main() {
  GameRunner gr = new GameRunner();
  gr.run(0);
}

class GameRunner {
  
  World _world;
  num _lastTickTime;
  
  GameRunner() {
    _world = new World();
    _lastTickTime = 0;

    CanvasManager cm = new CanvasManager();
    InputSystem inputSystem = new InputSystem(cm);
    MovementSystem movementSystem = new MovementSystem();
    AnimationSystem animationSystem = new AnimationSystem();
    RenderSystem renderSystem = new RenderSystem(cm);
    CollisionSystem collisionSystem = new CollisionSystem();
    
    inputSystem.enabled = true;
    movementSystem.enabled = true;
    animationSystem.enabled = true;
    renderSystem.enabled = true;
    collisionSystem.enabled = true;
    
    inputSystem.priority = 0;
    animationSystem.priority = 5;
    movementSystem.priority = 10;
    collisionSystem.priority = 15;
    renderSystem.priority = 20;
    
    _world.addSystem(inputSystem);
    _world.addSystem(movementSystem);
    _world.addSystem(animationSystem);
    _world.addSystem(collisionSystem);
    _world.addSystem(renderSystem);
    
    EntityCreator ec = new EntityCreator(_world);
    new AssetLoader(_world, ec);
  }
  
  void run(num time) {
    _world.process(time - _lastTickTime);
    _lastTickTime = time;
    window.requestAnimationFrame(run);
  }
}