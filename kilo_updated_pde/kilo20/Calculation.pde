
class Calculation {
  float[][][] nodeReactionLoad;
  float[][] nodeReactionTotal;
  float[][][] beamDiagramLoad;
  float[][] beamDiagramTotal;  
  int beamRange;
  float[][][] topValueLoad; 
  int[][][] topIndexLoad;  // [numberOfLoads] [0=min, 1=max] [0-4]
  float[][] topValueTotal; 
  int[][] topIndexTotal;  // [numberOfLoads] [0-4]

  void calcNodeReactionSetup() {
    // To be run only once within the void setup() main function
    // Third column tag: 0 is global Y, 1 is local Y direction, 2 is local X, 3 is bending
    // (global Y (0 column) is not going to be implemented at the moment, less computing)
    nodeReactionLoad=new float[numberOfNodes] [numberOfLoads] [4]; 
    nodeReactionTotal=new float[numberOfNodes] [4];
  }   

  void calcNodesReactions() {  // This will STILL only work for 2-noded beams
    for (int i=0; i<numberOfNodes; i++) {
      for (int k=0; k<4; k++) {
        nodeReactionTotal[i][k]=0;
      }  // Resets reaction totals
      for (int j=0; j<activeLoads; j++) {
        for (int k=0; k<4; k++) {
          nodeReactionLoad[i][j][k]=0;
        }  // Resets reactions for single loads (helps on beam nodes changes)
        switch(load[j].kindN) {  // Calculation of single load reactions
        case 0:  // Case for PUNTUAL LOADS
          switch(b1.nodeCombCase) {
          case 2: 
            break;  // rod+rod
          case 4:  // rod+sli - Rod is always in the left side (node[0])
            nodeReactionLoad [i] [j] [1] = -load[j].magnitudeY*(((node[1-i].x-node[i].x)-(load[j].xi-node[i].x))/(node[1-i].x-node[i].x));
            nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX;
            break;
          case 7:  // fix+no - Fix is always in the left side (node[0])
            nodeReactionLoad [0] [j] [1] = -load[j].magnitudeY;
            nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX;
            nodeReactionLoad [0] [j] [3] = load[j].magnitudeY*(load[j].ri*b1.L)/100;
            break;              
          case 8: 
            break;  // fix+rod
          case 10: 
            break;  // fix+sli
          case 14: 
            break;  // fix+fix
          } 
          break;
        case 1:  // Case for MOMENT LOADS
          switch(b1.nodeCombCase) {
          case 2: 
            break;  // rod+rod
          case 4:  // rod+sli - Rod is always in the left side (node[0])
            nodeReactionLoad [i] [j] [1] = -100*load[j].magnitude/b1.L+200*i*load[j].magnitude/b1.L;
            break;
          case 7:  // fix+no - Fix is always in the left side (node[0])
            nodeReactionLoad [0] [j] [3] = -load[j].magnitude;
            break;              
          case 8: 
            break;  // fix+rod
          case 10: 
            break;  // fix+sli
          case 14: 
            break;  // fix+fix
          } 
          break;
        case 2:  // Case for UNIFORM LOAD
          switch(b1.nodeCombCase) {
          case 2: 
            break;  // rod+rod
          case 4:  // rod+sli - Rod is always in the left side (node[0])
            nodeReactionLoad [i] [j] [1] = -b1.L/100*load[j].magnitudeY*(load[j].rf-load[j].ri)*abs(load[j].ri+(load[j].rf-load[j].ri)/2-(1-i));
            nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX*b1.L/100*(load[j].rf-load[j].ri);
            break;
          case 7:  // fix+no - Fix is always in the left side (node[0])
            nodeReactionLoad [0] [j] [1] = -load[j].magnitudeY*(load[j].rf-load[j].ri)*b1.L/100;
            nodeReactionLoad [0] [j] [2] = -load[j].magnitudeX*(load[j].rf-load[j].ri)*b1.L/100;
            nodeReactionLoad [0] [j] [3] = load[j].magnitudeY*(load[j].rf-load[j].ri)*sq(b1.L/100)*(load[j].ri+(load[j].rf-load[j].ri)/2);
            break;              
          case 8: 
            break;  // fix+rod
          case 10: 
            break;  // fix+sli
          case 14: 
            break;  // fix+fix
          } 
          break;
        }
        for (int k=0; k<4; k++) {
          nodeReactionTotal[i][k]+=nodeReactionLoad[i][j][k];
        }  // Calculation of total reactions
      }
    }
  }

