
void drawAxisCoordinate(color linescolour) {
  stroke(linescolour);
  line(0, 0, 25, 0); 
  line(0, 0, 0, 25);
  ellipse(25, 0, 5, 5); 
  ellipse(0, 25, 5, 5);
  stroke(0);
}

void drawNode(int kind) {
  switch(kind) {
  case 0: 
    break; // No node
  case 1:  // Rod
    beginShape();
    vertex (0, 0); 
    vertex (6, 9); 
    vertex (-6, 9);
    endShape (CLOSE);
    for (int i=0; i<4; i++) {
      line(-6+3*(i+1), 9, -6+3*i, 12);
    }
    fill(255); 
    ellipse(0, 0, 4, 4); 
    noFill(); 
    break;
  case 2:  // Slider
    beginShape(); 
    vertex (0, 0); 
    vertex (6, 9); 
    vertex (-6, 9);
    endShape (CLOSE);
    fill(255); 
    ellipse(-3, 11, 4, 4); 
    ellipse(3, 11, 4, 4);
    ellipse(0, 0, 4, 4); 
    noFill(); 
    break;
  case 3:  // Left fix
    line(0, -9, 0, 9); 
    for (int i=0; i<6; i++) {
      line(0, -9+3*i, -3, -9+3*(i+1));
    } 
    break;
  case 4:  // Right fix
    line(0, -9, 0, 9); 
    for (int i=0; i<6; i++) {
      line(0, -9+3*(i+1), 3, -9+3*i);
    } 
    break;
  }
}

void drawLoadPuntual(float magnitude) {
  strokeWeight(1.5);
  line(0, 0, 0, -magnitude);
  if (magnitude>=0) {
    line(0, 0, 3, -3); 
    line(0, 0, -3, -3);
  } else {
    line(0, 0, 3, 3); 
    line(0, 0, -3, 3);
  }  
  if (showValues==true) {
    textFont(txt10); 
    textAlign(CENTER); 
    fill(greenDark);
    if (magnitude>=0) {
      text(int(magnitude)+" kN", 0, -magnitude-2);
    } else {
      text(int(magnitude)+" kN", 0, -magnitude+10);
    }
    textFont(txt13); 
    textAlign(LEFT); 
    noFill();
  }
  strokeWeight(1);
}

void drawLoadMoment(float magnitude) {
  strokeWeight(1.5);
  line(0, -3, 0, 3);
  if (magnitude>0) {
    arc(0, 0, 2*magnitude, 2*magnitude, HALF_PI, TWO_PI);
    line(0, magnitude, -3, magnitude-3); 
    line(0, magnitude, -3, magnitude+3);
  } else {
    arc(0, 0, -2*magnitude, -2*magnitude, -PI, HALF_PI);
    line(0, -magnitude, 3, -magnitude-3); 
    line(0, -magnitude, 3, -magnitude+3);
  }
  if (showValues==true) {
    textFont(txt10); 
    fill(greenDark); 
    textAlign(CENTER);
    if (magnitude>0) {
      text(int(magnitude)+" kN·m", 0, magnitude+18);
    }
    if (magnitude<0) {
      text(int(magnitude)+" kN·m", 0, -magnitude+18);
    }
    textFont(txt13); 
    textAlign(LEFT); 
    noFill();
  }
  strokeWeight(1);
}

void drawLoadLineal(float ri, float rf, float magnitude) {
  strokeWeight(1.5);
  float intMax=15.0;
  float longitude=(rf-ri)*(b1.xf-b1.xi);
  float divisions=ceil(abs(longitude)/intMax);
  float interval=longitude/divisions;
  float lengthIncrement, heightIncrement;
  for (int i=0; i<=divisions; i++) {
    lengthIncrement=i*interval; 
    heightIncrement=(longitude*b1.yf/b1.xf)*i/divisions;
    line(lengthIncrement, heightIncrement, lengthIncrement, heightIncrement-magnitude);
    if (magnitude==0) {/*Do nothing*/
    } else if (magnitude>0) {
      line(lengthIncrement, heightIncrement, lengthIncrement-3, heightIncrement-3);
      line(lengthIncrement, heightIncrement, lengthIncrement+3, heightIncrement-3);
    } else if (magnitude<0) {
      line(lengthIncrement, heightIncrement, lengthIncrement-3, heightIncrement+3);
      line(lengthIncrement, heightIncrement, lengthIncrement+3, heightIncrement+3);
    }
  }
  line(0, -magnitude, longitude, (longitude*b1.yf/b1.xf)-magnitude);
  if (showValues==true) {
    textFont(txt10); 
    textAlign(CENTER); 
    fill(greenDark);
    if (magnitude>=0) {
      text(int(magnitude)+" kN/m", longitude/2, (rf-ri)*(b1.yf-b1.yi)/2-magnitude-2);
    } else {
      text(int(magnitude)+" kN/m", longitude/2, (rf-ri)*(b1.yf-b1.yi)/2-magnitude+10);
    }
    textFont(txt13); 
    textAlign(LEFT); 
    noFill();
  }
  strokeWeight(1);
}

