
class Highlight {  // A class to highlight active load or node
  float x, y, diameter;
  boolean on=false;

  void start(float x_, float y_) {
    x=x_; 
    y=y_; 
    on=true; 
    diameter=1;
  }

  void display() {
    if (on==true) {
      diameter+=2;
      strokeWeight(2); 
      stroke(150, 0, 0, map(diameter, 0, 50, 255, 100));
      ellipse (x, y, diameter, diameter);
      stroke(0); 
      strokeWeight(1);
      if (diameter>50) {
        on=false;
      }
    }
  }
}
