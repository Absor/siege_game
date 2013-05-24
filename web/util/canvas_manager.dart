part of siege_game;

class CanvasManager {
  
  CanvasElement _canvas;
  CanvasRenderingContext2D _context;
  Rect _canvasDrawArea;
  num _scaler;
  
  int _scaleWidth = 640;
  int _scaleHeight = 400;
  
  CanvasManager() {
    _canvas = query("#siege_game_canvas");
    _context = _canvas.context2D;
    _resize();
    window.onResize.listen(_resize);
  }
  
  int get scaleHeight => _scaleHeight;
  int get scaleWidth => _scaleWidth;
  
  Rect get canvasDrawArea => _canvasDrawArea;
  
  num get scaler => _scaler;
  
  CanvasRenderingContext2D get context => _context;
  
  Point translateToWorldCoordinates(WorldPositionComponent worldCenter, num mouseX, num mouseY) {
    num screenX0 = worldCenter.x - _scaleWidth / 2 ;
    num screenY0 = worldCenter.y - _scaleHeight / 2 ;
    num adjScreenX = screenX0 + (mouseX - _canvasDrawArea.left) / _scaler;
    num adjScreenY = screenY0 + (mouseY - _canvasDrawArea.top) / _scaler;
    num isoX = ((adjScreenY / 16) + (adjScreenX / 32)) / 2;
    num isoY = ((adjScreenY / 16) - (adjScreenX / 32)) / 2;
    return new Point(isoX, isoY);
  }
  
  void _resize([event]) {
    _canvas.height = window.innerHeight;
    _canvas.width = window.innerWidth;
    _calculateDrawArea();
    _canvas.focus();
  }
  
  void _calculateDrawArea() {
    num ratio = _canvas.width / _canvas.height;
    
    num width;
    num height;
    if (_canvas.width > 1024 && _canvas.height > 640) {
      width = 1024;
      height = 640;
    } else if (ratio > 1.6) {
        width = 1.6 * _canvas.height;
        height = _canvas.height;
    } else {
        width = _canvas.width;
        height = _canvas.width / 1.6;
    }
    num x = (_canvas.width - width) / 2;
    num y = (_canvas.height - height) / 2;
    
    _canvasDrawArea = new Rect(x, y, width, height);
    
    _scaler = width / _scaleWidth;
  }
  
  void clearCanvas() {
    _context.clearRect(0, 0, _canvas.width, _canvas.height);
    // TODO remove debugging stuff
    //_context.fillStyle = "red";
    //_context.fillRect(_canvasDrawArea.left, _canvasDrawArea.top, _canvasDrawArea.width, _canvasDrawArea.height);
  }
}