void drawReactionArrows(int i) {
  stroke(greenDark); 
  strokeWeight(1.5);
  pushMatrix(); 
  translate(node[i].x, node[i].y); 
  rotate(b1.slope);
  if (showAllLoads==true) {  // Drawing of total-load reaction arrows 
    // Draw horizontal reactions arrows
    if (b1.nodeReactionTotal[i][2]==0) {/* Do nothing */
    } else if (b1.nodeReactionTotal[i][2]>0) {
      line(0, 20, b1.nodeReactionTotal[i][2], 20);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]-3, 20-3);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]-3, 20+3);
    } else if (b1.nodeReactionTotal[i][2]<0) {
      line(0, 20, b1.nodeReactionTotal[i][2], 20);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]+3, 20-3);
      line(b1.nodeReactionTotal[i][2], 20, b1.nodeReactionTotal[i][2]+3, 20+3);
    }
    // Draws vertical reactions arrows
    if (b1.nodeReactionTotal[i][1]==0) {/* Do nothing */
    } else if (b1.nodeReactionTotal[i][1]>0) {
      line(0, 20, 0, 20+b1.nodeReactionTotal[i][1]);
      line(0, 20+b1.nodeReactionTotal[i][1], -3, 20+b1.nodeReactionTotal[i][1]-3);
      line(0, 20+b1.nodeReactionTotal[i][1], +3, 20+b1.nodeReactionTotal[i][1]-3);
    } else if (b1.nodeReactionTotal[i][1]<0) {
      line(0, 20, 0, 20-b1.nodeReactionTotal[i][1]);
      line(0, 20, -3, 20+3);
      line(0, 20, +3, 20+3);
    }
    // Draws moment reaction arrows - i is used as a 0-1 switch
    if (b1.nodeReactionTotal[i][3]==0) {/* Do nothing */
    } else if (b1.nodeReactionTotal[i][3]>0) {
      arc(-20+40*i, 0, 2*b1.nodeReactionTotal[i][3], 2*b1.nodeReactionTotal[i][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]-3-(2*b1.nodeReactionTotal[i][3])*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]+3-(2*b1.nodeReactionTotal[i][3])*i);
    } else if (b1.nodeReactionTotal[i][3]<0) {
      arc(-20+40*i, 0, -2*b1.nodeReactionTotal[i][3], -2*b1.nodeReactionTotal[i][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]-3-(2*b1.nodeReactionTotal[i][3])*i);
      line(-20+40*i, b1.nodeReactionTotal[i][3]-2*b1.nodeReactionTotal[i][3]*i, -23+46*i, b1.nodeReactionTotal[i][3]+3-(2*b1.nodeReactionTotal[i][3])*i);
    }
  } else {  // Drawing of single-load reaction arrows
    // Draws horizontal reactions arrows
    if (b1.nodeReactionLoad[i][currentLoad][2]==0) {/* Do nothing */
    } else if (b1.nodeReactionLoad[i][currentLoad][2]>0) {
      line(0, 20, b1.nodeReactionLoad[i][currentLoad][2], 20);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]-3, 20-3);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]-3, 20+3);
    } else if (b1.nodeReactionLoad[i][currentLoad][2]<0) {
      line(0, 20, b1.nodeReactionLoad[i][currentLoad][2], 20);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]+3, 20-3);
      line(b1.nodeReactionLoad[i][currentLoad][2], 20, b1.nodeReactionLoad[i][currentLoad][2]+3, 20+3);
    }
    // Draws vertical reactions arrows
    if (b1.nodeReactionLoad[i][currentLoad][1]==0) {/* Do nothing */
    } else if (b1.nodeReactionLoad[i][currentLoad][1]>0) {
      line(0, 20, 0, 20+b1.nodeReactionLoad[i][currentLoad][1]);
      line(0, 20+b1.nodeReactionLoad[i][currentLoad][1], -3, 20+b1.nodeReactionLoad[i][currentLoad][1]-3);
      line(0, 20+b1.nodeReactionLoad[i][currentLoad][1], +3, 20+b1.nodeReactionLoad[i][currentLoad][1]-3);
    } else if (b1.nodeReactionLoad[i][currentLoad][1]<0) {
      line(0, 20, 0, 20-b1.nodeReactionLoad[i][currentLoad][1]);
      line(0, 20, -3, 20+3); 
      line(0, 20, +3, 20+3);
    }
    // Draws moment reaction arrows, i is used as a 0-1 switch
    if (b1.nodeReactionLoad[i][currentLoad][3]==0) {/* Do nothing */
    } else if (b1.nodeReactionLoad[i][currentLoad][3]>0) {
      arc(-20+40*i, 0, 2*b1.nodeReactionLoad[i][currentLoad][3], 2*b1.nodeReactionLoad[i][currentLoad][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]-3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]+3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
    } else if (b1.nodeReactionLoad[i][currentLoad][3]<0) {
      arc(-20+40*i, 0, -2*b1.nodeReactionLoad[i][currentLoad][3], -2*b1.nodeReactionLoad[i][currentLoad][3], HALF_PI+2*HALF_PI*i, 3*HALF_PI+2*HALF_PI*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]-3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
      line(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-2*b1.nodeReactionLoad[i][currentLoad][3]*i, -23+46*i, b1.nodeReactionLoad[i][currentLoad][3]+3-(2*b1.nodeReactionLoad[i][currentLoad][3])*i);
    }
  }
  popMatrix(); 
  stroke(0); 
  strokeWeight(1);
}

