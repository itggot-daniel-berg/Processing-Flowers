import vialab.SMT.*;

int width = 1366;
int height = 768;

void setup() {
  // Create the window, use MultiTouch input 
  size(width, height, SMT.RENDERER);
  // Connect to the Touchscreen usion TUIO
  SMT.init(this, TouchSource.TUIO_DEVICE);
  
  // Create a new Touchzone, covering the entire window
  SMT.add(new MainZone(width, height));
  
  // Use Hue, Saturation, Brightness for more colour goodness
  colorMode(HSB);
}

void draw() {
  // Before every frame, cover previous frame in black
  background(0);
}

class MainZone extends Zone {
  
  MainZone(int width, int height) {
    super("Main", 0,0, width, height);
  }
  
  @Override
  public void touchDown(Touch touch) {
    // When touching inside the Main Zone, create a new Flower Zone
    FlowerZone fz = new FlowerZone(touch.x, touch.y, this);
    this.add(fz);
    // Let the Flower Zone handle the touch
    fz.assign(touch);
  }
  
  // Do nothing
  @Override
  public void touch() { }  
  
  // Do nothing
  @Override
  public void touchMoved(Touch touch ) { }
  
  // Do nothing
  @Override
  public void touchUp(Touch touch) { }
  
  // Do nothing
  @Override
  public void draw() { }
  
}

class FlowerZone extends Zone {
  int x;
  int y;
  int size = 40;
  MainZone parent;
  Flower flower;
  
  FlowerZone(int _x, int _y, MainZone _parent) {
    super(_x - 20, _y -20, 40, 40);
    x = _x - 20;
    y = _y - 20;
    // Keep track of MainZone
    // so we can tell it to stop drawing us later
    parent = _parent;
    
    // Create a new Flower inside the Flower Zone
    flower = new Flower(0, 0, 1);
  }
  
  // Tell the Main Zone to remove us
  // if "our" touch disappears
  @Override 
  public void touchUp(Touch touch ) {
    parent.remove(this);  
  }
  
  // For every frame, tell the flower to draw itself
  @Override
  public void draw() {
    flower.draw();
  }
 
  // Do nothing
  @Override
  public void touchMoved(Touch touch) { }
}

class Flower {
  float x, y;
  int totalPetals = 300;
  int size = 600;
  float goldenRatio = 137.5077640844293;
  float radiusGrowth = 1.0049;
  float radius = 60;
  float twist = 0.0;
  Petal[] petals; 
  int id;
  PGraphics image;
  int hue = int(random(255));
  float rotation = 0.0;
  float rotationSpeed = random(-1.5, 1.5);
    
  Flower(float _x, float _y, int _id) {
    x = _x;
    y = _y;
    id = _id;
    
    petals = new Petal[totalPetals];     
    image = createGraphics(size, size);
    for (int i = 0; i < totalPetals; i++) {     
      twist += goldenRatio;
      radius *= radiusGrowth;
      petals[i] = new Petal(this, i);
    }
    render();
  }
  
  // Save the flower as an image, so we do
  // not have to redraw it every frame
  void render() {  
    image.beginDraw();
      image.smooth();
      image.noStroke();
      image.pushMatrix();
        image.translate(size / 2 , size / 2);
        for(Petal petal : petals) { petal.render(); }
      image.popMatrix();
    image.endDraw();
  }
  
  // For every frame
  void draw() {
    if(rotation >= 360) { rotation = 0; }
    pushMatrix();
      //Rotate the canvas
      rotate(radians(rotation));
      // Draw the image
      image(image, - size / 2, - size / 2);
    // Reset the canvas
    popMatrix();
    rotation += rotationSpeed;
  }
}  
  
class Petal {
  float x = 0.0;
  float y = 0.0;
  float twist = 0.0;
  float scaleVar = 1;
  color baseColor;   
  color detailColor;
  color trimColor;
  Flower flower;
  int hue;
  
  Petal(Flower _flower, int i) {
      flower = _flower;
      x = cos(radians(flower.twist)) * flower.radius;
      y = sin(radians(flower.twist)) * flower.radius;
      twist = radians(flower.twist);
      scaleVar += (i * 2) / flower.totalPetals;
      hue = i;
  }
  
  void render() {
    flower.image.pushMatrix();
      setColors();
      flower.image.translate(this.x, this.y);
      flower.image.fill(this.baseColor);
      flower.image.rotate(this.twist);
      flower.image.scale(this.scaleVar, this.scaleVar);
      flower.image.rect(-10, -1, 20, 2);
      flower.image.ellipse(0, 0, 10, 10);
      flower.image.fill(this.detailColor);
      flower.image.ellipse(0, 0, 8, 8);
      flower.image.fill(this.trimColor);
      flower.image.ellipse(0, 0, 5, 5);
    flower.image.popMatrix();
  }
  
  void setColors() {
    int offset = flower.hue + hue % 255;
    baseColor = color(offset, 255, 255, 150);
    offset = (offset + 1) % 255;
    detailColor = color(offset, 255, 255, 160);
  }
}
