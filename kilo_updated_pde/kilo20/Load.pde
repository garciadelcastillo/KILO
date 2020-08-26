
class Load extends Calculation {
  char kind;  // char-coded load kind: P (puntual, M (moment), U (uniform)
  float ri, rf, xi, yi, xf, yf, magnitude, magnitudeX, magnitudeY;
  int kindN;  // Number-coded load kind: 0=Puntual, 1=Moment, 2=Uniform

  Load(char kind_, float ri_, float rf_, float magnitude_) {
    kind=kind_;
    ri=ri_; 
    rf=rf_;
    magnitude=magnitude_;
    magnitudeX=magnitude*sin(b1.slope); 
    magnitudeY=magnitude*cos(b1.slope);
  }

  // Updates loads relative positions
  void update() {
    if (rf<ri || ri>rf) {
      rf=ri;
    }
    // Translates relative positions to absolute coordinates
    xi=ri*(b1.xf-b1.xi); 
    yi=ri*(b1.yf-b1.yi);
    xf=rf*(b1.xf-b1.xi); 
    yf=rf*(b1.yf-b1.yi);
    magnitudeX=magnitude*sin(b1.slope); 
    magnitudeY=magnitude*cos(b1.slope); 
    if (kind=='P') {
      kindN=0;
    } else if (kind=='M') {
      kindN=1;
    } else if (kind=='U') {
      kindN=2;
    }
  }

  void display() {
    stroke(greenDark);
    pushMatrix();
    translate(xi, yi);
    if (kind=='P') {
      drawLoadPuntual(magnitude);
    } else if (kind=='M') {
      drawLoadMoment(magnitude);
    } else if (kind=='U') {
      drawLoadLineal(ri, rf, magnitude);
    }
    popMatrix();
    stroke(0);
  }
}