void drawReactionText(int i) {
  textFont(txt10); 
  fill(greenDark);
  pushMatrix(); 
  translate(node[i].x, node[i].y); 
  rotate(b1.slope);
  if (showAllLoads==true) {  // Drawing of total-load reaction arrow text
    // Draws horizontal reaction values
    if (b1.nodeReactionTotal[i][2]==0) {/* Do nothing */
    } else if (b1.nodeReactionTotal[i][2]>0) {
      pushMatrix(); 
      translate(b1.nodeReactionTotal[i][2]+10, 25); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionTotal[i][2])+" kN", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionTotal[i][2]<0) {
      textAlign(RIGHT);
      pushMatrix();
      translate(b1.nodeReactionTotal[i][2]-10, 25); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionTotal[i][2])+" kN", 0, 0);
      popMatrix();
    }
    // Draws vertical reaction values
    if (b1.nodeReactionTotal[i][1]==0) {/* Do nothing */
    } else {
      textAlign(CENTER);
      pushMatrix(); 
      translate(0, 20+abs(b1.nodeReactionTotal[i][1])+10); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionTotal[i][1])+" kN", 0, 0);
      popMatrix();
    }    
    // Draws moment reactions values, i is used as a 0-1 switch
    if (b1.nodeReactionTotal[i][3]==0) {/* Do nothing */
    } else if (b1.nodeReactionTotal[i][3]>0) {
      textAlign(CENTER);
      pushMatrix(); 
      translate(-20+40*i, b1.nodeReactionTotal[i][3]+18+(-2*b1.nodeReactionTotal[i][3]-28)*i); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionTotal[i][3])+" kN·m", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionTotal[i][3]<0) {
      textAlign(CENTER);
      pushMatrix();
      translate(-20+40*i, b1.nodeReactionTotal[i][3]-10+(-2*b1.nodeReactionTotal[i][3]+28)*i); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionTotal[i][3])+" kN·m", 0, 0);
      popMatrix();
    }
  } else {  // Drawing of single-load reaction arrow text
    // Draws horizontal reactions values
    if (b1.nodeReactionLoad[i][currentLoad][2]==0) {/* Do nothing */
    } else if (b1.nodeReactionLoad[i][currentLoad][2]>0) {
      pushMatrix();
      translate(b1.nodeReactionLoad[i][currentLoad][2]+10, 25); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionLoad[i][currentLoad][2])+" kN", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionLoad[i][currentLoad][2]<0) {
      textAlign(RIGHT);
      pushMatrix();
      translate(b1.nodeReactionLoad[i][currentLoad][2]-10, 25); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionLoad[i][currentLoad][2])+" kN", 0, 0);
      popMatrix();
    }
    // Draws vertical reactions values
    if (b1.nodeReactionLoad[i][currentLoad][1]==0) {/* Do nothing */
    } else {
      textAlign(CENTER);
      pushMatrix();
      translate(0, 20+abs(b1.nodeReactionLoad[i][currentLoad][1])+10); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionLoad[i][currentLoad][1])+" kN", 0, 0);
      popMatrix();
    }
    // Draws moment reactions values, i is used as a 0-1 switch
    if (b1.nodeReactionLoad[i][currentLoad][3]==0) {/* Do nothing */
    } else if (b1.nodeReactionLoad[i][currentLoad][3]>0) {
      textAlign(CENTER);
      pushMatrix(); 
      translate(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]+18+(-2*b1.nodeReactionLoad[i][currentLoad][3]-28)*i); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionLoad[i][currentLoad][3])+" kN·m", 0, 0);
      popMatrix();
    } else if (b1.nodeReactionLoad[i][currentLoad][3]<0) {
      textAlign(CENTER);
      pushMatrix();
      translate(-20+40*i, b1.nodeReactionLoad[i][currentLoad][3]-10+(-2*b1.nodeReactionLoad[i][currentLoad][3]+28)*i); 
      rotate(-b1.slope);
      text(int(b1.nodeReactionLoad[i][currentLoad][3])+" kN·m", 0, 0);
      popMatrix();
    }
  }    
  popMatrix();
  textFont(txt13); 
  textAlign(LEFT); 
  noFill(); 
  stroke(0);
}

