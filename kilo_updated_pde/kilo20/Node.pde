
class Node extends Calculation {
  char kind;  // char-coded node id.: N, R, S, F, G (None, Rod, Slider, Fix-left, Fix-right, implemented to be used with switch command)
  float x, y, r;  // absolute x, y positions, relative beam r position
  float size_=9;  // node icon drawing size
  int kindN;  // Number-coded node id.: 0=No node, 1=Rod, 3=Slider, 7=Fix
  int kindD;  // Number-coded drawing node id.: N=0, R=1, S=2, F=3, G=4

  Node(char kind_, float r_) {
    kind=kind_;
    r=r_;
  }

  void update() {
    if (r>1) {
      r=1;
    } else if (r<0) {
      r=0;
    }
    x=r*(b1.xf-b1.xi); 
    y=r*(b1.yf-b1.yi);
    switch (kind) {
    case 'N': 
      kindN=0; 
      kindD=0; 
      break;
    case 'R': 
      kindN=1; 
      kindD=1; 
      break; 
    case 'S': 
      kindN=3; 
      kindD=2; 
      break;
    case 'F': 
      kindN=7; 
      kindD=3; 
      break;
    case 'G': 
      kindN=7; 
      kindD=4; 
      break;
    }
  }

  void display() {
    pushMatrix(); 
    translate (x, y); 
    rotate(b1.slope); 
    scale(size_/9);
    drawNode(kindD);
    popMatrix();
  }
}