  void displayNodesReactions() {
    for (int i=0; i<numberOfNodes; i++) {
      drawReactionArrows(i); 
      if (showValues==true) {
        drawReactionText(i);
      }
    }
  }

  void calcBeamDiagramSetup() {
    // To be run only once within the void setup() main function
    // Third column tag: 0 is axial, 1 is shear, 2 is bending and 3 is deformed
    beamRange=int(b1.L);
    beamDiagramLoad=new float[beamRange] [numberOfLoads] [4]; 
    beamDiagramTotal=new float[beamRange] [4];    
    topValueLoad=new float [numberOfLoads] [2] [4]; 
    topIndexLoad=new int [numberOfLoads] [2] [4];
    topValueTotal=new float [2] [4]; 
    topIndexTotal=new int [2] [4];
  }

  void calcBeamDiagramAxial() {
    for (int i=0; i<beamRange; i++) {
      beamDiagramTotal[i][0]=0;  // Resets axial totals
      for (int j=0; j<activeLoads; j++) { // Calculates each load's axial forces
        switch(load[j].kindN) {  
        case 0:  // Case for PUNTUAL LOADS
          if (i<load[j].ri*beamRange) {
            beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2];
          } else {
            beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2]+load[j].magnitudeX;
          }
          break;
        case 1:  // Case for MOMENT LOAD
          beamDiagramLoad[i][j][0]=0;
          break; 
        case 2:  // Case for UNIFORM LOAD
          if (i<load[j].ri*beamRange) {
            beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2];
          } else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange) 
          {
            beamDiagramLoad[i][j][0]=nodeReactionLoad[0][j][2]+(i-load[j].ri*b1.L)*load[j].magnitudeX/100;
          } else if (i>load[j].rf) {
            beamDiagramLoad[i][j][0]=0;
          }
          break;
        }
        beamDiagramTotal[i][0]+=beamDiagramLoad[i][j][0];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][0] < topValueLoad[j][0][0]) {
          topValueLoad[j][0][0] = beamDiagramLoad[i][j][0]; 
          topIndexLoad[j][0][0] = i;
        } // min value
        if (beamDiagramLoad[i][j][0] > topValueLoad[j][1][0]) {
          topValueLoad[j][1][0] = beamDiagramLoad[i][j][0]; 
          topIndexLoad[j][1][0] = i;
        } // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][0] < topValueTotal[0][0]) {
        topValueTotal[0][0] = beamDiagramTotal[i][0]; 
        topIndexTotal[0][0] = i;
      }
      if (beamDiagramTotal[i][0] > topValueTotal[1][0]) {
        topValueTotal[1][0] = beamDiagramTotal[i][0]; 
        topIndexTotal[1][0] = i;
      }
    }
  }

  void calcBeamDiagramShear() {
    for (int i=0; i<beamRange; i++) {
      beamDiagramTotal[i][1]=0;  // Resets shear totals
      for (int j=0; j<activeLoads; j++) {  // Calculates each load's shear forces
        switch(load[j].kindN) {
        case 0:  // Case for PUNTUAL LOADS
          if (i<load[j].ri*beamRange) {
            beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1];
          } else {
            beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1]+load[j].magnitudeY;
          }
          break;
        case 1:  // Case for MOMENT LOADS
          beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1];
          break;
        case 2:  // Case for LINEAL LOADS
          if (i<load[j].ri*beamRange) {
            beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1];
          } else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange)
          {
            beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1]+(i-load[j].ri*b1.L)*load[j].magnitudeY/100;
          } else if (i>load[j].rf) {
            beamDiagramLoad[i][j][1]=nodeReactionLoad[0][j][1]+(load[j].rf-load[j].ri)*b1.L*load[j].magnitudeY/100;
          }
          break;
        }
        beamDiagramTotal[i][1]+=beamDiagramLoad[i][j][1];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][1] < topValueLoad[j][0][1]) {
          topValueLoad[j][0][1] = beamDiagramLoad[i][j][1]; 
          topIndexLoad[j][0][1] = i;
        } // min value
        if (beamDiagramLoad[i][j][1] > topValueLoad[j][1][1]) {
          topValueLoad[j][1][1] = beamDiagramLoad[i][j][1]; 
          topIndexLoad[j][1][1] = i;
        } // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][1] < topValueTotal[0][1]) {
        topValueTotal[0][1] = beamDiagramTotal[i][1]; 
        topIndexTotal[0][1] = i;
      }
      if (beamDiagramTotal[i][1] > topValueTotal[1][1]) {
        topValueTotal[1][1] = beamDiagramTotal[i][1]; 
        topIndexTotal[1][1] = i;
      }
    }
  }

  void calcBeamDiagramBending() {
    for (int i=0; i<beamRange; i++) {
      beamDiagramTotal[i][2]=0;  // Resets bending totals
      for (int j=0; j<activeLoads; j++) {  // Calculates each load's bending forces
        switch(load[j].kindN) {
        case 0:  // Case for PUNTUAL LOADS  
          if (i<load[j].ri*beamRange) {
            beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100;
          } else {
            beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-load[j].magnitudeY*(i-load[j].ri*b1.L)/100;
          }
          break;
        case 1:  // Case for MOMENT LOADS
          if (i<load[j].ri*beamRange) {
            beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100;
          } else {
            beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-load[j].magnitude;
          }
          break;
        case 2:  // Case for UNIFORM LOADS
          if (i<load[j].ri*beamRange) {
            beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100;
          } else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange)
          {
            beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-sq(i-load[j].ri*b1.L)*load[j].magnitudeY/2/10000;
          } else if (i>load[j].rf*beamRange) 
          {
            beamDiagramLoad[i][j][2]=-nodeReactionLoad[0][j][3]-nodeReactionLoad[0][j][1]*i/100-(load[j].rf-load[j].ri)*(b1.L)*load[j].magnitudeY/100*
              (i-load[j].ri*b1.L-(load[j].rf-load[j].ri)*b1.L/2)/100;
          }
          break;
        }
        beamDiagramTotal[i][2]+=beamDiagramLoad[i][j][2];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][2] < topValueLoad[j][0][2]) {
          topValueLoad[j][0][2] = beamDiagramLoad[i][j][2]; 
          topIndexLoad[j][0][2] = i;
        } // min value
        if (beamDiagramLoad[i][j][2] > topValueLoad[j][1][2]) {
          topValueLoad[j][1][2] = beamDiagramLoad[i][j][2]; 
          topIndexLoad[j][1][2] = i;
        } // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][2] < topValueTotal[0][2]) {
        topValueTotal[0][2] = beamDiagramTotal[i][2]; 
        topIndexTotal[0][2] = i;
      }
      if (beamDiagramTotal[i][2] > topValueTotal[1][2]) {
        topValueTotal[1][2] = beamDiagramTotal[i][2]; 
        topIndexTotal[1][2] = i;
      }
    }
  }

  void calcBeamDiagramDeformed() {
    float I=0;
    for (int i=0; i<beamRange; i++) {
      I=i/100.0;
      beamDiagramTotal[i][3]=0;  // Resets deformed totals
      for (int j=0; j<activeLoads; j++) {  // Calculates each load's deformed shape
        switch(load[j].kindN) {
        case 0:  // Case for PUNTUAL LOADS
          float a0=load[j].ri*b1.Lm; 
          float b0=b1.Lm-a0;
          switch(b1.nodeCombCase) {
          case 4:  // rod+sli
            if (i<load[j].ri*beamRange) {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*b1.Lm*b0*I*
                (1-sq(b0)/sq(b1.Lm)-sq(I)/sq(b1.Lm))/(6*EI);
            } else {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*b1.L/100*a0*(b1.L/100-I)*
                (1-sq(a0)/sq(b1.Lm)-sq((b1.Lm-I)/b1.Lm))/(6*EI);
            } 
            break;
          case 7:  // fix+no
            if (i<load[j].ri*beamRange) {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*sq(I)*(2*a0-b0+b1.Lm-I)/(6*EI);
            } else {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*sq(a0)*(3*I-a0)/(6*EI);
            } 
            break;
          }
          break;
        case 1:  // Case for MOMENT LOADS
          float a1=load[j].ri*b1.Lm; 
          float b11=b1.Lm-a1;
          switch(b1.nodeCombCase) {
          case 4:  // rod+sli
            if (i<load[j].ri*beamRange) {
              beamDiagramLoad[i][j][3]=load[j].magnitude*b1.Lm*I*
                (1-3*sq(b11)/sq(b1.Lm)-sq(I)/sq(b1.Lm))/(6*EI);
            } else {
              beamDiagramLoad[i][j][3]=-load[j].magnitude*b1.Lm*(b1.Lm-I)*
                (1-3*sq(a1)/sq(b1.Lm)-sq((b1.Lm-I)/b1.Lm))/(6*EI);
            } 
            break;
          case 7:  // fix+no
            if (i<load[j].ri*beamRange) {
              beamDiagramLoad[i][j][3]=-load[j].magnitude*sq(I)/(2*EI);
            } else {
              beamDiagramLoad[i][j][3]=-load[j].magnitude*a1*(2*b1.Lm-2*(b1.Lm-I)-a1)/(2*EI);
            } 
            break;
          }
          break;
        case 2:  // Case for UNIFORM LOADS
          float a2=load[j].ri*b1.Lm+(load[j].rf-load[j].ri)*b1.Lm/2;
          float b2=b1.Lm-(load[j].ri*b1.Lm+(load[j].rf-load[j].ri)*b1.Lm/2);
          float c2=(load[j].rf-load[j].ri)*b1.Lm;
          switch(b1.nodeCombCase) {
          case 4:  // rod+sli
            if (i<load[j].ri*beamRange) {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*b2*c2*I*(-sq(I)+a2*(b1.Lm+b2-sq(c2)/(4*a2)))/(6*b1.Lm*EI);
            } else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange) {
              beamDiagramLoad[i][j][3]=
                load[j].magnitudeY*(b1.Lm*pow((I-(a2-c2/2)), 4)-4*b2*c2*pow(I, 3)+4*a2*b2*c2*I*(b1.Lm+b2-sq(c2)/(4*a2)))/(24*b1.Lm*EI);
            } else {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*a2*c2*(b1.Lm-I)*(-sq(b1.Lm-I)+b2*(b1.Lm+a2-sq(c2)/(4*b2)))/(6*b1.Lm*EI);
            }       
            break;
          case 7:  // fix+no
            if (i<load[j].ri*beamRange) {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*c2*sq(I)*(2*a2-b2+b1.Lm-I)/(6*EI);
            } else if (load[j].ri*beamRange<=i && i<=load[j].rf*beamRange) {
              beamDiagramLoad[i][j][3]=
                load[j].magnitudeY*(pow(b1.Lm-I-b2+c2/2, 4)+4*c2*(b2-b1.Lm+I)*(3*sq(a2)+sq(c2)/4)+8*pow(a2, 3)*c2)/(24*EI);
            } else {
              beamDiagramLoad[i][j][3]=load[j].magnitudeY*c2*((b2-b1.Lm+I)*(3*sq(a2)+sq(c2)/4)+2*pow(a2, 3))/(6*EI);
            }
            break;
          }          
          break;
        }
        beamDiagramTotal[i][3]+=beamDiagramLoad[i][j][3];  // Adds to total axial forces per range point
        // Calculates min and max values per load
        if (beamDiagramLoad[i][j][3] < topValueLoad[j][0][3]) {
          topValueLoad[j][0][3] = beamDiagramLoad[i][j][3]; 
          topIndexLoad[j][0][3] = i;
        } // min value
        if (beamDiagramLoad[i][j][3] > topValueLoad[j][1][3]) {
          topValueLoad[j][1][3] = beamDiagramLoad[i][j][3]; 
          topIndexLoad[j][1][3] = i;
        } // max value
      }   
      // Calculates total min and max values
      if (beamDiagramTotal[i][3] < topValueTotal[0][3]) {
        topValueTotal[0][3] = beamDiagramTotal[i][3]; 
        topIndexTotal[0][3] = i;
      }
      if (beamDiagramTotal[i][3] > topValueTotal[1][3]) {
        topValueTotal[1][3] = beamDiagramTotal[i][3]; 
        topIndexTotal[1][3] = i;
      }
    }
  }

  void displayBeamDiagramAxial() {
    drawBeamDiagram(0); 
    if (showValues==true) {
      drawBeamDiagramValues(0);
    }
  }
  void displayBeamDiagramShear() {
    drawBeamDiagram(1); 
    if (showValues==true) {
      drawBeamDiagramValues(1);
    }
  }
  void displayBeamDiagramBending() {
    drawBeamDiagram(2); 
    if (showValues==true) {
      drawBeamDiagramValues(2);
    }
  }
  void displayBeamDiagramDeformed() {
    drawBeamDiagram(3); 
    if (showValues==true) {
      drawBeamDiagramValues(3);
    }
  }
}