void drawBeamDiagram(int kind) {  // Kind means: 0=Axial, 1=Shear, 2=Bending, 3=Deformed shape
  float dScale=1;
  switch(kind) {
  case 0: 
    stroke(greenDark); 
    fill(greenLight); 
    break;
  case 1: 
    stroke(blueDark); 
    fill(blueLight); 
    break;
  case 2: 
    stroke(redDark); 
    fill(redLight); 
    break;
  case 3: 
    stroke(redBright); 
    strokeWeight(2.5); 
    dScale=EIScale; 
    break;
  }  
  pushMatrix();
  rotate(b1.slope);
  if (showAllLoads==true) {
    beginShape(); 
    vertex(0, 0);
    for (int i=0; i<b1.beamRange; i++) {
      vertex(i, dScale*b1.beamDiagramTotal[i][kind]);
    }
    if (kind!=3) {
      vertex(b1.beamRange, 0);
    }
    endShape();
  } else {
    beginShape(); 
    vertex(0, 0);
    for (int i=0; i<b1.beamRange; i++) {
      vertex(i, dScale*b1.beamDiagramLoad[i][currentLoad][kind]);
    }
    if (kind!=3) {
      vertex(b1.beamRange, 0);
    }
    endShape();
  }
  popMatrix();
  strokeWeight(1); 
  stroke(0); 
  noFill();
}

void drawBeamDiagramValues(int kind) {  // Kind means: 0=Axial, 1=Shear, 2=Bending, 3=Deformed shape
  String units=""; 
  int textOffset; 
  float dScale=1;
  switch(kind) {
  case 0: 
    fill(greenDark); 
    units=" kN"; 
    break;
  case 1: 
    fill(blueDark); 
    units=" kN"; 
    break;
  case 2: 
    fill(redDark); 
    units=" kN·m"; 
    break;
  case 3: 
    fill(redBright); 
    units=" mm"; 
    dScale=EIScale; 
    break;
  }  
  textFont(txt10); 
  textAlign(CENTER);
  pushMatrix(); 
  rotate(b1.slope);
  if (showAllLoads==true) {
    for (int i=0; i<2; i++) {
      if (b1.topValueTotal[i][kind]<=0) {
        textOffset=-2;
      } else {
        textOffset=10;
      }
      pushMatrix();
      translate(b1.topIndexTotal[i][kind], dScale*b1.topValueTotal[i][kind]+textOffset);
      if (kind!=3) {
        if (int(b1.topValueTotal[i][kind])!=0) {
          text(int(b1.topValueTotal[i][kind])+units, 0, 0);
        }
      } else {
        if (b1.topValueTotal[i][kind]!=0) {
          text(nf(1000*b1.topValueTotal[i][kind], 0, 2)+units, 0, 0);
        }
      }
      popMatrix();
    }
  } else {
    for (int i=0; i<2; i++) {
      if (b1.topValueLoad[currentLoad][i][kind]<=0) {
        textOffset=-2;
      } else {
        textOffset=10;
      }
      pushMatrix();
      translate(b1.topIndexLoad[currentLoad][i][kind], dScale*b1.topValueLoad[currentLoad][i][kind]+textOffset);
      if (kind!=3) {
        if (int(b1.topValueLoad[currentLoad][i][kind])!=0) {
          text(int(b1.topValueLoad[currentLoad][i][kind])+units, 0, 0);
        }
      } else {
        if (b1.topValueLoad[currentLoad][i][kind]!=0) {
          text(nf(1000*b1.topValueLoad[currentLoad][i][kind], 0, 2)+units, 0, 0);
        }
      }
      popMatrix();
    }
  }
  popMatrix();
  textFont(txt13); 
  textAlign(LEFT);
  strokeWeight(1); 
  stroke(0); 
  noFill();
}


// Keyboard action functions
// (they are moved to a different tab to be sepparated from their action key
// and be easily translated by substituting the _f_keyb_letters_ES.pde)

