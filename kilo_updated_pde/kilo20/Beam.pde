class Beam extends Calculation {
  float xi, yi, xf, yf, slope, L, Lm;  // with L=length, Lm=length in meters
  int nodeCombCase;

  Beam (float xi_, float yi_, float xf_, float yf_) {
    xi=xi_; 
    yi=yi_; 
    xf=xf_; 
    yf=yf_;
  }

  void update() {  // Update geometry conditions
    slope=atan((yf-yi)/(xf-xi));
    L=dist(xi, yi, xf, yf); 
    Lm=L/100;
    nodeCombCase=node[0].kindN+node[1].kindN;
  }

  void display() {
    strokeWeight(2.5);
    line(xi, yi, xf, yf);
    strokeWeight(1);
  }
}