// CURSOR BEHAVIOUR - Is made a special function as it is the feature that is more customized
void kbCursorModeLoadUp() {
  kbChangeLoadMagnitude(+1);
}
void kbCursorModeLoadDown() {
  kbChangeLoadMagnitude(-1);
}
void kbCursorModeLoadLeft() {
  kbChangeLoadRIPosition(-1); 
  kbChangeLoadRFPosition(-1);
}
void kbCursorModeLoadRight() {
  kbChangeLoadRIPosition(+1); 
  kbChangeLoadRFPosition(+1);
}
void kbCursorModeRotationUp() {
  beamModeRotationAngleTemp=b1.slope-.01; 
  b1.xf=b1.L*cos(beamModeRotationAngleTemp); 
  b1.yf=b1.L*sin(beamModeRotationAngleTemp);
}
void kbCursorModeRotationDown() {
  beamModeRotationAngleTemp=b1.slope+.01; 
  b1.xf=b1.L*cos(beamModeRotationAngleTemp); 
  b1.yf=b1.L*sin(beamModeRotationAngleTemp);
}
void kbCursorModeNodeUp() {
  b1.yf-=2;
}
void kbCursorModeNodeDown() {
  b1.yf+=2;
}
void kbCursorModeNodeLeft() {
  if (b1.xf>b1.xi) {
    b1.xf-=2;
  }
}
void kbCursorModeNodeRight() {
  b1.xf+=2;
}

// ACTION FUNCTIONS - Are called for specific tasks
void kbChangeLoadKind(char kind) {
  load[currentLoad].kind=kind;
}
void kbChangeLoadWidth(int sign) {
  if (cursorModeLoad==true) {
    load[currentLoad].rf+=sign*0.01; 
    load[currentLoad].ri-=sign*0.01;
  }
}
void kbChangeLoadMagnitude(int sign) {
  load[currentLoad].magnitude+=sign*1;
}
void kbChangeLoadRIPosition(int sign) {
  load[currentLoad].ri+=sign*0.01;
}
void kbChangeLoadRFPosition(int sign) {
  load[currentLoad].rf+=sign*0.01;
}
void kbChangeEI(int sign) {
  EI+=sign*10;
}
void kbChangeModeLoad(int toggle) {
  if (toggle==0) { 
    cursorModeLoad=false; 
    highlight.start(node[currentNode].x, node[currentNode].y);
  } else {
    if (cursorModeLoad==false) {
      cursorModeLoad=true;
    } else {
      currentLoad+=1; 
      if (currentLoad==activeLoads) {
        currentLoad=0;
      }
    }
    highlight.start(load[currentLoad].xi, load[currentLoad].yi);
  }
}
void kbChangeDisplayDiagram(int kindN) {
  switch(kindN) {
  case 0: 
    activateDiagramAxial=!activateDiagramAxial; 
    break;
  case 1: 
    activateDiagramShear=!activateDiagramShear; 
    break;
  case 2: 
    activateDiagramBending=!activateDiagramBending; 
    break;
  case 3: 
    activateDiagramDeformed=!activateDiagramDeformed; 
    break;
  }
}
void kbChangeDisplayLoads() {
  showAllLoads=!showAllLoads;
}
void kbChangeDisplayValues() {
  showValues=!showValues;
}
void kbChangeModeRotation() {
  beamModeRotation=!beamModeRotation;
}
void kbChangeBeam() {
  if (node[0].kind=='R') {
    node[0].kind='F';
  } else {
    node[0].kind='R';
  }
  if (node[1].kind=='N') {
    node[1].kind='S';
  } else {
    node[1].kind='N';
  }
}
void kbPrint(int toggle) {
  if (toggle==0) {
    save("screenshot_" + frameCount + ".png");
  } else {
    savePDF=true;
  }
}
void kbChangeActiveLoads(int numb) {
  activeLoads=numb; 
  if (currentLoad>=activeLoads) {
    currentLoad=activeLoads-1;
  }
}

// Keyboard interaction functions

// Action keys
void keyboardInteraction() {
  if (keyPressed==true) {
    switch(key) {
    case 'P': 
    case 'p': 
      kbChangeLoadKind('P'); 
      break;
    case 'U': 
    case 'u': 
      kbChangeLoadKind('U'); 
      break;
    case 'M': 
    case 'm': 
      kbChangeLoadKind('M'); 
      break;
    case 'W': 
    case 'w': 
      kbChangeLoadWidth(+1); 
      break;
    case 'E': 
    case 'e': 
      kbChangeLoadWidth(-1); 
      break; 
    case 'Y': 
    case 'y': 
      kbChangeEI(+1); 
      break;
    case 'H': 
    case 'h': 
      kbChangeEI(-1); 
      break;
    }//      case CODED:
    if (cursorModeLoad==true) {
      switch(keyCode) {
      case UP: 
        kbCursorModeLoadUp(); 
        break;
      case DOWN: 
        kbCursorModeLoadDown(); 
        break;
      case LEFT: 
        kbCursorModeLoadLeft(); 
        break;
      case RIGHT: 
        kbCursorModeLoadRight(); 
        break;
      }
    } else if (beamModeRotation==true) {
      switch(keyCode) {
      case UP: 
        kbCursorModeRotationUp(); 
        break;
      case DOWN: 
        kbCursorModeRotationDown(); 
        break;
      }
    } else {
      switch(keyCode) {
      case UP: 
        kbCursorModeNodeUp(); 
        break;
      case DOWN: 
        kbCursorModeNodeDown(); 
        break;
      case LEFT: 
        kbCursorModeNodeLeft(); 
        break;
      case RIGHT: 
        kbCursorModeNodeRight(); 
        break;
      }
    }
    //      }
    // Contraints of relative position values for active loads (can't use a if.else structure because on uniform)
    for (int i=0; i<activeLoads; i++) { 
      if (load[i].ri>1) {
        load[i].ri=1;
      } else if (load[i].ri<0) {
        load[i].ri=0;
      }
      if (load[i].rf>1) {
        load[i].rf=1;
      } else if (load[i].rf<0) {
        load[i].rf=0;
      }
    }
    // All updating has been put together here to any keyStroke. Could be optimised... 
    updateAllCalculation();
  }
}

// Display keys
void keyPressed() {  
  println("Pressed key " + key);
  println("Pressed keyCode " + keyCode);

  switch(key) {
  case 'Q': 
  case 'q': 
    kbChangeModeLoad(1); 
    break;
  case 'N': 
  case 'n': 
    kbChangeModeLoad(0); 
    break; 
  case 'A': 
  case 'a': 
    kbChangeDisplayDiagram(0); 
    break;
  case 'S': 
  case 's': 
    kbChangeDisplayDiagram(1); 
    break;
  case 'B': 
  case 'b': 
    kbChangeDisplayDiagram(2); 
    break;
  case 'D': 
  case 'd': 
    kbChangeDisplayDiagram(3); 
    break;
  case 'T': 
  case 't': 
    kbChangeDisplayLoads(); 
    break;
  case 'X': 
  case 'x': 
    kbChangeDisplayValues(); 
    break;
  case 'R': 
  case 'r': 
    kbChangeModeRotation(); 
    break;
  case 'V': 
  case 'v': 
    kbChangeBeam(); 
    break;
  case '1': 
  case '2': 
  case '3': 
  case '4': 
  case '5': 
    String temp=Character.toString(key); 
    kbChangeActiveLoads(int(temp)); 
    break;
  case 'Z': 
  case 'z': 
    welcomeToggle=true; 
    break;
  }
  //    case CODED:
  switch(keyCode) {
  case 112:  // F1
    helpToggle=!helpToggle; 
    break;
  case 123:  // F12 
    print("Taking screenshot");
    kbPrint(0); 
    break;  // Save to PNG
  case 122: 
    kbPrint(1); 
    break;  // Save to PDF
  case SHIFT: 
    welcomeToggle=false; 
    break;
  }        
  //  }
}


// Help text lines
String ha="KEYBOARD CONFIGURATION\n\n";
String hb="              Q __ Select active load\n";
String hc="              ARROW KEYS __ Move and change magnitude of active load\n";
String hd="              W-E __ Increase/decrease active load's width (uniform loads only)\n";  
String he="              P-U-M __ Change active load to Puntual / Uniform / Moment\n";
String hf="              T __ Display active/all loads toggle\n";
String hg="              X __ Display values toggle\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n";
String hh="              N __ Select active node\n";
String hi="              ARROW KEYS __ Move active node\n";
String hj="              V __ Change beam supports\n";
String hk="              R __ Beam rotation mode toggle\n";
String hl="              A-S-B-D __ Axial / Shear / Bending / Deformed shape diagrams toggle\n";
String hm="              Y-H __ Increase/Decrease EI\n\n";
String hn="              F1 __  Help menu toggle\n";
String ho="              F12 __  PNG screenshot (deactivated in web mode)\n";
String hp="             F11 __  PDF screenshot (deactivated in web mode)\n";
String hq="LOADS:\n";
String hr="BEAM:\n";
String hs="              1/5 __ Choose number of active loads\n";
String ht="              Z __  Welcome screen\n";
String hu="Version 2.0";

void displayHelp() {
  fill(230, 100); 
  noStroke(); 
  rect(210, 10, 781, 581); 
  stroke(0);
  pushMatrix();  // (it has to come from 0,0 reference)
  translate(210, 10);  // Help text anchor point
  fill(0); 
  textFont(txt10); 
  textLeading(11);
  text(hr+hh+hi+hk+hj+hl+hm+hq+hs+hb+hc+hd+he+hf+hg+hn+ht, 10, 20);
  textAlign(RIGHT); 
  text(hu, 740, 550); 
  textAlign(LEFT);
  noFill(); 
  textFont(txt13);
  popMatrix();
}

void displayWelcomeScreen() {
  fill(255); 
  noStroke(); 
  rect(0, 0, width, height);
  stroke(0); 
  noFill();
  pushMatrix();
  translate(width/2, 80);
  fill(0); 
  textAlign(CENTER); 
  image(imgIntro, 0, 140); 
  //image(imgLogoUS, 0, 430);
  textFont(txt16); 
  text("KILO", 0, 0);
  fill(redDark); 
  text("INTERACTIVE STRUCTURAL ANALYSIS TOOL", 0, 20);
  fill(0); 
  textFont(txt10);
  text("Faculty of Architecture, Universidad de Sevilla", 0, 300);
  text("Department of Continuum Mechanics, Theory of Structures and Geotechnical Engineering", 0, 310);
  text("Structures 1", 0, 320);
  text("Director: Enrique de Justo Moscardó", 0, 340);
  text("Coding: Jose Luis García del Castillo y López", 0, 350);
  text("Contact: info@garciadelcastillo.es", 0, 370);
  textFont(txt13); 
  fill(redDark); 
  text("Press CAPS to continue", 0, 500);
  popMatrix();
  textAlign(LEFT); 
  textFont(txt13);
  noFill();
}

void displayDataText() {
  fill(0); 
  textFont(txt16); 
  text("KILO", 10, 26); 
  line(10, 29, 200, 29);
  textFont(txt10); 
  text("Use keys to interact with the structure", 10, 570);
  text("Press 'F1' for help", 10, 585);
  text("BEAM", 10, 50);
  text("Length = "+nf(b1.L/100, 0, 2)+" m", 10, 60);
  text("Slope = "+nf(degrees(b1.slope), 0, 2)+"º", 10, 70);
  text("EI = "+int(EI)+" kN·m2", 10, 80);
  text("ACTIVE LOAD", 10, 100);
  text("Position = "+nf(load[currentLoad].ri*b1.Lm, 0, 2)+" m", 10, 110); 
  switch(load[currentLoad].kindN) {
  case 0: 
    text("Magnitude = "+int(load[currentLoad].magnitudeY)+" kN", 10, 120); 
    break;
  case 1: 
    text("Magnitude = "+int(load[currentLoad].magnitude)+" kN·m", 10, 120); 
    break;
  case 2: 
    text("Magnitude = "+int(load[currentLoad].magnitudeY)+" kN/m (width "+nf((load[currentLoad].rf-load[currentLoad].ri)*b1.Lm, 0, 2)+" m)", 10, 120); 
    break;
  }
  text("REACTIONS", 10, 140);
  if (showAllLoads==true) {
    text("Rx1 = "+int(b1.nodeReactionTotal[0][2])+" kN", 10, 150); 
    text("Ry1 = "+int(b1.nodeReactionTotal[0][1])+" kN", 10, 160); 
    text("M1  = "+int(b1.nodeReactionTotal[0][3])+" kN·m", 10, 170);
    text("Rx2 = "+int(b1.nodeReactionTotal[1][2])+" kN", 100, 150); 
    text("Ry2 = "+int(b1.nodeReactionTotal[1][1])+" kN", 100, 160); 
    text("M2  = "+int(b1.nodeReactionTotal[1][3])+" kN·m", 100, 170);
  } else {
    text("Rx1 = "+int(b1.nodeReactionLoad[0][currentLoad][2])+" kN", 10, 150); 
    text("Ry1 = "+int(b1.nodeReactionLoad[0][currentLoad][1])+" kN", 10, 160);
    text("M1  = "+int(b1.nodeReactionLoad[0][currentLoad][3])+" kN·m", 10, 170);
    text("Rx2 = "+int(b1.nodeReactionLoad[1][currentLoad][2])+" kN", 100, 150); 
    text("Ry2 = "+int(b1.nodeReactionLoad[1][currentLoad][1])+" kN", 100, 160);
    text("M2  = "+int(b1.nodeReactionLoad[1][currentLoad][3])+" kN·m", 100, 170);
  }
  fill(greenDark); 
  text("AXIAL FORCES", 10, 190);
  if (showAllLoads==true) {
    text("Min. value = "+int(b1.topValueTotal[0][0])+" kN (at "+nf(b1.topIndexTotal[0][0]*0.01, 0, 2)+" m)", 10, 200);
    text("Max. value = "+int(b1.topValueTotal[1][0])+" kN (at "+nf(b1.topIndexTotal[1][0]*0.01, 0, 2)+" m)", 10, 210);
  } else {
    text("Min. value = "+int(b1.topValueLoad[currentLoad][0][0])+" kN (at "+nf(b1.topIndexLoad[currentLoad][0][0]*0.01, 0, 2)+" m)", 10, 200);
    text("Max. value = "+int(b1.topValueLoad[currentLoad][1][0])+" kN (at "+nf(b1.topIndexLoad[currentLoad][1][0]*0.01, 0, 2)+" m)", 10, 210);
  }
  fill(blueDark); 
  text("SHEAR FORCES", 10, 230);
  if (showAllLoads==true) {
    text("Min. value = "+int(b1.topValueTotal[0][1])+" kN (at "+nf(b1.topIndexTotal[0][1]*0.01, 0, 2)+" m)", 10, 240);
    text("Max. value = "+int(b1.topValueTotal[1][1])+" kN (at "+nf(b1.topIndexTotal[1][1]*0.01, 0, 2)+" m)", 10, 250);
  } else {
    text("Min. value = "+int(b1.topValueLoad[currentLoad][0][1])+" kN (at "+nf(b1.topIndexLoad[currentLoad][0][1]*0.01, 0, 2)+" m)", 10, 240);
    text("Max. value = "+int(b1.topValueLoad[currentLoad][1][1])+" kN (at "+nf(b1.topIndexLoad[currentLoad][1][1]*0.01, 0, 2)+" m)", 10, 250);
  }
  fill(redDark); 
  text("BENDING FORCES", 10, 270);
  if (showAllLoads==true) {
    text("Min. value = "+int(b1.topValueTotal[0][2])+" kN·m (at "+nf(b1.topIndexTotal[0][2]*0.01, 0, 2)+" m)", 10, 280);
    text("Max. value = "+int(b1.topValueTotal[1][2])+" kN·m (at "+nf(b1.topIndexTotal[1][2]*0.01, 0, 2)+" m)", 10, 290);
  } else {
    text("Min. value = "+int(b1.topValueLoad[currentLoad][0][2])+" kN·m (at "+nf(b1.topIndexLoad[currentLoad][0][2]*0.01, 0, 2)+" m)", 10, 280);
    text("Max. value = "+int(b1.topValueLoad[currentLoad][1][2])+" kN·m (at "+nf(b1.topIndexLoad[currentLoad][1][2]*0.01, 0, 2)+" m)", 10, 290);
  }
  fill(redBright); 
  text("DEFORMED SHAPE", 10, 310);
  if (showAllLoads==true) {
    text("Min. value = "+nf(1000*b1.topValueTotal[0][3], 0, 2)+" mm (at "+nf(b1.topIndexTotal[0][3]*0.01, 0, 2)+" m)", 10, 320);
    text("Max. value = "+nf(1000*b1.topValueTotal[1][3], 0, 2)+" mm (at "+nf(b1.topIndexTotal[1][3]*0.01, 0, 2)+" m)", 10, 330);
  } else {
    text("Min. value = "+nf(1000*b1.topValueLoad[currentLoad][0][3], 0, 2)+" mm (at "+nf(b1.topIndexLoad[currentLoad][0][3]*0.01, 0, 2)+" m)", 10, 320);
    text("Max. value = "+nf(1000*b1.topValueLoad[currentLoad][1][3], 0, 2)+" mm (at "+nf(b1.topIndexLoad[currentLoad][1][3]*0.01, 0, 2)+" m)", 10, 330);
  }
  noFill(); 
  textFont(txt13);
}

void updateAllCalculation() {
  // Remember to consider introducing calculation in the initial sketch setup
  b1.update();
  for (int i=0; i<activeLoads; i++) {
    load[i].update();
  }
  for (int i=0; i<numberOfNodes; i++) {
    node[i].update();
  }
  switch(b1.nodeCombCase) {
  case 0: 
  case 1: 
  case 3: 
  case 6: 
    eraseAllCalculation();
    break;
  case 2: 
  case 4: 
  case 7: 
  case 8: 
  case 10: 
  case 14:
    b1.calcNodesReactions(); 
    b1.calcBeamDiagramSetup();
    if (activateDiagramAxial==true) {
      b1.calcBeamDiagramAxial();
    }
    if (activateDiagramShear==true) {
      b1.calcBeamDiagramShear();
    }
    if (activateDiagramBending==true) {
      b1.calcBeamDiagramBending();
    }
    if (activateDiagramDeformed==true) {
      b1.calcBeamDiagramDeformed();
    }
    break;
  }
}

void eraseAllCalculation() {
  // Erase node reactions
  for (int i=0; i<numberOfNodes; i++) {
    for (int k=0; k<4; k++) {
      b1.nodeReactionTotal[i][k]=0;
    }
    for (int j=0; j<numberOfLoads; j++) {
      for (int k=0; k<4; k++) {
        b1.nodeReactionLoad[i][j][k]=0;
      }
    }
  }
  // Erase beam forces
  b1.calcBeamDiagramSetup();  // To update beamRange
  for (int i=0; i<b1.beamRange; i++) {
    for (int k=0; k<4; k++) {
      b1.beamDiagramTotal[i][k]=0;
    }
    for (int j=0; j<numberOfLoads; j++) {
      for (int k=0; k<4; k++) {
        b1.beamDiagramLoad[i][j][k]=0;
      }
    }
  }
}
